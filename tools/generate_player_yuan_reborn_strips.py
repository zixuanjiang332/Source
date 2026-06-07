from __future__ import annotations

from dataclasses import dataclass, replace
from math import floor
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
STRIP_DIR = ROOT / "art_src" / "generated" / "player_yuan_fist_pass" / "strips"

CELL = 96
SCALE = 4

OUTLINE = (3, 6, 12, 255)
DEEP = (3, 5, 10, 255)
COAT = (5, 7, 12, 255)
COAT_LIT = (18, 20, 28, 255)
PANEL = (8, 10, 16, 255)
PANEL_LIT = (32, 37, 48, 255)
CYAN = (48, 224, 255, 255)
CYAN_DIM = (24, 118, 150, 190)
SKIN = (220, 146, 105, 255)
SKIN_SHADE = (145, 82, 61, 255)
HAIR = (13, 14, 20, 255)
HAIR_LIT = (55, 62, 84, 255)
BOOT = (7, 9, 14, 255)

ANIMATIONS = [
    ("idle", 6, True),
    ("run", 8, True),
    ("jump", 3, False),
    ("fall", 3, False),
    ("dash", 5, False),
    ("hit", 3, False),
    ("death", 8, False),
    ("combat_idle", 8, True),
    ("combat_run", 10, True),
    ("punch_1", 12, False),
    ("punch_2", 12, False),
    ("punch_3", 14, False),
    ("punch_skill", 14, False),
]


@dataclass(frozen=True)
class Pose:
    pelvis: tuple[float, float]
    chest: tuple[float, float]
    head: tuple[float, float]
    left_hand: tuple[float, float]
    right_hand: tuple[float, float]
    left_foot: tuple[float, float]
    right_foot: tuple[float, float]
    left_elbow: tuple[float, float] | None = None
    right_elbow: tuple[float, float] | None = None
    left_knee: tuple[float, float] | None = None
    right_knee: tuple[float, float] | None = None
    facing: float = 1.0
    coat_swing: float = 0.0
    glow: float = 0.35
    speed: float = 0.0
    impact: float = 0.0
    crouch: float = 0.0
    hurt: float = 0.0


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def lerp_point(a: tuple[float, float], b: tuple[float, float], t: float) -> tuple[float, float]:
    return (lerp(a[0], b[0], t), lerp(a[1], b[1], t))


def maybe_point(a: tuple[float, float] | None, b: tuple[float, float] | None, t: float) -> tuple[float, float] | None:
    if a is None and b is None:
        return None
    if a is None:
        return b
    if b is None:
        return a
    return lerp_point(a, b, t)


def lerp_pose(a: Pose, b: Pose, t: float) -> Pose:
    return Pose(
        pelvis=lerp_point(a.pelvis, b.pelvis, t),
        chest=lerp_point(a.chest, b.chest, t),
        head=lerp_point(a.head, b.head, t),
        left_hand=lerp_point(a.left_hand, b.left_hand, t),
        right_hand=lerp_point(a.right_hand, b.right_hand, t),
        left_foot=lerp_point(a.left_foot, b.left_foot, t),
        right_foot=lerp_point(a.right_foot, b.right_foot, t),
        left_elbow=maybe_point(a.left_elbow, b.left_elbow, t),
        right_elbow=maybe_point(a.right_elbow, b.right_elbow, t),
        left_knee=maybe_point(a.left_knee, b.left_knee, t),
        right_knee=maybe_point(a.right_knee, b.right_knee, t),
        facing=lerp(a.facing, b.facing, t),
        coat_swing=lerp(a.coat_swing, b.coat_swing, t),
        glow=lerp(a.glow, b.glow, t),
        speed=lerp(a.speed, b.speed, t),
        impact=lerp(a.impact, b.impact, t),
        crouch=lerp(a.crouch, b.crouch, t),
        hurt=lerp(a.hurt, b.hurt, t),
    )


def shifted(pose: Pose, dx: float = 0.0, dy: float = 0.0, **updates) -> Pose:
    def move(point: tuple[float, float] | None) -> tuple[float, float] | None:
        if point is None:
            return None
        return (point[0] + dx, point[1] + dy)

    values = {
        "pelvis": move(pose.pelvis),
        "chest": move(pose.chest),
        "head": move(pose.head),
        "left_hand": move(pose.left_hand),
        "right_hand": move(pose.right_hand),
        "left_foot": move(pose.left_foot),
        "right_foot": move(pose.right_foot),
        "left_elbow": move(pose.left_elbow),
        "right_elbow": move(pose.right_elbow),
        "left_knee": move(pose.left_knee),
        "right_knee": move(pose.right_knee),
    }
    values.update(updates)
    return replace(pose, **values)


BASE = Pose(
    pelvis=(48, 73),
    chest=(50, 54),
    head=(53, 34),
    left_elbow=(39, 63),
    left_hand=(37, 75),
    right_elbow=(60, 62),
    right_hand=(63, 74),
    left_knee=(44, 80),
    left_foot=(41, 90),
    right_knee=(55, 79),
    right_foot=(59, 90),
    coat_swing=0.1,
    glow=0.45,
)

GUARD = Pose(
    pelvis=(48, 73),
    chest=(50, 54),
    head=(53, 34),
    left_elbow=(39, 63),
    left_hand=(37, 75),
    right_elbow=(60, 62),
    right_hand=(63, 74),
    left_knee=(44, 82),
    left_foot=(40, 90),
    right_knee=(55, 81),
    right_foot=(60, 90),
    coat_swing=0.1,
    glow=0.52,
    crouch=0.0,
)


def sample_sequence(keys: list[Pose], frame_count: int, loop: bool) -> list[Pose]:
    if len(keys) == 1:
        return [keys[0] for _ in range(frame_count)]
    samples = []
    segment_count = len(keys) if loop else len(keys) - 1
    for index in range(frame_count):
        position = segment_count * index / (frame_count if loop else max(1, frame_count - 1))
        segment = floor(position)
        t = position - segment
        start = keys[segment % len(keys)]
        end = keys[(segment + 1) % len(keys)] if loop else keys[min(segment + 1, len(keys) - 1)]
        samples.append(lerp_pose(start, end, t))
    return samples


def animation_keys() -> dict[str, list[Pose]]:
    return {
        "idle": [
            BASE,
            shifted(BASE, dy=0.8, chest=(50, 55.0), head=(53, 35.0), left_hand=(37, 75.8), right_hand=(63, 74.8), glow=0.55, coat_swing=0.28),
            shifted(BASE, dy=-0.4, chest=(49.7, 53.5), head=(52.7, 33.6), left_hand=(36.8, 74.5), right_hand=(62.7, 73.8), glow=0.35, coat_swing=-0.12),
        ],
        "run": [
            Pose((46, 74), (50, 56), (54, 38), (35, 68), (67, 61), (37, 90), (59, 84), (39, 58), (60, 54), (42, 79), (55, 75), speed=0.3, coat_swing=0.8, glow=0.45),
            Pose((49, 73), (53, 55), (57, 37), (38, 66), (68, 64), (43, 90), (56, 82), (42, 57), (61, 55), (47, 80), (54, 74), speed=0.2, coat_swing=0.3, glow=0.38),
            Pose((51, 72), (55, 54), (59, 36), (42, 64), (70, 68), (50, 84), (58, 90), (45, 56), (62, 57), (49, 78), (54, 80), speed=0.4, coat_swing=-0.55, glow=0.52),
            Pose((48, 73), (52, 55), (56, 37), (38, 66), (67, 62), (40, 84), (60, 90), (42, 57), (60, 54), (46, 76), (55, 80), speed=0.25, coat_swing=0.1, glow=0.42),
        ],
        "jump": [
            shifted(BASE, dy=-3, chest=(51, 52), head=(54, 34), left_foot=(43, 84), right_foot=(59, 83), right_hand=(67, 61), coat_swing=0.8, glow=0.55),
            shifted(BASE, dx=3, dy=-12, chest=(54, 46), head=(58, 28), left_knee=(48, 68), left_foot=(45, 77), right_knee=(59, 67), right_foot=(63, 76), left_hand=(41, 62), right_hand=(70, 56), coat_swing=0.45, glow=0.7),
            shifted(BASE, dx=4, dy=-10, chest=(55, 49), head=(59, 31), left_foot=(47, 80), right_foot=(62, 78), left_hand=(42, 64), right_hand=(69, 58), coat_swing=-0.25, glow=0.55),
        ],
        "fall": [
            shifted(BASE, dx=3, dy=-9, chest=(54, 49), head=(58, 31), left_foot=(45, 80), right_foot=(62, 82), left_hand=(42, 66), right_hand=(69, 62), coat_swing=0.65, glow=0.5),
            shifted(BASE, dx=2, dy=-3, chest=(52, 56), head=(56, 38), left_foot=(43, 88), right_foot=(59, 89), coat_swing=0.15, glow=0.42),
            shifted(BASE, dy=1, chest=(50, 59), head=(53, 42), left_foot=(41, 90), right_foot=(59, 90), coat_swing=-0.2, glow=0.35),
        ],
        "dash": [
            Pose((48, 76), (54, 59), (59, 40), (41, 68), (74, 58), (38, 90), (62, 85), (47, 61), (64, 55), (44, 82), (58, 77), speed=0.75, glow=0.8, coat_swing=1.2),
            Pose((53, 75), (60, 57), (65, 38), (45, 67), (82, 57), (43, 90), (68, 84), (51, 60), (70, 54), (49, 81), (64, 76), speed=1.0, impact=0.15, glow=0.95, coat_swing=0.8),
            Pose((58, 74), (66, 56), (71, 37), (50, 67), (88, 58), (48, 90), (73, 84), (56, 60), (76, 54), (54, 81), (69, 76), speed=1.0, impact=0.3, glow=1.0, coat_swing=0.2),
            Pose((54, 75), (61, 57), (66, 38), (46, 68), (80, 60), (44, 90), (68, 85), (52, 60), (70, 55), (50, 81), (64, 77), speed=0.7, glow=0.8, coat_swing=-0.2),
            shifted(GUARD, dx=1, glow=0.55, coat_swing=-0.35),
        ],
        "hit": [
            shifted(BASE, dx=-1, chest=(48, 57), head=(50, 38), left_hand=(34, 70), right_hand=(62, 70), glow=0.8, hurt=0.45, coat_swing=0.5),
            shifted(BASE, dx=-5, dy=1, chest=(44, 60), head=(45, 41), left_hand=(31, 73), right_hand=(58, 74), left_foot=(38, 90), right_foot=(53, 90), glow=1.0, hurt=1.0, coat_swing=0.9),
            shifted(BASE, dx=-2, chest=(47, 58), head=(49, 39), left_hand=(34, 71), right_hand=(61, 72), glow=0.55, hurt=0.2, coat_swing=0.2),
        ],
        "death": [
            BASE,
            shifted(BASE, dx=-1, dy=2, chest=(48, 61), head=(50, 43), left_hand=(33, 75), right_hand=(62, 76), glow=0.3, coat_swing=0.9),
            Pose((44, 80), (45, 68), (45, 51), (31, 82), (58, 81), (35, 91), (55, 91), (36, 72), (53, 72), (39, 86), (50, 86), glow=0.2, coat_swing=0.5),
            Pose((39, 84), (38, 73), (37, 60), (27, 86), (54, 84), (29, 91), (52, 91), (31, 77), (49, 77), (35, 88), (47, 88), glow=0.12, coat_swing=0.1),
            Pose((34, 86), (31, 76), (28, 67), (23, 88), (49, 85), (24, 91), (49, 91), (27, 81), (45, 79), (31, 89), (43, 88), glow=0.05, coat_swing=-0.2),
            Pose((30, 87), (26, 77), (23, 69), (21, 89), (44, 86), (21, 91), (46, 91), (24, 82), (41, 80), (28, 89), (40, 88), glow=0.0, coat_swing=-0.35),
            Pose((28, 87), (23, 77), (20, 70), (20, 89), (40, 86), (20, 91), (44, 91), (22, 82), (38, 80), (26, 89), (38, 88), glow=0.0, coat_swing=-0.35),
            Pose((27, 87), (22, 77), (19, 70), (19, 89), (39, 86), (19, 91), (43, 91), (21, 82), (37, 80), (25, 89), (37, 88), glow=0.0, coat_swing=-0.35),
        ],
        "combat_idle": [
            GUARD,
            shifted(GUARD, dy=0.8, chest=(50.4, 55.0), head=(53.4, 35.0), left_hand=(37.2, 75.8), right_hand=(63.4, 74.7), glow=0.66, coat_swing=0.36),
            shifted(GUARD, dy=-0.5, chest=(49.6, 53.5), head=(52.6, 33.6), left_hand=(36.7, 74.4), right_hand=(62.8, 73.7), glow=0.45, coat_swing=0.02),
            shifted(GUARD, dx=0.4, chest=(50.4, 54.2), head=(53.4, 34.1), left_hand=(37.4, 75.0), right_hand=(63.4, 74.2), glow=0.58, coat_swing=-0.12),
        ],
        "combat_run": [
            Pose((47, 76), (52, 59), (56, 41), (37, 65), (70, 60), (38, 90), (61, 84), (41, 57), (63, 54), (43, 82), (57, 77), speed=0.35, crouch=1.0, coat_swing=0.9, glow=0.6),
            Pose((50, 75), (55, 58), (59, 40), (40, 64), (71, 63), (44, 90), (58, 82), (44, 56), (64, 55), (48, 82), (55, 75), speed=0.25, crouch=0.8, coat_swing=0.35, glow=0.5),
            Pose((52, 74), (57, 57), (61, 39), (43, 63), (73, 67), (50, 85), (59, 90), (47, 55), (65, 57), (50, 80), (55, 80), speed=0.45, crouch=0.65, coat_swing=-0.55, glow=0.68),
            Pose((49, 75), (54, 58), (58, 40), (39, 64), (70, 61), (41, 84), (61, 90), (43, 56), (63, 54), (47, 77), (57, 81), speed=0.28, crouch=0.9, coat_swing=0.05, glow=0.55),
        ],
        "punch_1": [
            GUARD,
            Pose((47, 76), (48, 60), (52, 42), (37, 66), (63, 67), (40, 90), (59, 90), (40, 58), (59, 58), (44, 82), (55, 81), crouch=1.2, glow=0.52, coat_swing=0.55),
            Pose((48, 75), (52, 58), (56, 40), (37, 65), (72, 60), (41, 90), (59, 90), (40, 57), (63, 55), (45, 81), (55, 80), impact=0.25, glow=0.75, coat_swing=0.25),
            Pose((50, 74), (56, 56), (60, 38), (38, 64), (82, 57), (42, 90), (60, 90), (41, 57), (68, 54), (45, 81), (56, 80), impact=1.0, glow=1.0, coat_swing=-0.15),
            Pose((50, 74), (55, 56), (59, 38), (38, 64), (77, 59), (42, 90), (60, 90), (41, 57), (66, 54), (45, 81), (56, 80), impact=0.55, glow=0.82, coat_swing=-0.25),
            Pose((49, 75), (52, 58), (56, 40), (38, 65), (69, 64), (41, 90), (59, 90), (41, 57), (62, 56), (45, 82), (55, 81), glow=0.55, coat_swing=0.1),
            shifted(GUARD, dx=0.5, glow=0.48),
        ],
        "punch_2": [
            GUARD,
            Pose((45, 77), (45, 61), (49, 43), (37, 65), (61, 72), (39, 90), (58, 90), (40, 58), (59, 61), (43, 83), (54, 82), crouch=1.45, glow=0.62, coat_swing=0.85),
            Pose((46, 76), (49, 60), (53, 42), (36, 65), (69, 69), (40, 90), (59, 90), (39, 58), (62, 58), (43, 83), (55, 81), crouch=1.2, glow=0.72, coat_swing=0.55),
            Pose((50, 74), (56, 57), (60, 39), (37, 66), (84, 59), (42, 90), (60, 90), (40, 58), (68, 55), (46, 81), (56, 80), impact=1.0, glow=1.0, coat_swing=0.05),
            Pose((52, 74), (58, 57), (62, 39), (38, 67), (86, 60), (43, 90), (60, 90), (41, 59), (70, 55), (47, 81), (56, 81), impact=0.75, glow=0.88, coat_swing=-0.25),
            Pose((50, 75), (54, 58), (58, 40), (39, 67), (71, 66), (43, 90), (59, 90), (42, 58), (63, 57), (47, 82), (55, 82), glow=0.58, coat_swing=0.05),
            shifted(GUARD, dx=0.7, glow=0.5),
        ],
        "punch_3": [
            GUARD,
            Pose((45, 79), (45, 63), (49, 45), (37, 67), (61, 76), (39, 90), (58, 90), (40, 60), (59, 64), (43, 84), (54, 83), crouch=1.7, glow=0.7, coat_swing=1.05),
            Pose((44, 81), (44, 65), (48, 47), (37, 68), (63, 81), (39, 90), (58, 90), (40, 61), (60, 66), (43, 85), (54, 84), crouch=2.0, glow=0.82, coat_swing=1.1),
            Pose((48, 79), (51, 62), (55, 44), (38, 67), (72, 76), (41, 90), (60, 90), (41, 60), (65, 63), (45, 83), (56, 83), impact=0.4, glow=0.9, coat_swing=0.65),
            Pose((55, 76), (61, 58), (65, 40), (39, 68), (83, 72), (45, 90), (63, 90), (42, 61), (70, 58), (49, 82), (58, 82), impact=1.0, glow=1.0, coat_swing=-0.2),
            Pose((56, 77), (61, 59), (65, 41), (40, 69), (79, 77), (46, 90), (63, 90), (43, 62), (70, 60), (50, 83), (58, 83), impact=0.65, glow=0.82, coat_swing=-0.4),
            Pose((52, 78), (56, 61), (60, 43), (40, 69), (70, 72), (44, 90), (61, 90), (43, 62), (65, 61), (48, 84), (57, 84), glow=0.55, coat_swing=-0.25),
            shifted(GUARD, dx=1.0, glow=0.48),
        ],
        "punch_skill": [
            Pose((45, 79), (45, 63), (49, 45), (37, 67), (62, 77), (39, 90), (58, 90), (40, 60), (60, 64), (43, 84), (54, 83), crouch=1.9, glow=0.9, coat_swing=1.1),
            Pose((47, 80), (47, 64), (51, 46), (38, 67), (64, 80), (40, 90), (59, 90), (41, 61), (61, 65), (44, 85), (55, 84), crouch=2.1, glow=1.0, coat_swing=1.0),
            Pose((53, 75), (59, 57), (63, 39), (43, 65), (78, 58), (40, 90), (65, 84), (48, 58), (69, 54), (48, 82), (60, 76), speed=0.75, impact=0.25, glow=1.0, coat_swing=0.55),
            Pose((59, 73), (66, 55), (70, 37), (48, 64), (88, 58), (45, 90), (72, 84), (53, 58), (77, 53), (53, 81), (67, 75), speed=1.0, impact=1.0, glow=1.0, coat_swing=0.1),
            Pose((61, 74), (67, 56), (71, 38), (49, 65), (86, 62), (47, 90), (72, 85), (54, 59), (76, 54), (54, 82), (67, 76), speed=0.75, impact=0.65, glow=0.86, coat_swing=-0.25),
            Pose((56, 76), (61, 58), (65, 40), (45, 66), (77, 68), (45, 90), (66, 87), (49, 59), (69, 56), (51, 82), (62, 79), speed=0.25, glow=0.6, coat_swing=-0.35),
            shifted(GUARD, dx=1.3, glow=0.5),
        ],
    }


def p(point: tuple[float, float]) -> tuple[int, int]:
    return (round(point[0] * SCALE), round(point[1] * SCALE))


def line(draw: ImageDraw.ImageDraw, points: list[tuple[float, float]], fill: tuple[int, int, int, int], width: float) -> None:
    draw.line([p(point) for point in points], fill=fill, width=max(1, round(width * SCALE)), joint="curve")


def ellipse(draw: ImageDraw.ImageDraw, center: tuple[float, float], radius: float, fill: tuple[int, int, int, int]) -> None:
    x, y = center
    box = [round((x - radius) * SCALE), round((y - radius) * SCALE), round((x + radius) * SCALE), round((y + radius) * SCALE)]
    draw.ellipse(box, fill=fill)


def polygon(draw: ImageDraw.ImageDraw, points: list[tuple[float, float]], fill: tuple[int, int, int, int]) -> None:
    draw.polygon([p(point) for point in points], fill=fill)


def auto_joint(a: tuple[float, float], b: tuple[float, float]) -> tuple[float, float]:
    return ((a[0] + b[0]) * 0.5, min(a[1], b[1]) + 3)


def draw_arm(
    draw: ImageDraw.ImageDraw,
    shoulder: tuple[float, float],
    elbow: tuple[float, float],
    hand: tuple[float, float],
    *,
    mech: bool,
    front: bool,
    glow: float,
) -> None:
    line(draw, [shoulder, elbow, hand], OUTLINE, 7.2 if front else 6.4)
    line(draw, [shoulder, elbow], COAT_LIT if front else COAT, 4.7 if front else 4.2)
    forearm = (38, 43, 54, 255) if mech else COAT_LIT
    line(draw, [elbow, hand], forearm if front else PANEL, 4.3 if front else 3.9)
    if mech:
        line(draw, [((elbow[0] + hand[0]) * 0.55, (elbow[1] + hand[1]) * 0.55 - 2), ((elbow[0] + hand[0]) * 0.55 + 1.5, (elbow[1] + hand[1]) * 0.55 + 2)], CYAN_DIM, 0.8 + glow * 0.35)
    ellipse(draw, hand, 3.5, OUTLINE)
    ellipse(draw, (hand[0] + 0.5, hand[1] + 0.3), 2.25, SKIN)
    line(draw, [(hand[0] - 2, hand[1] - 0.5), (hand[0] + 2.2, hand[1] - 0.4)], SKIN_SHADE, 0.9)


def draw_leg(
    draw: ImageDraw.ImageDraw,
    hip: tuple[float, float],
    knee: tuple[float, float],
    foot: tuple[float, float],
    *,
    front: bool,
) -> None:
    line(draw, [hip, knee, foot], OUTLINE, 7.0 if front else 6.2)
    line(draw, [hip, knee], PANEL if front else DEEP, 4.5 if front else 3.9)
    line(draw, [knee, foot], COAT_LIT if front else COAT, 4.2 if front else 3.7)
    line(draw, [foot, (foot[0] + 6, foot[1] - 1)], OUTLINE, 4.6)
    line(draw, [(foot[0] + 0.5, foot[1] - 0.2), (foot[0] + 5.5, foot[1] - 1.0)], BOOT, 2.8)


def draw_character(pose: Pose) -> Image.Image:
    image = Image.new("RGBA", (CELL * SCALE, CELL * SCALE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    chest = pose.chest
    pelvis = pose.pelvis
    left_shoulder = (chest[0] - 7.4, chest[1] + 1.2)
    right_shoulder = (chest[0] + 7.0, chest[1])
    left_hip = (pelvis[0] - 5.0, pelvis[1])
    right_hip = (pelvis[0] + 5.2, pelvis[1])
    left_elbow = pose.left_elbow or auto_joint(left_shoulder, pose.left_hand)
    right_elbow = pose.right_elbow or auto_joint(right_shoulder, pose.right_hand)
    left_knee = pose.left_knee or auto_joint(left_hip, pose.left_foot)
    right_knee = pose.right_knee or auto_joint(right_hip, pose.right_foot)

    draw_leg(draw, left_hip, left_knee, pose.left_foot, front=False)
    draw_leg(draw, right_hip, right_knee, pose.right_foot, front=True)

    coat_shell = [
        (left_shoulder[0] - 3, left_shoulder[1]),
        (chest[0] - 4, chest[1] - 9),
        (right_shoulder[0] + 4, right_shoulder[1] - 1),
        (right_hip[0] + 3, right_hip[1] + 4),
        (pelvis[0] + 10 + pose.coat_swing * 1.8, 93),
        (pelvis[0] + 1, 88),
        (pelvis[0] - 10 + pose.coat_swing * 1.1, 93),
        (left_hip[0] - 3, left_hip[1] + 4),
    ]
    polygon(draw, coat_shell, OUTLINE)
    polygon(draw, [(x + 0.6, y + 0.3) for x, y in coat_shell], COAT)

    left_flap = [
        (chest[0] - 4, chest[1] - 2),
        (pelvis[0] - 1, pelvis[1] + 2),
        (pelvis[0] - 7 + pose.coat_swing * 0.9, 92),
        (pelvis[0] - 12 + pose.coat_swing * 0.45, 91),
        (left_hip[0] - 2, left_hip[1] + 2),
    ]
    right_flap = [
        (chest[0] + 4, chest[1] - 2),
        (right_hip[0] + 2, right_hip[1] + 2),
        (pelvis[0] + 11 + pose.coat_swing * 1.6, 92),
        (pelvis[0] + 5 + pose.coat_swing * 0.9, 91),
        (pelvis[0] + 1, pelvis[1] + 2),
    ]
    polygon(draw, left_flap, DEEP)
    polygon(draw, right_flap, (6, 8, 14, 255))
    line(draw, [(left_flap[0][0] + 1, left_flap[0][1] + 2), (left_flap[2][0] + 1, left_flap[2][1] - 2)], COAT_LIT, 0.55)
    line(draw, [(right_flap[0][0], right_flap[0][1] + 2), (right_flap[2][0] - 1, right_flap[2][1] - 2)], COAT_LIT, 0.55)

    torso = [
        (left_shoulder[0], left_shoulder[1] + 1),
        (chest[0] - 2, chest[1] - 7),
        (right_shoulder[0] + 1, right_shoulder[1]),
        (right_hip[0] + 1, right_hip[1] + 2),
        (pelvis[0], pelvis[1] + 5),
        (left_hip[0], left_hip[1] + 2),
    ]
    polygon(draw, torso, PANEL)
    line(draw, [(chest[0] + 2, chest[1] - 4), (pelvis[0] + 3, pelvis[1] + 5)], PANEL_LIT, 0.8)
    line(draw, [(chest[0] - 3, chest[1] - 3), (left_hip[0] + 1, left_hip[1] + 5)], COAT_LIT, 0.75)
    if pose.glow > 0.15:
        line(draw, [(chest[0] - 5, chest[1] - 7), (left_shoulder[0] - 1, left_shoulder[1] - 2)], CYAN_DIM, 0.55)
        line(draw, [(chest[0] + 3, chest[1] - 7), (right_shoulder[0] + 2, right_shoulder[1] - 2)], CYAN_DIM, 0.55)

    draw_arm(draw, left_shoulder, left_elbow, pose.left_hand, mech=False, front=False, glow=pose.glow)
    draw_arm(draw, right_shoulder, right_elbow, pose.right_hand, mech=True, front=True, glow=pose.glow)

    line(draw, [(chest[0], chest[1] - 8), (pose.head[0], pose.head[1] + 6)], OUTLINE, 4.4)
    ellipse(draw, pose.head, 6.8, OUTLINE)
    ellipse(draw, (pose.head[0] + 1.2, pose.head[1] + 1.6), 5.1, SKIN)
    hair = [
        (pose.head[0] - 7, pose.head[1] + 1),
        (pose.head[0] - 6, pose.head[1] - 5),
        (pose.head[0] - 2, pose.head[1] - 9),
        (pose.head[0] + 5, pose.head[1] - 7),
        (pose.head[0] + 7, pose.head[1] - 1),
        (pose.head[0] + 3.5, pose.head[1] + 2),
        (pose.head[0] - 1, pose.head[1] + 1),
    ]
    polygon(draw, hair, HAIR)
    line(draw, [(pose.head[0] - 3, pose.head[1] - 5), (pose.head[0] + 4, pose.head[1] - 7)], HAIR_LIT, 1.1)
    line(draw, [(pose.head[0] - 2, pose.head[1] + 1), (pose.head[0] + 4, pose.head[1] + 1)], SKIN_SHADE, 0.9)
    ellipse(draw, (pose.head[0] + 3.5, pose.head[1] + 1.0), 2.0 + pose.glow, CYAN_DIM)
    ellipse(draw, (pose.head[0] + 3.5, pose.head[1] + 1.0), 0.9, CYAN)
    line(draw, [(pose.head[0] - 1, pose.head[1] + 5), (pose.head[0] + 2, pose.head[1] + 6)], SKIN_SHADE, 0.8)

    if pose.impact > 0:
        hx, hy = pose.right_hand
        reach = 8 + 8 * pose.impact
        line(draw, [(hx, hy), (min(94, hx + reach), hy - 2)], CYAN, 1.0 + pose.impact * 0.55)
        line(draw, [(hx, hy + 1.5), (min(94, hx + reach - 2), hy + 5)], CYAN_DIM, 0.75)
        line(draw, [(hx + 1, hy - 3), (min(94, hx + reach - 3), hy - 6)], CYAN_DIM, 0.7)

    if pose.hurt > 0:
        line(draw, [(pose.head[0] - 4, pose.head[1] - 7), (pose.head[0] - 9, pose.head[1] - 11)], CYAN_DIM, 1.0)
        line(draw, [(pose.chest[0] + 4, pose.chest[1] - 4), (pose.chest[0] + 9, pose.chest[1] - 8)], CYAN, 1.0)

    return image.resize((CELL, CELL), Image.Resampling.BOX)


def build_animation_frames() -> dict[str, list[Image.Image]]:
    key_map = animation_keys()
    frames: dict[str, list[Image.Image]] = {}
    for name, count, loop in ANIMATIONS:
        frames[name] = [draw_character(pose) for pose in sample_sequence(key_map[name], count, loop)]
    return frames


def write_strip(name: str, frames: list[Image.Image]) -> None:
    sheet = Image.new("RGBA", (CELL * len(frames), CELL), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        sheet.alpha_composite(frame, (index * CELL, 0))
    sheet.save(STRIP_DIR / f"{name}.png")


def main() -> None:
    STRIP_DIR.mkdir(parents=True, exist_ok=True)
    for stale in STRIP_DIR.glob("*.png"):
        stale.unlink()
    frames = build_animation_frames()
    for name, animation_frames in frames.items():
        write_strip(name, animation_frames)
    print(f"Generated fresh cyber fist strips: {sum(len(v) for v in frames.values())} frames")
    print(STRIP_DIR)


if __name__ == "__main__":
    main()
