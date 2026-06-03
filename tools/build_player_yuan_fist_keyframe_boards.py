from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
FRAME_ROOT = ROOT / "assets" / "pixel" / "characters" / "player_yuan_runtime" / "frames"
OUTPUT_DIR = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "keyframe_boards"

BOARDS = {
    "punch_chain_board": [
        ("punch_1", [1, 3, 5]),
        ("punch_2", [1, 3, 5]),
        ("punch_3", [2, 5, 7]),
    ],
    "punch_skill_board": [
        ("punch_skill", [1, 3, 6, 8]),
    ],
    "combat_mobility_board": [
        ("combat_idle", [0, 3, 6]),
        ("combat_run", [0, 2, 4, 6]),
    ],
}

CELL = 96
SCALE = 3
PAD = 24
LABEL_W = 160
ROW_GAP = 28
TITLE_H = 40


def build_board(name: str, rows: list[tuple[str, list[int]]]) -> Path:
    max_cols = max(len(indices) for _anim, indices in rows)
    width = LABEL_W + PAD * 2 + max_cols * CELL * SCALE
    height = TITLE_H + PAD * 2 + len(rows) * (CELL * SCALE + ROW_GAP) - ROW_GAP
    canvas = Image.new("RGBA", (width, height), (18, 20, 28, 255))
    draw = ImageDraw.Draw(canvas)
    draw.text((PAD, 10), name, fill=(230, 240, 255, 255))

    y = TITLE_H + PAD
    for anim_name, indices in rows:
        draw.text((PAD, y + CELL), anim_name, fill=(120, 220, 255, 255))
        for col, index in enumerate(indices):
            frame_path = FRAME_ROOT / f"{anim_name}_{index:02d}.png"
            if not frame_path.exists():
                continue
            frame = Image.open(frame_path).convert("RGBA")
            frame = frame.resize((CELL * SCALE, CELL * SCALE), Image.Resampling.NEAREST)
            x = LABEL_W + PAD + col * CELL * SCALE
            canvas.alpha_composite(frame, (x, y))
            draw.rectangle((x, y, x + CELL * SCALE - 1, y + CELL * SCALE - 1), outline=(72, 92, 128, 255), width=1)
            draw.text((x + 8, y + 8), f"{index:02d}", fill=(220, 235, 255, 255))
        y += CELL * SCALE + ROW_GAP

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    out = OUTPUT_DIR / f"{name}.png"
    canvas.save(out)
    return out


def main() -> None:
    for board_name, rows in BOARDS.items():
        out = build_board(board_name, rows)
        print(out)


if __name__ == "__main__":
    main()
