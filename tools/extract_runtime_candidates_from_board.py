from __future__ import annotations

import argparse
from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
CELL = 96
TARGET_BODY_W = 62
TARGET_BODY_H = 72
BASELINE_Y = 92
BG_THRESHOLD = 18
MIN_COMPONENT_AREA = 24
POST_CLEAN_AREA = 16
PAD = 3


def component_groups(image: Image.Image) -> list[dict[str, object]]:
    pixels = image.load()
    width, height = image.size
    bg = pixels[0, 0][:3]
    visited: set[tuple[int, int]] = set()
    groups: list[dict[str, object]] = []

    def is_subject(x: int, y: int) -> bool:
        r, g, b, a = pixels[x, y]
        return a > 0 and max(abs(r - bg[0]), abs(g - bg[1]), abs(b - bg[2])) > BG_THRESHOLD

    for start_y in range(height):
        for start_x in range(width):
            if (start_x, start_y) in visited:
                continue
            visited.add((start_x, start_y))
            if not is_subject(start_x, start_y):
                continue

            queue = deque([(start_x, start_y)])
            points: list[tuple[int, int]] = [(start_x, start_y)]
            min_x = max_x = start_x
            min_y = max_y = start_y

            while queue:
                x, y = queue.popleft()
                for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if nx < 0 or nx >= width or ny < 0 or ny >= height or (nx, ny) in visited:
                        continue
                    visited.add((nx, ny))
                    if is_subject(nx, ny):
                        queue.append((nx, ny))
                        points.append((nx, ny))
                        min_x = min(min_x, nx)
                        max_x = max(max_x, nx)
                        min_y = min(min_y, ny)
                        max_y = max(max_y, ny)

            if len(points) >= MIN_COMPONENT_AREA:
                groups.append(
                    {
                        "area": len(points),
                        "points": points,
                        "bbox": (min_x, min_y, max_x + 1, max_y + 1),
                        "center_x": (min_x + max_x) / 2,
                    }
                )

    return groups


def assign_groups_to_frames(groups: list[dict[str, object]], width: int, frame_count: int) -> list[list[dict[str, object]]]:
    frame_w = width / frame_count
    buckets: list[list[dict[str, object]]] = [[] for _ in range(frame_count)]
    for group in groups:
        center_x = float(group["center_x"])
        index = min(frame_count - 1, max(0, int(center_x / frame_w)))
        buckets[index].append(group)
    return buckets


def crop_bucket(board: Image.Image, bucket: list[dict[str, object]]) -> Image.Image:
    if not bucket:
        return Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))

    min_x = min(int(group["bbox"][0]) for group in bucket)
    min_y = min(int(group["bbox"][1]) for group in bucket)
    max_x = max(int(group["bbox"][2]) for group in bucket)
    max_y = max(int(group["bbox"][3]) for group in bucket)

    min_x = max(0, min_x - PAD)
    min_y = max(0, min_y - PAD)
    max_x = min(board.width, max_x + PAD)
    max_y = min(board.height, max_y + PAD)
    subject = board.crop((min_x, min_y, max_x, max_y)).convert("RGBA")

    bg = board.getpixel((0, 0))[:3]
    pixels = subject.load()
    for y in range(subject.height):
        for x in range(subject.width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            if max(abs(r - bg[0]), abs(g - bg[1]), abs(b - bg[2])) <= BG_THRESHOLD:
                pixels[x, y] = (0, 0, 0, 0)

    scale = min(TARGET_BODY_W / subject.width, TARGET_BODY_H / subject.height)
    resized = subject.resize(
        (max(1, round(subject.width * scale)), max(1, round(subject.height * scale))),
        Image.Resampling.BOX,
    )
    frame = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    x = (CELL - resized.width) // 2
    y = BASELINE_Y - resized.height
    frame.alpha_composite(resized, (x, y))
    return strip_post_fragments(frame)


def strip_post_fragments(image: Image.Image) -> Image.Image:
    image = image.convert("RGBA")
    pixels = image.load()
    visited: set[tuple[int, int]] = set()
    remove: list[tuple[int, int]] = []

    for start_y in range(image.height):
        for start_x in range(image.width):
            if (start_x, start_y) in visited:
                continue
            visited.add((start_x, start_y))
            if pixels[start_x, start_y][3] == 0:
                continue

            queue = deque([(start_x, start_y)])
            points = [(start_x, start_y)]
            while queue:
                x, y = queue.popleft()
                for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if nx < 0 or nx >= image.width or ny < 0 or ny >= image.height or (nx, ny) in visited:
                        continue
                    visited.add((nx, ny))
                    if pixels[nx, ny][3] > 0:
                        queue.append((nx, ny))
                        points.append((nx, ny))

            if len(points) < POST_CLEAN_AREA:
                remove.extend(points)

    for x, y in remove:
        pixels[x, y] = (0, 0, 0, 0)
    return image


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--board", required=True)
    parser.add_argument("--frame-count", required=True, type=int)
    parser.add_argument("--prefix", required=True)
    parser.add_argument("--output-dir", required=True)
    args = parser.parse_args()

    board_path = Path(args.board)
    if not board_path.is_absolute():
        board_path = ROOT / board_path
    output_dir = Path(args.output_dir)
    if not output_dir.is_absolute():
        output_dir = ROOT / output_dir

    board = Image.open(board_path).convert("RGBA")
    groups = component_groups(board)
    buckets = assign_groups_to_frames(groups, board.width, args.frame_count)
    output_dir.mkdir(parents=True, exist_ok=True)

    for stale in output_dir.glob(f"{args.prefix}_*.png"):
        stale.unlink()

    for index, bucket in enumerate(buckets):
        frame = crop_bucket(board, bucket)
        frame.save(output_dir / f"{args.prefix}_{index:02d}.png")

    print(board_path)
    print(output_dir)
    print(f"groups={len(groups)} frames={args.frame_count}")


if __name__ == "__main__":
    main()
