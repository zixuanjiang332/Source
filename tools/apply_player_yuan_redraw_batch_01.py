from __future__ import annotations

import argparse
import shutil
import subprocess
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
STRIP_DIR = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "strips"
REDRAW_BATCH_ROOT = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "redraw_batches"
BACKUP_ROOT = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "backups"
BUILD_SCRIPT = ROOT / "tools" / "build_player_yuan_runtime_from_fist_pass.py"
DEPLOY_SCRIPT = ROOT / "tools" / "deploy_player_yuan_fist_pass.ps1"

CELL = 96

BATCH_CONFIGS = {
    "batch_01": {
        "punch_1": [1, 3, 5],
        "punch_2": [1, 3, 5],
        "punch_3": [2, 5, 7],
    },
    "batch_02": {
        "punch_skill": [1, 3, 6, 8],
    },
    "batch_03": {
        "combat_idle": [0, 3, 6],
        "combat_run": [0, 2, 4, 6],
        "punch_1": [4],
        "punch_2": [4],
        "punch_3": [5],
    },
    "batch_04": {
        "punch_1": [4],
        "punch_2": [4],
        "punch_3": [5],
        "punch_skill": [6],
    },
    "batch_05": {
        "punch_1": [1, 2, 3, 4, 5],
        "punch_2": [1, 2, 3, 4, 5],
        "punch_3": [1, 2, 3, 4, 5, 6, 7],
    },
}

CLEAR_CELL_BATCHES = {"batch_05"}


def selected_batch_map(batch_name: str, animations: list[str] | None) -> dict[str, list[int]]:
    batch_map = BATCH_CONFIGS[batch_name]
    if not animations:
        return batch_map
    return {name: batch_map[name] for name in animations}


def expected_replacements(batch_name: str, batch_map: dict[str, list[int]]) -> list[Path]:
    paths: list[Path] = []
    for anim, indices in batch_map.items():
        for index in indices:
            paths.append(REDRAW_BATCH_ROOT / batch_name / anim / f"frame_{index:02d}.png")
    return paths


def missing_replacements(batch_name: str, batch_map: dict[str, list[int]]) -> list[Path]:
    return [path for path in expected_replacements(batch_name, batch_map) if not path.exists()]


def ensure_backups(batch_name: str, batch_map: dict[str, list[int]]) -> None:
    backup_dir = BACKUP_ROOT / batch_name
    backup_dir.mkdir(parents=True, exist_ok=True)
    for anim in batch_map:
        source = STRIP_DIR / f"{anim}.png"
        backup = backup_dir / f"{anim}.png"
        if source.exists() and not backup.exists():
            shutil.copy2(source, backup)


def apply_replacements(batch_name: str, batch_map: dict[str, list[int]]) -> None:
    ensure_backups(batch_name, batch_map)
    for anim, indices in batch_map.items():
        strip_path = STRIP_DIR / f"{anim}.png"
        if not strip_path.exists():
            raise FileNotFoundError(f"Missing strip: {strip_path}")

        strip = Image.open(strip_path).convert("RGBA")
        for index in indices:
            replacement_path = REDRAW_BATCH_ROOT / batch_name / anim / f"frame_{index:02d}.png"
            if not replacement_path.exists():
                raise FileNotFoundError(f"Missing replacement: {replacement_path}")
            replacement = Image.open(replacement_path).convert("RGBA")
            if replacement.size != (CELL, CELL):
                raise ValueError(f"{replacement_path} must be 96x96, got {replacement.size}")
            if batch_name in CLEAR_CELL_BATCHES:
                strip.paste((0, 0, 0, 0), (index * CELL, 0, (index + 1) * CELL, CELL))
            strip.alpha_composite(replacement, (index * CELL, 0))
        strip.save(strip_path)
        print(f"Applied {batch_name} replacements to {strip_path.relative_to(ROOT).as_posix()}")


def run_deploy() -> None:
    subprocess.run(["python", str(BUILD_SCRIPT)], check=True, cwd=ROOT)
    subprocess.run(
        ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(DEPLOY_SCRIPT)],
        check=True,
        cwd=ROOT,
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--batch", default="batch_01", choices=sorted(BATCH_CONFIGS.keys()))
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--deploy", action="store_true")
    parser.add_argument(
        "--animations",
        nargs="*",
        choices=sorted({name for batch in BATCH_CONFIGS.values() for name in batch.keys()}),
    )
    args = parser.parse_args()

    batch_map = selected_batch_map(args.batch, args.animations)
    missing = missing_replacements(args.batch, batch_map)
    if args.check:
        if missing:
            print(f"Missing {args.batch} replacements:")
            for path in missing:
                print(path.relative_to(ROOT).as_posix())
            raise SystemExit(1)
        print(f"{args.batch} replacements are complete.")
        return

    if missing:
        print(f"Missing {args.batch} replacements:")
        for path in missing:
            print(path.relative_to(ROOT).as_posix())
        raise SystemExit(1)

    apply_replacements(args.batch, batch_map)
    if args.deploy:
        run_deploy()


if __name__ == "__main__":
    main()
