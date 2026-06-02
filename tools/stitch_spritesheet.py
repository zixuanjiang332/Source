#!/usr/bin/env python3
from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT / "art_src" / "generated_frames" / "background" / "lab"
AI_SOURCE_ROOT = SOURCE_ROOT / "_source"
OUTPUT_ROOT = ROOT / "assets" / "pixel" / "background" / "lab"


@dataclass(frozen=True)
class AnimatedAsset:
    asset_id: str
    frame_width: int
    frame_height: int
    frame_count: int


STATIC_ASSETS = {
    "bg_lab_wall_tiles": (256, 128),
    "bg_lab_floor_tiles": (256, 64),
}

ANIMATED_ASSETS = [
    AnimatedAsset("prop_lab_med_bed_glow", 128, 64, 8),
    AnimatedAsset("prop_lab_tank_liquid", 96, 128, 8),
    AnimatedAsset("prop_lab_terminal_scan", 64, 48, 6),
    AnimatedAsset("prop_lab_warning_light", 32, 32, 6),
    AnimatedAsset("prop_lab_cable_spark", 64, 32, 6),
    AnimatedAsset("prop_lab_elevator_pulse", 96, 160, 8),
    AnimatedAsset("prop_lab_mech_arm_idle", 96, 96, 8),
    AnimatedAsset("prop_lab_floor_light_strip", 128, 16, 8),
]


def main() -> int:
    parser = argparse.ArgumentParser(description="Build lab background spritesheets from AI frame boards.")
    parser.add_argument("--process-lab", action="store_true", help="Crop AI source boards into frames and runtime sheets.")
    parser.add_argument("--check", action="store_true", help="Validate expected runtime sheet sizes.")
    args = parser.parse_args()

    if args.process_lab:
        process_lab_assets()
    if args.check:
        check_lab_assets()
    if not args.process_lab and not args.check:
        parser.error("Specify --process-lab, --check, or both.")
    return 0


def process_lab_assets() -> None:
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
    SOURCE_ROOT.mkdir(parents=True, exist_ok=True)
    _process_static_tiles()
    for asset in ANIMATED_ASSETS:
        _process_animated_asset(asset)


def _process_static_tiles() -> None:
    for asset_id, size in STATIC_ASSETS.items():
        source = _source_path(asset_id)
        image = Image.open(source).convert("RGBA")
        fitted = _fit_cover(image, size)
        fitted.save(OUTPUT_ROOT / f"{asset_id}.png")


def _process_animated_asset(asset: AnimatedAsset) -> None:
    source = Image.open(_source_path(asset.asset_id)).convert("RGBA")
    frame_dir = SOURCE_ROOT / asset.asset_id
    frame_dir.mkdir(parents=True, exist_ok=True)

    frames: list[Image.Image] = []
    segment_width = source.width / asset.frame_count
    for index in range(asset.frame_count):
        left = round(index * segment_width)
        right = round((index + 1) * segment_width)
        segment = source.crop((left, 0, right, source.height))
        frame = _extract_chroma_subject(segment, (asset.frame_width, asset.frame_height))
        frame.save(frame_dir / f"frame_{index:03d}.png")
        frames.append(frame)

    sheet = Image.new("RGBA", (asset.frame_width * asset.frame_count, asset.frame_height), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        sheet.alpha_composite(frame, (index * asset.frame_width, 0))
    sheet.save(OUTPUT_ROOT / f"{asset.asset_id}.png")


def _source_path(asset_id: str) -> Path:
    path = AI_SOURCE_ROOT / f"{asset_id}_ai_source.png"
    if not path.exists():
        raise FileNotFoundError(f"Missing AI source image: {path}")
    return path


def _extract_chroma_subject(image: Image.Image, target_size: tuple[int, int]) -> Image.Image:
    keyed = _remove_green_key(image)
    bbox = keyed.getbbox()
    if bbox is None:
        return Image.new("RGBA", target_size, (0, 0, 0, 0))

    subject = keyed.crop(bbox)
    return _fit_inside(subject, target_size)


def _remove_green_key(image: Image.Image) -> Image.Image:
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if g > 130 and g > r * 1.35 and g > b * 1.35:
                pixels[x, y] = (r, g, b, 0)
    return image


def _fit_inside(image: Image.Image, target_size: tuple[int, int]) -> Image.Image:
    target_width, target_height = target_size
    scale = min(target_width / image.width, target_height / image.height)
    new_size = (
        max(1, min(target_width, round(image.width * scale))),
        max(1, min(target_height, round(image.height * scale))),
    )
    resized = image.resize(new_size, Image.Resampling.NEAREST)
    output = Image.new("RGBA", target_size, (0, 0, 0, 0))
    offset = ((target_width - new_size[0]) // 2, (target_height - new_size[1]) // 2)
    output.alpha_composite(resized, offset)
    return output


def _fit_cover(image: Image.Image, target_size: tuple[int, int]) -> Image.Image:
    target_width, target_height = target_size
    scale = max(target_width / image.width, target_height / image.height)
    new_size = (round(image.width * scale), round(image.height * scale))
    resized = image.resize(new_size, Image.Resampling.NEAREST)
    left = max(0, (new_size[0] - target_width) // 2)
    top = max(0, (new_size[1] - target_height) // 2)
    return resized.crop((left, top, left + target_width, top + target_height))


def check_lab_assets() -> None:
    for asset_id, size in STATIC_ASSETS.items():
        _check_image(OUTPUT_ROOT / f"{asset_id}.png", size)

    for asset in ANIMATED_ASSETS:
        sheet_size = (asset.frame_width * asset.frame_count, asset.frame_height)
        _check_image(OUTPUT_ROOT / f"{asset.asset_id}.png", sheet_size)
        frame_dir = SOURCE_ROOT / asset.asset_id
        for index in range(asset.frame_count):
            _check_image(frame_dir / f"frame_{index:03d}.png", (asset.frame_width, asset.frame_height))


def _check_image(path: Path, expected_size: tuple[int, int]) -> None:
    if not path.exists():
        raise FileNotFoundError(f"Missing generated image: {path}")
    with Image.open(path) as image:
        if image.size != expected_size:
            raise ValueError(f"{path} has size {image.size}, expected {expected_size}")


if __name__ == "__main__":
    raise SystemExit(main())
