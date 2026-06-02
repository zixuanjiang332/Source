from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE_FRAME_DIR = ROOT / "assets" / "pixel" / "characters" / "player_yuan_early_clone" / "frames"
SOURCE_STRIP_DIR = ROOT / "art_src" / "generated" / "player_yuan_early_clone" / "strips"
OUTPUT_FRAME_DIR = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "frames"
OUTPUT_STRIP_DIR = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "strips"

CELL_SIZE = 96
FOOT_BASELINE_Y = 92
SOURCE_STRIP_COUNTS = {
    "idle": 6,
    "run": 8,
    "jump": 3,
    "fall": 3,
    "dash": 5,
    "atk_1": 6,
    "atk_2": 6,
    "atk_3": 8,
    "skill": 10,
    "hit": 3,
    "death": 8,
}

FRAME_RULES = {
    "idle": {
        "frames": [
            "idle_00",
            "idle_01",
            "idle_02",
            "idle_03",
            "idle_04",
            "idle_05",
        ],
        "keep_energy": False,
    },
    "run": {
        "frames": [
            "run_00",
            "run_01",
            "run_02",
            "run_03",
            "run_04",
            "run_05",
            "run_06",
            "run_07",
        ],
        "keep_energy": False,
    },
    "jump": {
        "frames": [
            "jump_00",
            "jump_01",
            "jump_02",
        ],
        "keep_energy": False,
    },
    "fall": {
        "frames": [
            "fall_00",
            "fall_01",
            "fall_02",
        ],
        "keep_energy": False,
    },
    "dash": {
        "frames": [
            "dash_00",
            "dash_01",
            "dash_02",
            "dash_03",
            "dash_04",
        ],
        "keep_energy": False,
    },
    "hit": {
        "frames": [
            "hit_00",
            "hit_01",
            "hit_02",
        ],
        "keep_energy": False,
    },
    "death": {
        "frames": [
            "death_00",
            "death_01",
            "death_02",
            "death_03",
            "death_04",
            "death_05",
            "death_06",
            "death_07",
        ],
        "keep_energy": False,
    },
    "combat_idle": {
        "frames": [
            "idle_00",
            "idle_01",
            "idle_02",
            "idle_03",
            "idle_04",
            "idle_05",
            "idle_04",
            "idle_02",
        ],
        "keep_energy": False,
    },
    "combat_run": {
        "frames": [
            "run_00",
            "run_01",
            "run_02",
            "run_03",
            "run_04",
            "run_05",
            "run_06",
            "run_07",
        ],
        "keep_energy": False,
    },
    "punch_1": {
        "frames": [
            "atk_1_00",
            "atk_1_01",
            "atk_1_02",
        "atk_1_03",
            "atk_1_03",
            "atk_1_04",
            "atk_1_05",
            "atk_1_00",
        ],
        "keep_energy": False,
    },
    "punch_2": {
        "frames": [
            "atk_2_00",
            "atk_2_01",
            "atk_2_02",
        "atk_2_03",
            "atk_2_03",
            "atk_2_04",
            "atk_2_05",
            "atk_2_00",
        ],
        "keep_energy": False,
    },
    "punch_3": {
        "frames": [
            "atk_3_00",
            "atk_3_01",
            "atk_3_02",
        "atk_3_03",
        "atk_3_04",
        "atk_3_04",
        "atk_3_05",
            "atk_3_06",
            "atk_3_07",
            "atk_3_07",
        ],
        "keep_energy": False,
    },
    "punch_skill": {
        "frames": [
            "dash_00",
            "dash_01",
            "dash_02",
        "dash_03",
        "dash_04",
        "atk_3_02",
        "atk_3_03",
            "atk_3_04",
            "atk_3_05",
            "atk_3_06",
        ],
        "keep_energy": False,
    },
}


def should_remove_energy(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    brightness = max(r, g, b)
    cool_bias = (b > r + 20 or g > r + 20)
    bright_core = brightness > 95
    pale_white = brightness > 180 and abs(g - b) < 40
    return cool_bias and bright_core or pale_white


def cleanup_frame(image: Image.Image, keep_energy: bool) -> Image.Image:
    image = image.convert("RGBA")
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if not keep_energy and should_remove_energy(r, g, b, a):
                pixels[x, y] = (0, 0, 0, 0)
    remove_tiny_islands(image)
    return image


def normalize_frame(image: Image.Image) -> Image.Image:
    bbox = image.getbbox()
    output = Image.new("RGBA", (CELL_SIZE, CELL_SIZE), (0, 0, 0, 0))
    if bbox is None:
        return output

    cropped = image.crop(bbox)
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


def remove_tiny_islands(image: Image.Image, max_area: int = 6) -> None:
    pixels = image.load()
    visited: set[tuple[int, int]] = set()
    width, height = image.size

    for y in range(height):
        for x in range(width):
            if (x, y) in visited:
                continue
            if pixels[x, y][3] == 0:
                continue

            stack = [(x, y)]
            component: list[tuple[int, int]] = []
            while stack:
                cx, cy = stack.pop()
                if (cx, cy) in visited:
                    continue
                visited.add((cx, cy))
                if cx < 0 or cy < 0 or cx >= width or cy >= height:
                    continue
                if pixels[cx, cy][3] == 0:
                    continue
                component.append((cx, cy))
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if 0 <= nx < width and 0 <= ny < height and (nx, ny) not in visited:
                        stack.append((nx, ny))

            if 0 < len(component) <= max_area:
                for cx, cy in component:
                    pixels[cx, cy] = (0, 0, 0, 0)


def load_frame(frame_name: str, *, keep_energy: bool) -> Image.Image:
    source_path = SOURCE_FRAME_DIR / f"{frame_name}.png"
    if source_path.exists():
        return cleanup_frame(Image.open(source_path), keep_energy=keep_energy)

    animation_name, frame_index_text = frame_name.rsplit("_", 1)
    frame_index = int(frame_index_text)
    frame_count = SOURCE_STRIP_COUNTS[animation_name]
    strip_path = SOURCE_STRIP_DIR / f"{animation_name}.png"
    if not strip_path.exists():
        raise FileNotFoundError(f"Missing source frame and strip: {source_path} / {strip_path}")

    strip = Image.open(strip_path).convert("RGBA")
    cell_width = strip.width / frame_count
    left = round(frame_index * cell_width)
    right = round((frame_index + 1) * cell_width)
    frame = strip.crop((left, 0, right, strip.height))
    return cleanup_frame(frame, keep_energy=keep_energy)


def write_animation_frames(animation_name: str, frame_names: list[str], *, keep_energy: bool) -> list[Path]:
    animation_dir = OUTPUT_FRAME_DIR / animation_name
    animation_dir.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []

    for index, frame_name in enumerate(frame_names):
        image = normalize_frame(load_frame(frame_name, keep_energy=keep_energy))
        output_path = animation_dir / f"frame_{index:02d}.png"
        image.save(output_path)
        written.append(output_path)
    return written


def write_strip(animation_name: str, frame_paths: list[Path]) -> Path:
    strip = Image.new("RGBA", (CELL_SIZE * len(frame_paths), CELL_SIZE), (0, 0, 0, 0))
    for index, frame_path in enumerate(frame_paths):
        frame = Image.open(frame_path).convert("RGBA")
        strip.alpha_composite(frame, (index * CELL_SIZE, 0))
    OUTPUT_STRIP_DIR.mkdir(parents=True, exist_ok=True)
    output_path = OUTPUT_STRIP_DIR / f"{animation_name}.png"
    strip.save(output_path)
    return output_path


def main() -> None:
    generated = 0
    for animation_name, rule in FRAME_RULES.items():
        frame_paths = write_animation_frames(
            animation_name,
            rule["frames"],
            keep_energy=rule["keep_energy"],
        )
        write_strip(animation_name, frame_paths)
        generated += len(frame_paths)

    print(f"Generated transitional fist pass with {generated} frames.")
    print(OUTPUT_STRIP_DIR)


if __name__ == "__main__":
    main()
