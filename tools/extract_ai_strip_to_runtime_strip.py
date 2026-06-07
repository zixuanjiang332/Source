from __future__ import annotations

import argparse
from collections import deque
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
CELL = 96
FOOT_BASELINE_Y = 92
MAX_FRAME_WIDTH = 88
MAX_FRAME_HEIGHT = 88


@dataclass(frozen=True)
class Component:
    bbox: tuple[int, int, int, int]
    area: int
    cyan_ratio: float
    points: tuple[tuple[int, int], ...]

    @property
    def center_x(self) -> float:
        return (self.bbox[0] + self.bbox[2]) / 2

    @property
    def width(self) -> int:
        return self.bbox[2] - self.bbox[0]

    @property
    def height(self) -> int:
        return self.bbox[3] - self.bbox[1]


def is_key_green(r: int, g: int, b: int, a: int) -> bool:
    if a <= 12:
        return True
    is_cyan = a > 25 and b > 110 and g > 80 and b > r * 1.25
    if is_cyan:
        return False
    return g >= 120 and g > r * 1.25 and g > b * 1.08


def remove_green(source: Image.Image) -> Image.Image:
    image = source.convert("RGBA")
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if is_key_green(r, g, b, a):
                pixels[x, y] = (0, 0, 0, 0)
    return image


def components(image: Image.Image, *, min_area: int) -> list[Component]:
    pixels = image.load()
    visited: set[tuple[int, int]] = set()
    found: list[Component] = []
    for sy in range(image.height):
        for sx in range(image.width):
            if (sx, sy) in visited:
                continue
            visited.add((sx, sy))
            if pixels[sx, sy][3] == 0:
                continue
            queue = deque([(sx, sy)])
            area = 0
            component_points: list[tuple[int, int]] = []
            min_x = max_x = sx
            min_y = max_y = sy
            while queue:
                x, y = queue.popleft()
                area += 1
                component_points.append((x, y))
                min_x = min(min_x, x)
                max_x = max(max_x, x)
                min_y = min(min_y, y)
                max_y = max(max_y, y)
                for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if nx < 0 or nx >= image.width or ny < 0 or ny >= image.height or (nx, ny) in visited:
                        continue
                    visited.add((nx, ny))
                    if pixels[nx, ny][3] > 0:
                        queue.append((nx, ny))
            if area >= min_area:
                cyan = 0
                for px, py in component_points:
                    r, g, b, a = pixels[px, py]
                    if a > 25 and b > 95 and g > 75 and b > r * 1.18:
                        cyan += 1
                found.append(
                    Component(
                        (min_x, min_y, max_x + 1, max_y + 1),
                        area,
                        cyan / max(1, area),
                        tuple(component_points),
                    )
                )
    return found


def select_anchor_components(parts: list[Component], frame_count: int) -> list[Component]:
    body_like = [
        part
        for part in parts
        if part.area >= 240 and part.height >= 42 and part.width >= 12 and part.cyan_ratio < 0.45
    ]
    if not body_like:
        body_like = [
            part
            for part in parts
            if part.area >= 160 and part.height >= 30 and part.width >= 10 and part.cyan_ratio < 0.7
        ]
    body_like.sort(key=lambda part: part.area * (1.0 - min(part.cyan_ratio, 0.9) * 0.55), reverse=True)
    anchors = sorted(body_like[:frame_count], key=lambda part: part.center_x)
    if not anchors:
        raise RuntimeError("No body components found")
    return anchors


def bucket_bounds(anchors: list[Component], image_width: int) -> list[tuple[float, float]]:
    centers = [anchor.center_x for anchor in anchors]
    bounds: list[tuple[float, float]] = []
    for index, center in enumerate(centers):
        left = 0.0 if index == 0 else (centers[index - 1] + center) / 2
        right = float(image_width) if index == len(centers) - 1 else (center + centers[index + 1]) / 2
        bounds.append((left, right))
    return bounds


def crop_frame(image: Image.Image, parts: list[Component], anchor: Component, left: float, right: float) -> Image.Image:
    left_i = max(0, round(left))
    right_i = min(image.width, round(right))
    included = [
        part
        for part in parts
        if (
            part == anchor
            or (
                left <= part.center_x < right
                and not (part.area < 18 and part.height < 7 and part.width < 7)
                and (part.area < 160 or part.height < 35 or part.cyan_ratio > 0.25)
            )
        )
    ]

    selected_points: list[tuple[int, int]] = []
    for part in included:
        selected_points.extend((x, y) for x, y in part.points if left_i <= x < right_i)

    if not selected_points:
        return Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))

    x0 = max(left_i, min(x for x, _y in selected_points) - 8)
    y0 = max(0, min(y for _x, y in selected_points) - 8)
    x1 = min(right_i, max(x for x, _y in selected_points) + 9)
    y1 = min(image.height, max(y for _x, y in selected_points) + 9)
    cropped = Image.new("RGBA", (x1 - x0, y1 - y0), (0, 0, 0, 0))
    source_pixels = image.load()
    cropped_pixels = cropped.load()
    for x, y in selected_points:
        if x0 <= x < x1 and y0 <= y < y1:
            cropped_pixels[x - x0, y - y0] = source_pixels[x, y]

    bbox = cropped.getbbox()
    output = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    if bbox is None:
        return output
    cropped = cropped.crop(bbox)
    scale = min(MAX_FRAME_WIDTH / cropped.width, MAX_FRAME_HEIGHT / cropped.height, 1.0)
    size = (max(1, round(cropped.width * scale)), max(1, round(cropped.height * scale)))
    resized = cropped.resize(size, Image.Resampling.LANCZOS)
    x = (CELL - resized.width) // 2
    y = max(0, FOOT_BASELINE_Y - resized.height)
    output.alpha_composite(resized, (x, y))
    return output


def resample_frames(frames: list[Image.Image], frame_count: int) -> list[Image.Image]:
    if len(frames) == frame_count:
        return frames
    if len(frames) == 1:
        return [frames[0].copy() for _ in range(frame_count)]
    resampled: list[Image.Image] = []
    for index in range(frame_count):
        source_index = round(index * (len(frames) - 1) / max(1, frame_count - 1))
        resampled.append(frames[source_index].copy())
    return resampled


def crop_cell_window(image: Image.Image, left: int, right: int) -> Image.Image:
    window = image.crop((left, 0, right, image.height))
    parts = components(window, min_area=14)
    body_like = [
        part
        for part in parts
        if part.area >= 160 and part.height >= 30 and part.width >= 10 and part.cyan_ratio < 0.55
    ]
    center_x = window.width / 2
    if body_like:
        anchor = max(
            body_like,
            key=lambda part: (
                part.area * (1.0 - min(part.cyan_ratio, 0.9) * 0.55)
                - abs(part.center_x - center_x) * 18.0
            ),
        )
    else:
        anchor = max(parts, key=lambda part: part.area, default=None)

    kept_points: list[tuple[int, int]] = []
    for part in parts:
        if anchor is None:
            continue
        if part.area < 18 and part.height < 7 and part.width < 7:
            continue
        touches_edge = part.bbox[0] <= 2 or part.bbox[2] >= window.width - 2
        close_to_anchor = abs(part.center_x - anchor.center_x) <= max(48, window.width * 0.33)
        overlaps_anchor_y = part.bbox[1] < anchor.bbox[3] and part.bbox[3] > anchor.bbox[1]
        if part != anchor:
            if touches_edge and part.cyan_ratio < 0.75:
                continue
            if part.cyan_ratio > 0.25:
                if not close_to_anchor and part.area < 900:
                    continue
            elif not (close_to_anchor and overlaps_anchor_y):
                continue
        kept_points.extend(part.points)

    output = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    if not kept_points:
        return output

    x0 = max(0, min(x for x, _y in kept_points) - 8)
    y0 = max(0, min(y for _x, y in kept_points) - 8)
    x1 = min(window.width, max(x for x, _y in kept_points) + 9)
    y1 = min(window.height, max(y for _x, y in kept_points) + 9)
    cropped = Image.new("RGBA", (x1 - x0, y1 - y0), (0, 0, 0, 0))
    source_pixels = window.load()
    cropped_pixels = cropped.load()
    for x, y in kept_points:
        if x0 <= x < x1 and y0 <= y < y1:
            cropped_pixels[x - x0, y - y0] = source_pixels[x, y]

    bbox = cropped.getbbox()
    if bbox is None:
        return output
    cropped = cropped.crop(bbox)
    scale = min(MAX_FRAME_WIDTH / cropped.width, MAX_FRAME_HEIGHT / cropped.height, 1.0)
    size = (max(1, round(cropped.width * scale)), max(1, round(cropped.height * scale)))
    resized = cropped.resize(size, Image.Resampling.LANCZOS)
    x = (CELL - resized.width) // 2
    y = max(0, FOOT_BASELINE_Y - resized.height)
    output.alpha_composite(resized, (x, y))
    return output


def frame_from_points(image: Image.Image, points: list[tuple[int, int]]) -> Image.Image:
    if not points:
        return Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))

    x0 = max(0, min(x for x, _y in points) - 8)
    y0 = max(0, min(y for _x, y in points) - 8)
    x1 = min(image.width, max(x for x, _y in points) + 9)
    y1 = min(image.height, max(y for _x, y in points) + 9)
    cropped = Image.new("RGBA", (x1 - x0, y1 - y0), (0, 0, 0, 0))
    source_pixels = image.load()
    cropped_pixels = cropped.load()
    for x, y in points:
        if x0 <= x < x1 and y0 <= y < y1:
            cropped_pixels[x - x0, y - y0] = source_pixels[x, y]

    bbox = cropped.getbbox()
    output = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    if bbox is None:
        return output
    cropped = cropped.crop(bbox)
    scale = min(MAX_FRAME_WIDTH / cropped.width, MAX_FRAME_HEIGHT / cropped.height, 1.0)
    size = (max(1, round(cropped.width * scale)), max(1, round(cropped.height * scale)))
    resized = cropped.resize(size, Image.Resampling.LANCZOS)
    x = (CELL - resized.width) // 2
    y = max(0, FOOT_BASELINE_Y - resized.height)
    output.alpha_composite(resized, (x, y))
    return output


def frame_from_component_centers(image: Image.Image, centers: list[float]) -> Image.Image:
    parts = components(image, min_area=14)
    points: list[tuple[int, int]] = []
    for center in centers:
        nearest = min(parts, key=lambda part: abs(part.center_x - center), default=None)
        if nearest is not None:
            points.extend(nearest.points)
    return frame_from_points(image, points)


def frame_from_masked_window(
    image: Image.Image,
    box: tuple[int, int, int, int],
    *,
    remove_non_cyan_before_x: int | None = None,
    remove_non_cyan_after_x: int | None = None,
) -> Image.Image:
    cropped = image.crop(box).convert("RGBA")
    pixels = cropped.load()
    for y in range(cropped.height):
        for x in range(cropped.width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            remove_left = remove_non_cyan_before_x is not None and x < remove_non_cyan_before_x
            remove_right = remove_non_cyan_after_x is not None and x > remove_non_cyan_after_x
            if (remove_left or remove_right) and not (a > 25 and b > 95 and g > 75 and b > r * 1.18):
                pixels[x, y] = (0, 0, 0, 0)

    points: list[tuple[int, int]] = []
    for part in components(cropped, min_area=14):
        points.extend(part.points)
    return frame_from_points(cropped, points)


def apply_manual_problem_frame_overrides(source_name: str, image: Image.Image, frames: list[Image.Image]) -> None:
    if source_name == "punch_2_12_frame_face_lock_source.png" and len(frames) >= 8:
        frames[6] = frame_from_component_centers(image, [1087.0, 1250.5])
        frames[7] = frame_from_component_centers(image, [1349.0])
    elif source_name == "punch_3_14_frame_face_lock_source.png" and len(frames) >= 10:
        frames[7] = frame_from_component_centers(image, [996.5])
        frames[8] = frame_from_masked_window(image, (1100, 180, 1405, 545), remove_non_cyan_after_x=210)
        frames[9] = frame_from_component_centers(image, [1632.5])


def extract_grid_frames(image: Image.Image, frame_count: int) -> list[Image.Image]:
    cell_width = image.width / frame_count
    frames: list[Image.Image] = []
    for index in range(frame_count):
        left = round(index * cell_width)
        right = round((index + 1) * cell_width)
        frames.append(crop_cell_window(image, left, right))
    return frames


def extract_anchor_frames(image: Image.Image, frame_count: int) -> list[Image.Image]:
    parts = components(image, min_area=14)
    anchors = select_anchor_components(parts, frame_count)
    bounds = bucket_bounds(anchors, image.width)
    return resample_frames(
        [crop_frame(image, parts, anchor, left, right) for anchor, (left, right) in zip(anchors, bounds)],
        frame_count,
    )


def extract(source_path: Path, out_path: Path, frame_count: int) -> None:
    keyed = remove_green(Image.open(source_path))
    frames = extract_anchor_frames(keyed, frame_count)
    apply_manual_problem_frame_overrides(source_path.name, keyed, frames)
    strip = Image.new("RGBA", (CELL * frame_count, CELL), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        strip.alpha_composite(frame, (index * CELL, 0))
    out_path.parent.mkdir(parents=True, exist_ok=True)
    strip.save(out_path)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("out", type=Path)
    parser.add_argument("--frames", type=int, required=True)
    args = parser.parse_args()
    extract(args.source, args.out, args.frames)


if __name__ == "__main__":
    main()
