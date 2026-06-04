from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "templates"

CELL = 96
BASELINE_Y = 92
CENTER_X = 48

TEMPLATES = [
    ("idle", 12),
    ("run", 8),
    ("jump", 3),
    ("fall", 3),
    ("dash", 5),
    ("hit", 3),
    ("death", 8),
    ("combat_idle", 12),
    ("combat_run", 8),
    ("punch_1", 8),
    ("punch_2", 8),
    ("punch_3", 10),
    ("punch_skill", 10),
]


def build_template(name: str, frame_count: int) -> Image.Image:
    width = CELL * frame_count
    height = CELL
    image = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    for index in range(frame_count):
        x = index * CELL
        # frame bounds
        draw.rectangle((x, 0, x + CELL - 1, CELL - 1), outline=(64, 88, 122, 255), width=1)
        # center line
        draw.line((x + CENTER_X, 0, x + CENTER_X, CELL - 1), fill=(78, 155, 255, 160), width=1)
        # baseline
        draw.line((x, BASELINE_Y, x + CELL - 1, BASELINE_Y), fill=(255, 92, 92, 180), width=1)
        # frame number
        draw.text((x + 4, 4), f"{index:02d}", fill=(210, 225, 245, 255))

    draw.text((4, CELL - 18), name, fill=(120, 220, 255, 255))
    return image


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for name, frame_count in TEMPLATES:
        image = build_template(name, frame_count)
        out = OUTPUT_DIR / f"{name}_template.png"
        image.save(out)
    print(OUTPUT_DIR)


if __name__ == "__main__":
    main()
