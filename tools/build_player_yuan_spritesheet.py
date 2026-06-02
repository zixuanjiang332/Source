from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
STRIP_DIR = ROOT / "art_src" / "generated" / "player_yuan_early_clone" / "strips"
FRAME_DIR = ROOT / "assets" / "pixel" / "characters" / "player_yuan_early_clone" / "frames"
SHEET_PATH = ROOT / "assets" / "pixel" / "spr_player_yuan_early_clone.png"
SPRITE_FRAMES_PATH = ROOT / "resources" / "characters" / "player_yuan_early_clone_frames.tres"

CELL_SIZE = 96
SHEET_COLUMNS = 10
FOOT_BASELINE_Y = 92

ANIMATIONS = [
    ("idle", 6, 8, True),
    ("run", 8, 12, True),
    ("jump", 3, 10, False),
    ("fall", 3, 10, True),
    ("dash", 5, 18, False),
    ("atk_1", 6, 18, False),
    ("atk_2", 6, 18, False),
    ("atk_3", 8, 16, False),
    ("skill", 10, 14, False),
    ("hit", 3, 12, False),
    ("death", 8, 10, False),
]


def is_key_green(r: int, g: int, b: int, a: int) -> bool:
    if a <= 12:
        return True
    return g >= 120 and g > r * 1.3 and g > b * 1.08


def remove_chroma_key(image: Image.Image) -> Image.Image:
    image = image.convert("RGBA")
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if is_key_green(r, g, b, a):
                pixels[x, y] = (0, 0, 0, 0)
            elif g > r and g > b:
                pixels[x, y] = (r, min(g, max(r, b) + 45), b, a)
    return image


def normalize_frame(source: Image.Image) -> Image.Image:
    keyed = remove_chroma_key(source)
    bbox = keyed.getbbox()
    output = Image.new("RGBA", (CELL_SIZE, CELL_SIZE), (0, 0, 0, 0))
    if bbox is None:
        return output

    cropped = keyed.crop(bbox)
    max_width = 90
    max_height = 90
    scale = min(max_width / cropped.width, max_height / cropped.height, 1.0)
    next_size = (
        max(1, round(cropped.width * scale)),
        max(1, round(cropped.height * scale)),
    )
    resized = cropped.resize(next_size, Image.Resampling.LANCZOS)
    x = (CELL_SIZE - resized.width) // 2
    y = max(0, FOOT_BASELINE_Y - resized.height)
    output.alpha_composite(resized, (x, y))
    return output


def build_frames() -> dict[str, list[Path]]:
    FRAME_DIR.mkdir(parents=True, exist_ok=True)
    frames_by_animation: dict[str, list[Path]] = {}

    for name, frame_count, _fps, _loop in ANIMATIONS:
        strip_path = STRIP_DIR / f"{name}.png"
        if not strip_path.exists():
            raise FileNotFoundError(f"Missing strip: {strip_path}")

        strip = Image.open(strip_path).convert("RGBA")
        cell_width = strip.width / frame_count
        animation_frames: list[Path] = []

        for index in range(frame_count):
            left = round(index * cell_width)
            right = round((index + 1) * cell_width)
            frame = normalize_frame(strip.crop((left, 0, right, strip.height)))
            out_path = FRAME_DIR / f"{name}_{index:02d}.png"
            frame.save(out_path)
            animation_frames.append(out_path)

        frames_by_animation[name] = animation_frames

    return frames_by_animation


def build_sheet(frames_by_animation: dict[str, list[Path]]) -> None:
    SHEET_PATH.parent.mkdir(parents=True, exist_ok=True)
    sheet = Image.new(
        "RGBA",
        (CELL_SIZE * SHEET_COLUMNS, CELL_SIZE * len(ANIMATIONS)),
        (0, 0, 0, 0),
    )

    for row, (name, _frame_count, _fps, _loop) in enumerate(ANIMATIONS):
        for column, frame_path in enumerate(frames_by_animation[name]):
            frame = Image.open(frame_path).convert("RGBA")
            sheet.alpha_composite(frame, (column * CELL_SIZE, row * CELL_SIZE))

    sheet.save(SHEET_PATH)


def resource_path(path: Path) -> str:
    return "res://" + path.relative_to(ROOT).as_posix()


def build_sprite_frames_resource() -> None:
    SPRITE_FRAMES_PATH.parent.mkdir(parents=True, exist_ok=True)

    subresources: list[str] = []
    animations: list[str] = []
    subresource_index = 1

    for row, (name, frame_count, fps, loop) in enumerate(ANIMATIONS):
        frame_entries: list[str] = []
        for column in range(frame_count):
            sub_id = f"AtlasTexture_{name}_{column:02d}"
            x = column * CELL_SIZE
            y = row * CELL_SIZE
            subresources.append(
                "\n".join(
                    [
                        f'[sub_resource type="AtlasTexture" id="{sub_id}"]',
                        'atlas = ExtResource("1_sheet")',
                        f"region = Rect2({x}, {y}, {CELL_SIZE}, {CELL_SIZE})",
                    ]
                )
            )
            frame_entries.append(
                '{\n"duration": 1.0,\n"texture": SubResource("'
                + sub_id
                + '")\n}'
            )
            subresource_index += 1

        animations.append(
            "{\n"
            + '"frames": ['
            + ", ".join(frame_entries)
            + "],\n"
            + f'"loop": {str(loop).lower()},\n'
            + f'"name": &"{name}",\n'
            + f'"speed": {float(fps):.1f}\n'
            + "}"
        )

    load_steps = 1 + len(subresources) + 1
    content = [
        f'[gd_resource type="SpriteFrames" load_steps={load_steps} format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{resource_path(SHEET_PATH)}" id="1_sheet"]',
        "",
        "\n\n".join(subresources),
        "",
        "[resource]",
        "animations = [" + ", ".join(animations) + "]",
        "",
    ]
    SPRITE_FRAMES_PATH.write_text("\n".join(content), encoding="utf-8", newline="\n")


def main() -> None:
    frames = build_frames()
    build_sheet(frames)
    build_sprite_frames_resource()
    total = sum(len(items) for items in frames.values())
    print(f"Built {total} frames")
    print(resource_path(SHEET_PATH))
    print(resource_path(SPRITE_FRAMES_PATH))


if __name__ == "__main__":
    main()
