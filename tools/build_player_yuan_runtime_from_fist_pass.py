from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]

LEGACY_STRIP_DIR = ROOT / "art_src" / "generated" / "player_yuan_early_clone" / "strips"
FIST_STRIP_DIR = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "strips"
OUTPUT_FRAME_DIR = ROOT / "assets" / "pixel" / "characters" / "player_yuan_runtime" / "frames"
OUTPUT_SHEET_PATH = ROOT / "assets" / "pixel" / "spr_player_yuan_runtime.png"
OUTPUT_RESOURCE_PATH = ROOT / "resources" / "characters" / "player_yuan_runtime_frames.tres"
ULTIMATE_SLAM_PATH = ROOT / "assets" / "pixel" / "characters" / "player_yuan_early_clone" / "spr_player_yuan_ultimate_slam.png"

CELL_SIZE = 96
ATLAS_GUTTER = 2
ATLAS_STRIDE = CELL_SIZE + ATLAS_GUTTER * 2
SHEET_COLUMNS = 10
FOOT_BASELINE_Y = 92
MAX_FRAME_WIDTH = 86
MAX_FRAME_HEIGHT = 88
MIN_COMPONENT_AREA = 18
STABLE_IDLE_HEAD_BOX = (28, 2, 68, 47)

LEGACY_ANIMATIONS = [
    ("idle", 6, 8, True),
    ("run", 8, 12, True),
    ("jump", 3, 10, False),
    ("fall", 3, 10, True),
    ("dash", 5, 18, False),
    ("hit", 3, 12, False),
    ("death", 8, 10, False),
]

FIST_ANIMATIONS = [
    ("combat_idle", 8, 8, True),
    ("combat_run", 8, 12, True),
    ("punch_1", 8, 18, False),
    ("punch_2", 8, 18, False),
    ("punch_3", 10, 16, False),
    ("punch_skill", 10, 16, False),
]

ULTIMATE_ANIMATION = ("ultimate_slam", 8, 16, False)
ALL_ANIMATIONS = LEGACY_ANIMATIONS + FIST_ANIMATIONS + [ULTIMATE_ANIMATION]


def resource_path(path: Path) -> str:
    return "res://" + path.relative_to(ROOT).as_posix()


def expected_strip_paths() -> list[Path]:
    paths: list[Path] = []
    for name, _frame_count, _fps, _loop in LEGACY_ANIMATIONS:
        paths.append(LEGACY_STRIP_DIR / f"{name}.png")
    for name, _frame_count, _fps, _loop in FIST_ANIMATIONS:
        paths.append(FIST_STRIP_DIR / f"{name}.png")
    return paths


def missing_strip_paths() -> list[Path]:
    return [path for path in expected_strip_paths() if not path.exists()]


def is_key_green(r: int, g: int, b: int, a: int) -> bool:
    if a <= 12:
        return True
    if is_cyan_effect_pixel(r, g, b, a):
        return False
    return g >= 120 and g > r * 1.3 and g > b * 1.08


def is_skin_pixel(r: int, g: int, b: int, a: int) -> bool:
    return a > 40 and r > 105 and g > 58 and b > 38 and r > g > b and (r - b) > 35


def is_cyan_effect_pixel(r: int, g: int, b: int, a: int) -> bool:
    return a > 25 and b > 110 and g > 80 and b > r * 1.35


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


def polish_small_sprite(frame: Image.Image) -> Image.Image:
    frame = frame.convert("RGBA")
    pixels = frame.load()
    bbox = frame.getbbox()
    if bbox is None:
        return frame

    skin_points: list[tuple[int, int]] = []
    top_limit = min(CELL_SIZE, bbox[1] + 40)
    for y in range(bbox[1], top_limit):
        for x in range(bbox[0], bbox[2]):
            if is_skin_pixel(*pixels[x, y]):
                skin_points.append((x, y))

    for x, y in skin_points:
        r, g, b, a = pixels[x, y]
        pixels[x, y] = (min(255, r + 24), min(220, g + 16), min(180, b + 8), max(a, 230))
        for nx, ny in ((x + 1, y), (x, y + 1)):
            if 0 <= nx < CELL_SIZE and 0 <= ny < CELL_SIZE:
                nr, ng, nb, na = pixels[nx, ny]
                if na == 0 or (nr + ng + nb) < 110:
                    pixels[nx, ny] = (190, 122, 84, max(na, 165))

    for y in range(CELL_SIZE):
        for x in range(CELL_SIZE):
            r, g, b, a = pixels[x, y]
            if is_cyan_effect_pixel(r, g, b, a):
                pixels[x, y] = (min(r, 55), min(255, g + 26), min(255, b + 34), max(a, 220))

    return frame


def strip_tiny_fragments(image: Image.Image) -> Image.Image:
    image = image.convert("RGBA")
    pixels = image.load()
    visited: set[tuple[int, int]] = set()
    remove_points: list[tuple[int, int]] = []

    for start_y in range(image.height):
        for start_x in range(image.width):
            if (start_x, start_y) in visited:
                continue
            if pixels[start_x, start_y][3] == 0:
                visited.add((start_x, start_y))
                continue

            stack = [(start_x, start_y)]
            component: list[tuple[int, int]] = []
            visited.add((start_x, start_y))
            while stack:
                x, y = stack.pop()
                component.append((x, y))
                for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if nx < 0 or nx >= image.width or ny < 0 or ny >= image.height or (nx, ny) in visited:
                        continue
                    visited.add((nx, ny))
                    if pixels[nx, ny][3] > 0:
                        stack.append((nx, ny))

            if len(component) < MIN_COMPONENT_AREA:
                remove_points.extend(component)

    for x, y in remove_points:
        pixels[x, y] = (0, 0, 0, 0)
    return image


def normalize_frame(source: Image.Image) -> Image.Image:
    keyed = strip_tiny_fragments(remove_chroma_key(source))
    bbox = keyed.getbbox()
    output = Image.new("RGBA", (CELL_SIZE, CELL_SIZE), (0, 0, 0, 0))
    if bbox is None:
        return output

    cropped = keyed.crop(bbox)
    scale = min(MAX_FRAME_WIDTH / cropped.width, MAX_FRAME_HEIGHT / cropped.height, 1.0)
    next_size = (
        max(1, round(cropped.width * scale)),
        max(1, round(cropped.height * scale)),
    )
    resized = cropped.resize(next_size, Image.Resampling.LANCZOS)
    x = (CELL_SIZE - resized.width) // 2
    y = max(0, FOOT_BASELINE_Y - resized.height)
    output.alpha_composite(resized, (x, y))
    return strip_tiny_fragments(polish_small_sprite(output))


def stabilize_head_region(frames: list[Image.Image]) -> list[Image.Image]:
    if not frames:
        return frames

    template = frames[0].convert("RGBA").crop(STABLE_IDLE_HEAD_BOX)
    stabilized: list[Image.Image] = []
    for frame in frames:
        output = frame.convert("RGBA").copy()
        output.paste(
            (0, 0, 0, 0),
            STABLE_IDLE_HEAD_BOX,
        )
        output.alpha_composite(template, STABLE_IDLE_HEAD_BOX[:2])
        stabilized.append(output)
    return stabilized


def read_strip_frames(strip_dir: Path, name: str, frame_count: int) -> list[Image.Image]:
    strip_path = strip_dir / f"{name}.png"
    if not strip_path.exists():
        raise FileNotFoundError(f"Missing strip: {strip_path}")

    strip = Image.open(strip_path).convert("RGBA")
    cell_width = strip.width / frame_count
    frames: list[Image.Image] = []
    for index in range(frame_count):
        left = round(index * cell_width)
        right = round((index + 1) * cell_width)
        frames.append(normalize_frame(strip.crop((left, 0, right, strip.height))))
    return frames


def read_preferred_strip_frames(name: str, frame_count: int) -> list[Image.Image]:
    preferred = FIST_STRIP_DIR / f"{name}.png"
    if preferred.exists():
        return read_strip_frames(FIST_STRIP_DIR, name, frame_count)
    return read_strip_frames(LEGACY_STRIP_DIR, name, frame_count)


def build_frames() -> dict[str, list[Path]]:
    OUTPUT_FRAME_DIR.mkdir(parents=True, exist_ok=True)
    frames_by_animation: dict[str, list[Path]] = {}

    for name, frame_count, _fps, _loop in LEGACY_ANIMATIONS:
        out_paths: list[Path] = []
        for index, frame in enumerate(read_preferred_strip_frames(name, frame_count)):
            out_path = OUTPUT_FRAME_DIR / f"{name}_{index:02d}.png"
            frame.save(out_path)
            out_paths.append(out_path)
        frames_by_animation[name] = out_paths

    for name, frame_count, _fps, _loop in FIST_ANIMATIONS:
        out_paths = []
        frames = read_strip_frames(FIST_STRIP_DIR, name, frame_count)
        if name == "combat_idle":
            frames = stabilize_head_region(frames)
        for index, frame in enumerate(frames):
            out_path = OUTPUT_FRAME_DIR / f"{name}_{index:02d}.png"
            frame.save(out_path)
            out_paths.append(out_path)
        frames_by_animation[name] = out_paths

    return frames_by_animation


def build_sheet(frames_by_animation: dict[str, list[Path]]) -> None:
    OUTPUT_SHEET_PATH.parent.mkdir(parents=True, exist_ok=True)
    rows_without_ultimate = len(ALL_ANIMATIONS) - 1
    sheet = Image.new(
        "RGBA",
        (ATLAS_STRIDE * SHEET_COLUMNS, ATLAS_STRIDE * rows_without_ultimate),
        (0, 0, 0, 0),
    )

    for row, (name, _frame_count, _fps, _loop) in enumerate(LEGACY_ANIMATIONS + FIST_ANIMATIONS):
        for column, frame_path in enumerate(frames_by_animation[name]):
            frame = Image.open(frame_path).convert("RGBA")
            x = column * ATLAS_STRIDE + ATLAS_GUTTER
            y = row * ATLAS_STRIDE + ATLAS_GUTTER
            sheet.alpha_composite(frame, (x, y))

    sheet.save(OUTPUT_SHEET_PATH)


def build_sprite_frames_resource() -> None:
    OUTPUT_RESOURCE_PATH.parent.mkdir(parents=True, exist_ok=True)

    subresources: list[str] = []
    animations: list[str] = []

    packed_rows = LEGACY_ANIMATIONS + FIST_ANIMATIONS
    for row, (name, frame_count, fps, loop) in enumerate(packed_rows):
        frame_entries: list[str] = []
        for column in range(frame_count):
            sub_id = f"AtlasTexture_{name}_{column:02d}"
            x = column * ATLAS_STRIDE + ATLAS_GUTTER
            y = row * ATLAS_STRIDE + ATLAS_GUTTER
            subresources.append(
                "\n".join(
                    [
                        f'[sub_resource type="AtlasTexture" id="{sub_id}"]',
                        'atlas = ExtResource("1_sheet")',
                        f"region = Rect2({x}, {y}, {CELL_SIZE}, {CELL_SIZE})",
                        "filter_clip = true",
                    ]
                )
            )
            frame_entries.append(
                '{\n"duration": 1.0,\n"texture": SubResource("'
                + sub_id
                + '")\n}'
            )

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

    ultimate_name, ultimate_frame_count, ultimate_fps, ultimate_loop = ULTIMATE_ANIMATION
    ultimate_entries: list[str] = []
    for column in range(ultimate_frame_count):
        sub_id = f"AtlasTexture_{ultimate_name}_{column:02d}"
        x = column * CELL_SIZE
        subresources.append(
            "\n".join(
                [
                    f'[sub_resource type="AtlasTexture" id="{sub_id}"]',
                    'atlas = ExtResource("2_ultimate_slam")',
                    f"region = Rect2({x}, 0, {CELL_SIZE}, {CELL_SIZE})",
                    "filter_clip = true",
                ]
            )
        )
        ultimate_entries.append(
            '{\n"duration": 1.0,\n"texture": SubResource("'
            + sub_id
            + '")\n}'
        )

    animations.append(
        "{\n"
        + '"frames": ['
        + ", ".join(ultimate_entries)
        + "],\n"
        + f'"loop": {str(ultimate_loop).lower()},\n'
        + f'"name": &"{ultimate_name}",\n'
        + f'"speed": {float(ultimate_fps):.1f}\n'
        + "}"
    )

    load_steps = 1 + 2 + len(subresources)
    content = [
        f'[gd_resource type="SpriteFrames" load_steps={load_steps} format=3]',
        "",
        f'[ext_resource type="Texture2D" path="{resource_path(OUTPUT_SHEET_PATH)}" id="1_sheet"]',
        f'[ext_resource type="Texture2D" path="{resource_path(ULTIMATE_SLAM_PATH)}" id="2_ultimate_slam"]',
        "",
        "\n\n".join(subresources),
        "",
        "[resource]",
        "animations = [" + ", ".join(animations) + "]",
        "",
    ]
    OUTPUT_RESOURCE_PATH.write_text("\n".join(content), encoding="utf-8", newline="\n")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()

    missing = missing_strip_paths()
    if args.check:
        if missing:
            print("Missing strips:")
            for path in missing:
                print(path.relative_to(ROOT).as_posix())
            raise SystemExit(1)
        print("All required strips are present.")
        return

    if missing:
        print("Missing strips:")
        for path in missing:
            print(path.relative_to(ROOT).as_posix())
        raise SystemExit(1)

    frames = build_frames()
    build_sheet(frames)
    build_sprite_frames_resource()
    total = sum(len(items) for items in frames.values()) + ULTIMATE_ANIMATION[1]
    print(f"Built runtime player set with {total} frames")
    print(resource_path(OUTPUT_SHEET_PATH))
    print(resource_path(OUTPUT_RESOURCE_PATH))


if __name__ == "__main__":
    main()
