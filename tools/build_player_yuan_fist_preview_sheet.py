from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
FRAME_ROOT = ROOT / "assets" / "pixel" / "characters" / "player_yuan_runtime" / "frames"
OUTPUT_PATH = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "preview_sheet.png"

ANIMATION_ROWS = [
    ("idle", 12),
    ("run", 8),
    ("jump", 3),
    ("fall", 3),
    ("dash", 5),
    ("hit", 3),
    ("death", 8),
    ("combat_idle", 12),
    ("combat_run", 10),
    ("punch_1", 12),
    ("punch_2", 12),
    ("punch_3", 14),
    ("punch_skill", 14),
]

CELL = 96
PADDING = 16
LABEL_WIDTH = 140
HEADER = 36
ROW_GAP = 14
MAX_COLS = max(frame_count for _name, frame_count in ANIMATION_ROWS)


def build_preview_sheet() -> Path:
    width = LABEL_WIDTH + PADDING * 2 + CELL * MAX_COLS
    height = HEADER + PADDING * 2 + sum(CELL + ROW_GAP for _name, _count in ANIMATION_ROWS) - ROW_GAP
    sheet = Image.new("RGBA", (width, height), (10, 12, 18, 255))
    draw = ImageDraw.Draw(sheet)

    draw.text((PADDING, 8), "Cyber Fist Runtime Preview", fill=(220, 235, 255, 255))

    y = HEADER + PADDING
    for animation_name, frame_count in ANIMATION_ROWS:
        draw.text((PADDING, y + 36), animation_name, fill=(120, 220, 255, 255))
        for index in range(frame_count):
            frame_path = FRAME_ROOT / f"{animation_name}_{index:02d}.png"
            if not frame_path.exists():
                continue
            frame = Image.open(frame_path).convert("RGBA")
            x = LABEL_WIDTH + PADDING + index * CELL
            sheet.alpha_composite(frame, (x, y))
            draw.rectangle((x, y, x + CELL - 1, y + CELL - 1), outline=(38, 55, 80, 255), width=1)
            draw.text((x + 4, y + 4), f"{index:02d}", fill=(200, 210, 230, 255))
        y += CELL + ROW_GAP

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(OUTPUT_PATH)
    return OUTPUT_PATH


if __name__ == "__main__":
    out = build_preview_sheet()
    print(out)
