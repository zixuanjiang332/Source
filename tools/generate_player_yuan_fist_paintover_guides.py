from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "strips"
OUTPUT_DIR = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "paintover_guides"

CELL = 96
BASELINE_Y = 92
CENTER_X = 48

STRIPS = [
    ("combat_idle", 8),
    ("combat_run", 8),
    ("punch_1", 8),
    ("punch_2", 8),
    ("punch_3", 10),
    ("punch_skill", 10),
]


def soften_frame(frame: Image.Image, alpha: int = 185) -> Image.Image:
    frame = frame.convert("RGBA")
    pixels = frame.load()
    for y in range(frame.height):
        for x in range(frame.width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            lift = 72
            nr = min(255, r + lift)
            ng = min(255, g + lift)
            nb = min(255, b + lift)
            pixels[x, y] = (nr, ng, nb, min(a, alpha))
    return frame


def build_guide(name: str, frame_count: int) -> Image.Image:
    source_path = SOURCE_DIR / f"{name}.png"
    if not source_path.exists():
        raise FileNotFoundError(f"Missing strip: {source_path}")

    source = Image.open(source_path).convert("RGBA")
    width = CELL * frame_count
    canvas = Image.new("RGBA", (width, CELL), (132, 136, 146, 255))
    draw = ImageDraw.Draw(canvas)

    for index in range(frame_count):
        left = index * CELL
        right = left + CELL
        frame = source.crop((left, 0, right, CELL))
        frame = soften_frame(frame)
        canvas.alpha_composite(frame, (left, 0))
        draw.rectangle((left, 0, right - 1, CELL - 1), outline=(64, 88, 122, 255), width=1)
        draw.line((left + CENTER_X, 0, left + CENTER_X, CELL - 1), fill=(78, 155, 255, 170), width=1)
        draw.line((left, BASELINE_Y, right - 1, BASELINE_Y), fill=(255, 92, 92, 190), width=1)
        draw.text((left + 4, 4), f"{index:02d}", fill=(220, 235, 255, 255))

    draw.text((4, CELL - 18), f"{name} guide", fill=(120, 220, 255, 255))
    return canvas


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for name, frame_count in STRIPS:
        guide = build_guide(name, frame_count)
        guide.save(OUTPUT_DIR / f"{name}_guide.png")
    print(OUTPUT_DIR)


if __name__ == "__main__":
    main()
