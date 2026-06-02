from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_ROOT = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "redraw_batches"
CELL = 96
BASELINE_Y = 92


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


def normalize_frame(frame: Image.Image) -> Image.Image:
    frame = remove_background(frame)
    bbox = frame.getbbox()
    output = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    if bbox is None:
        return output

    cropped = frame.crop(bbox)
    max_width = 90
    max_height = 90
    scale = min(max_width / cropped.width, max_height / cropped.height, 1.0)
    next_size = (
        max(1, round(cropped.width * scale)),
        max(1, round(cropped.height * scale)),
    )
    resized = cropped.resize(next_size, Image.Resampling.LANCZOS)
    x = (CELL - resized.width) // 2
    y = max(0, BASELINE_Y - resized.height)
    output.alpha_composite(resized, (x, y))
    return output


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True)
    parser.add_argument("--batch", default="batch_01")
    parser.add_argument("--animation", required=True)
    parser.add_argument("--panel-count", type=int, required=True)
    parser.add_argument("--map", nargs="+", required=True, help="panel_index:frame_index")
    args = parser.parse_args()

    source_path = Path(args.source)
    image = Image.open(source_path).convert("RGBA")
    panel_width = image.width / args.panel_count
    out_dir = OUTPUT_ROOT / args.batch / args.animation
    out_dir.mkdir(parents=True, exist_ok=True)

    for item in args.map:
        panel_text, frame_text = item.split(":")
        panel_index = int(panel_text)
        frame_index = int(frame_text)
        left = round(panel_index * panel_width)
        right = round((panel_index + 1) * panel_width)
        panel = image.crop((left, 0, right, image.height))
        normalized = normalize_frame(panel)
        out_path = out_dir / f"frame_{frame_index:02d}.png"
        normalized.save(out_path)
        print(out_path.relative_to(ROOT).as_posix())


if __name__ == "__main__":
    main()
