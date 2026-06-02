from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_ROOT = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "redraw_batches"
CELL = 96
BASELINE_Y = 92
MAX_BODY_WIDTH = 84
MAX_BODY_HEIGHT = 88


def remove_background(image: Image.Image) -> Image.Image:
    image = image.convert("RGBA")
    pixels = image.load()
    bg = pixels[0, 0]
    br, bgc, bb, _ba = bg
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            if abs(r - br) < 28 and abs(g - bgc) < 28 and abs(b - bb) < 28 and max(r, g, b) < 70:
                pixels[x, y] = (0, 0, 0, 0)
    return image


def is_skin_pixel(r: int, g: int, b: int, a: int) -> bool:
    return a > 40 and r > 105 and g > 58 and b > 38 and r > g > b and (r - b) > 35


def is_cyan_effect_pixel(r: int, g: int, b: int, a: int) -> bool:
    return a > 25 and b > 110 and g > 80 and b > r * 1.35


def polish_small_sprite(frame: Image.Image) -> Image.Image:
    frame = frame.convert("RGBA")
    pixels = frame.load()
    bbox = frame.getbbox()
    if bbox is None:
        return frame

    skin_points: list[tuple[int, int]] = []
    top_limit = min(CELL, bbox[1] + 40)
    for y in range(bbox[1], top_limit):
        for x in range(bbox[0], bbox[2]):
            if is_skin_pixel(*pixels[x, y]):
                skin_points.append((x, y))

    for x, y in skin_points:
        r, g, b, a = pixels[x, y]
        pixels[x, y] = (min(255, r + 28), min(220, g + 18), min(180, b + 10), max(a, 230))
        for nx, ny in ((x + 1, y), (x, y + 1)):
            if 0 <= nx < CELL and 0 <= ny < CELL:
                nr, ng, nb, na = pixels[nx, ny]
                if na == 0 or (nr + ng + nb) < 110:
                    pixels[nx, ny] = (194, 126, 88, max(na, 175))

    for y in range(CELL):
        for x in range(CELL):
            r, g, b, a = pixels[x, y]
            if is_cyan_effect_pixel(r, g, b, a):
                pixels[x, y] = (min(r, 55), min(255, g + 28), min(255, b + 36), max(a, 220))

    return frame


def normalize_frame(frame: Image.Image) -> Image.Image:
    frame = remove_background(frame)
    bbox = frame.getbbox()
    output = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    if bbox is None:
        return output

    cropped = frame.crop(bbox)
    scale = min(MAX_BODY_WIDTH / cropped.width, MAX_BODY_HEIGHT / cropped.height, 1.0)
    next_size = (
        max(1, round(cropped.width * scale)),
        max(1, round(cropped.height * scale)),
    )
    resized = cropped.resize(next_size, Image.Resampling.LANCZOS)
    x = (CELL - resized.width) // 2
    y = max(0, BASELINE_Y - resized.height)
    output.alpha_composite(resized, (x, y))
    return polish_small_sprite(output)


def offset_frame(frame: Image.Image, dx: int, dy: int) -> Image.Image:
    if dx == 0 and dy == 0:
        return frame

    output = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    output.alpha_composite(frame, (dx, dy))
    return output


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True)
    parser.add_argument("--batch", default="batch_01")
    parser.add_argument("--animation", required=True)
    parser.add_argument("--panel-count", type=int, required=True)
    parser.add_argument(
        "--map",
        nargs="+",
        required=True,
        help="panel_index:frame_index[:dx[:dy]]",
    )
    args = parser.parse_args()

    source_path = Path(args.source)
    image = Image.open(source_path).convert("RGBA")
    panel_width = image.width / args.panel_count
    out_dir = OUTPUT_ROOT / args.batch / args.animation
    out_dir.mkdir(parents=True, exist_ok=True)

    for item in args.map:
        parts = item.split(":")
        panel_text = parts[0]
        frame_text = parts[1]
        dx = int(parts[2]) if len(parts) >= 3 else 0
        dy = int(parts[3]) if len(parts) >= 4 else 0
        panel_index = int(panel_text)
        frame_index = int(frame_text)
        left = round(panel_index * panel_width)
        right = round((panel_index + 1) * panel_width)
        panel = image.crop((left, 0, right, image.height))
        normalized = normalize_frame(panel)
        normalized = offset_frame(normalized, dx, dy)
        out_path = out_dir / f"frame_{frame_index:02d}.png"
        normalized.save(out_path)
        print(out_path.relative_to(ROOT).as_posix())


if __name__ == "__main__":
    main()
