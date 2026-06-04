from __future__ import annotations

import csv
from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
FRAME_DIR = ROOT / "assets" / "pixel" / "characters" / "player_yuan_runtime" / "frames"
REPORT_PATH = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "runtime_frame_audit.csv"

PRIMARY_ONLY = {
    "combat_idle",
    "punch_1",
    "punch_2",
    "punch_3",
    "punch_skill",
}

SECONDARY_AREA_THRESHOLD = 20
SUSPECT_AREA_THRESHOLD = 80
SUSPECT_COUNT_THRESHOLD = 2


def is_cyan_effect_pixel(r: int, g: int, b: int, a: int) -> bool:
    return a > 25 and b > 95 and g > 75 and b > r * 1.18


def component_stats(image: Image.Image) -> list[dict[str, int | float]]:
    pixels = image.convert("RGBA").load()
    width, height = image.size
    visited: set[tuple[int, int]] = set()
    stats: list[dict[str, int | float]] = []

    for start_y in range(height):
        for start_x in range(width):
            if (start_x, start_y) in visited:
                continue
            visited.add((start_x, start_y))
            if pixels[start_x, start_y][3] == 0:
                continue

            queue = deque([(start_x, start_y)])
            area = 1
            cyan = 1 if is_cyan_effect_pixel(*pixels[start_x, start_y]) else 0
            while queue:
                x, y = queue.popleft()
                for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if nx < 0 or nx >= width or ny < 0 or ny >= height or (nx, ny) in visited:
                        continue
                    visited.add((nx, ny))
                    if pixels[nx, ny][3] > 0:
                        queue.append((nx, ny))
                        area += 1
                        if is_cyan_effect_pixel(*pixels[nx, ny]):
                            cyan += 1

            stats.append({"area": area, "cyan_ratio": cyan / max(1, area)})

    return sorted(stats, key=lambda item: int(item["area"]), reverse=True)


def audit_rows() -> list[dict[str, str | int]]:
    rows: list[dict[str, str | int]] = []
    for path in sorted(FRAME_DIR.glob("*.png")):
        anim = "_".join(path.stem.split("_")[:-1])
        stats = component_stats(Image.open(path))
        areas = [int(item["area"]) for item in stats]
        big_parts = [area for area in areas[1:] if area >= SECONDARY_AREA_THRESHOLD]
        non_cyan_suspect_parts = [
            item
            for item in stats[1:]
            if int(item["area"]) >= SUSPECT_AREA_THRESHOLD and float(item["cyan_ratio"]) < 0.25
        ]
        suspect = (
            anim in PRIMARY_ONLY
            and len(non_cyan_suspect_parts) >= SUSPECT_COUNT_THRESHOLD
        )
        rows.append(
            {
                "frame": path.name,
                "animation": anim,
                "largest_area": areas[0] if areas else 0,
                "secondary_count_ge20": len(big_parts),
                "secondary_areas": " ".join(str(area) for area in big_parts[:8]),
                "suspect": "yes" if suspect else "",
            }
        )
    return rows


def main() -> None:
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    rows = audit_rows()
    with REPORT_PATH.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["frame", "animation", "largest_area", "secondary_count_ge20", "secondary_areas", "suspect"],
        )
        writer.writeheader()
        writer.writerows(rows)

    suspects = [row for row in rows if row["suspect"] == "yes"]
    print(REPORT_PATH)
    print(f"Frames audited: {len(rows)}")
    print(f"Suspect frames: {len(suspects)}")
    for row in suspects[:40]:
        print(f"{row['frame']}: {row['secondary_areas']}")


if __name__ == "__main__":
    main()
