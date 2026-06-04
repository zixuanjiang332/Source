from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
SPRITE_PATH = ROOT / "assets" / "pixel" / "characters" / "player_yuan_runtime" / "frames" / "combat_idle_00.png"
RUNTIME_FRAME_DIR = ROOT / "assets" / "pixel" / "characters" / "player_yuan_runtime" / "frames"

CONCEPT_SRC_DIR = ROOT / "art_src" / "concepts"
CONCEPT_EXPORT_DIR = ROOT / "assets" / "pixel" / "characters" / "yuan"
UI_DIR = ROOT / "assets" / "ui"
PLACEHOLDER_DIR = ROOT / "assets" / "pixel" / "placeholders"
HIGHRES_SRC_DIR = ROOT / "art_src" / "generated" / "highres_backgrounds"

NAVY = (6, 10, 22, 255)
NAVY_2 = (10, 18, 36, 255)
CYAN = (52, 238, 255, 255)
CYAN_SOFT = (44, 170, 214, 180)
CYAN_FAINT = (26, 112, 148, 150)
STEEL_SIGNAL = (96, 128, 154, 190)
SKIN = (217, 151, 118, 255)
SKIN_SH = (129, 82, 66, 255)
PLATE = (54, 62, 78, 255)
PLATE_HI = (94, 112, 134, 255)
PLATE_DARK = (28, 34, 48, 255)
CLOTH = (8, 10, 16, 255)
WHITE = (244, 250, 255, 255)
BLACK = (4, 6, 12, 255)


def ensure_dirs() -> None:
    for path in [CONCEPT_SRC_DIR, CONCEPT_EXPORT_DIR, UI_DIR, PLACEHOLDER_DIR, HIGHRES_SRC_DIR]:
        path.mkdir(parents=True, exist_ok=True)


def load_base_sprite() -> Image.Image:
    return Image.open(SPRITE_PATH).convert("RGBA")


def make_gradient(width: int, height: int, top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    image = Image.new("RGBA", (width, height), 0)
    draw = ImageDraw.Draw(image)
    for y in range(height):
        t = y / max(1, height - 1)
        color = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        draw.line([(0, y), (width, y)], fill=color + (255,))
    return image


def add_scanlines(image: Image.Image, spacing: int, alpha: int) -> None:
    draw = ImageDraw.Draw(image)
    for y in range(0, image.height, spacing):
        draw.line([(0, y), (image.width, y)], fill=(255, 255, 255, alpha))


def add_city_lights(image: Image.Image, *, density: int = 48) -> None:
    draw = ImageDraw.Draw(image)
    for x in range(density, image.width, density):
        h = int(image.height * (0.18 + ((x * 17) % 43) / 100))
        w = 6 + (x % 13)
        y0 = image.height - h - 90
        color = CYAN_SOFT if (x // density) % 3 else CYAN_FAINT
        draw.rounded_rectangle((x, y0, x + w, image.height - 90), radius=3, fill=color)
        for py in range(y0 + 8, image.height - 96, 18):
            draw.rectangle((x + 1, py, x + w - 1, py + 2), fill=(255, 255, 255, 50))


def add_grid(image: Image.Image, *, step: int, alpha: int) -> None:
    draw = ImageDraw.Draw(image)
    for x in range(0, image.width, step):
        draw.line([(x, 0), (x, image.height)], fill=(66, 110, 160, alpha))
    for y in range(0, image.height, step):
        draw.line([(0, y), (image.width, y)], fill=(66, 110, 160, alpha))


def compose_sprite_glow(sprite: Image.Image, scale: int) -> Image.Image:
    scaled = sprite.resize((sprite.width * scale, sprite.height * scale), Image.Resampling.NEAREST)
    glow = Image.new("RGBA", scaled.size, (0, 0, 0, 0))
    glow.alpha_composite(scaled)
    glow = glow.filter(ImageFilter.GaussianBlur(radius=max(3, scale // 2)))
    tinted = Image.new("RGBA", glow.size, (0, 0, 0, 0))
    tint_draw = ImageDraw.Draw(tinted)
    tint_draw.rectangle((0, 0, glow.width, glow.height), fill=(55, 238, 255, 90))
    glow = Image.blend(glow, tinted, 0.55)
    glow.alpha_composite(scaled)
    return glow


def add_core_bloom(image: Image.Image, center: tuple[int, int], radius: int) -> None:
    bloom = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(bloom)
    for i in range(4):
        r = radius + i * 18
        alpha = max(18, 120 - i * 28)
        draw.ellipse((center[0] - r, center[1] - r, center[0] + r, center[1] + r), fill=(52, 238, 255, alpha))
    bloom = bloom.filter(ImageFilter.GaussianBlur(radius=10))
    image.alpha_composite(bloom)


def add_shatter(image: Image.Image, origin: tuple[int, int], spread: int, color: tuple[int, int, int, int]) -> None:
    draw = ImageDraw.Draw(image)
    ox, oy = origin
    for i in range(9):
        dx = (i * 37) % spread - spread // 2
        dy = (i * 23) % spread - spread // 2
        draw.line([(ox, oy), (ox + dx, oy + dy)], fill=color, width=2)
        draw.line([(ox + dx, oy + dy), (ox + dx + 14, oy + dy - 6)], fill=color, width=1)


def load_runtime_frame(name: str) -> Image.Image:
    return Image.open(RUNTIME_FRAME_DIR / f"{name}.png").convert("RGBA")


def stamp_pixel_sprite(
    canvas: Image.Image,
    sprite: Image.Image,
    *,
    position: tuple[int, int],
    scale: int,
    glow_radius: int = 8,
    glow_tint: tuple[int, int, int, int] = (52, 238, 255, 78),
) -> tuple[int, int]:
    scaled = sprite.resize((sprite.width * scale, sprite.height * scale), Image.Resampling.NEAREST)
    glow = scaled.filter(ImageFilter.GaussianBlur(radius=glow_radius))
    tint = Image.new("RGBA", glow.size, glow_tint)
    glow = Image.blend(glow, tint, 0.35)
    canvas.alpha_composite(glow, (position[0] - glow_radius * 2, position[1] - glow_radius * 2))
    canvas.alpha_composite(scaled, position)
    return (position[0] + scaled.width // 2, position[1] + scaled.height // 2)


def add_pixel_skyline(image: Image.Image, *, band_top: int, band_bottom: int, density: int, seed: int) -> None:
    draw = ImageDraw.Draw(image)
    span = band_bottom - band_top
    for i in range(density):
        x = 36 + i * max(18, image.width // density)
        width = 18 + ((i * 11 + seed) % 46)
        height = span // 3 + ((i * 19 + seed) % max(32, span // 2))
        y = band_bottom - height
        tone = 18 + (i * 7 + seed) % 26
        color = (tone, tone + 10, tone + 24, 220)
        draw.rectangle((x, y, x + width, band_bottom), fill=color)
        light = CYAN_SOFT if i % 3 else CYAN_FAINT
        for py in range(y + 8, band_bottom - 6, 14):
            draw.rectangle((x + 3, py, x + width - 3, py + 2), fill=light)


def add_pixel_panel(image: Image.Image, box: tuple[int, int, int, int], title: str, lines: list[str]) -> None:
    draw = ImageDraw.Draw(image)
    x0, y0, x1, y1 = box
    draw.rectangle(box, fill=(8, 12, 24, 208), outline=(72, 136, 186, 180), width=3)
    draw.rectangle((x0 + 10, y0 + 10, x1 - 10, y0 + 34), fill=(18, 28, 52, 220))
    draw.text((x0 + 18, y0 + 14), title, fill=WHITE)
    cursor_y = y0 + 52
    for line in lines:
        draw.text((x0 + 18, cursor_y), line, fill=(176, 214, 235, 255))
        cursor_y += 28


def crop_to_visible(sprite: Image.Image, pad: int = 0) -> Image.Image:
    bbox = sprite.getbbox()
    if bbox is None:
        return sprite.copy()
    x0 = max(0, bbox[0] - pad)
    y0 = max(0, bbox[1] - pad)
    x1 = min(sprite.width, bbox[2] + pad)
    y1 = min(sprite.height, bbox[3] + pad)
    return sprite.crop((x0, y0, x1, y1))


def make_concept_variant(name: str, accent: str, *, include_weapon: bool) -> Image.Image:
    canvas = make_gradient(1254, 1254, (5, 9, 22), (14, 24, 46))
    add_scanlines(canvas, spacing=4, alpha=10)
    add_pixel_skyline(canvas, band_top=182, band_bottom=1110, density=18, seed=22 if include_weapon else 41)

    hero = load_runtime_frame("combat_idle_00")
    ghost_a = load_runtime_frame("punch_1_05")
    ghost_b = load_runtime_frame("punch_3_06" if include_weapon else "combat_run_04")

    stamp_pixel_sprite(canvas, ghost_a, position=(120, 540), scale=5, glow_radius=6, glow_tint=(36, 152, 192, 52))
    stamp_pixel_sprite(canvas, ghost_b, position=(820, 560), scale=5, glow_radius=6, glow_tint=(52, 238, 255, 64))
    core_center = stamp_pixel_sprite(canvas, hero, position=(280, 220), scale=9, glow_radius=10)

    draw = ImageDraw.Draw(canvas)
    add_core_bloom(canvas, (core_center[0] + 16, core_center[1] + 148), 42)
    add_shatter(canvas, (core_center[0] - 20, core_center[1] - 76), 220, CYAN_FAINT)

    if include_weapon:
        draw.line([(688, 552), (964, 468)], fill=(90, 118, 142, 220), width=12)
        draw.line([(676, 560), (950, 438)], fill=CYAN, width=6)

    add_pixel_panel(
        canvas,
        (80, 900, 1174, 1160),
        f"YUAN // {name.upper()}",
        [
            accent,
            "High-resolution pixel composition rebuilt from runtime combat frames.",
            "Cyber bruiser silhouette // exposed chest core // fist-first opening loadout.",
            "Fresh cyber fist runtime frames; no board-cropped character fragments.",
        ],
    )
    return canvas


def make_portrait() -> Image.Image:
    base = make_gradient(64, 64, (8, 14, 28), (15, 24, 42))
    close = crop_to_visible(load_runtime_frame("combat_idle_00"), pad=2)
    scaled = close.resize((58, 58), Image.Resampling.NEAREST)
    glow = scaled.filter(ImageFilter.GaussianBlur(radius=3))
    tint = Image.new("RGBA", glow.size, (52, 238, 255, 72))
    glow = Image.blend(glow, tint, 0.3)
    base.alpha_composite(glow, (2, 4))
    base.alpha_composite(scaled, (4, 4))
    draw = ImageDraw.Draw(base)
    draw.rectangle((1, 1, 62, 62), outline=CYAN, width=2)
    draw.rectangle((4, 48, 60, 60), fill=(10, 18, 36, 220))
    draw.rectangle((6, 50, 38, 52), fill=STEEL_SIGNAL)
    draw.rectangle((6, 55, 54, 57), fill=CYAN)
    return base


def make_demo_idle() -> Image.Image:
    sprite = load_base_sprite().copy()
    add_core_bloom(sprite, (52, 61), 5)
    return sprite


def make_menu_background(width: int, height: int, *, close_crop: bool) -> Image.Image:
    canvas = make_gradient(width, height, (4, 7, 18), (9, 16, 34))
    add_scanlines(canvas, spacing=5, alpha=7)
    add_pixel_skyline(canvas, band_top=120, band_bottom=height - 78, density=max(18, width // 110), seed=17 if close_crop else 31)

    hero_name = "punch_skill_06" if close_crop else "combat_idle_00"
    hero_sprite = load_runtime_frame(hero_name)
    action_sprite = load_runtime_frame("combat_run_03")

    if close_crop:
        hero_pos = (-80, 40)
        core_center = stamp_pixel_sprite(canvas, hero_sprite, position=hero_pos, scale=16, glow_radius=14)
        stamp_pixel_sprite(canvas, action_sprite, position=(width - 360, height - 420), scale=7, glow_radius=8, glow_tint=(36, 152, 192, 52))
    else:
        hero_pos = (110, 108)
        core_center = stamp_pixel_sprite(canvas, hero_sprite, position=hero_pos, scale=11, glow_radius=12)
        stamp_pixel_sprite(canvas, action_sprite, position=(width - 520, height - 390), scale=8, glow_radius=9, glow_tint=(36, 152, 192, 52))
        stamp_pixel_sprite(canvas, load_runtime_frame("punch_2_05"), position=(width - 780, height - 460), scale=6, glow_radius=7)

    add_core_bloom(canvas, (core_center[0] + 22, core_center[1] + 130), 48 if close_crop else 38)
    add_shatter(canvas, (core_center[0] - 50, core_center[1] - 90), 260, CYAN_FAINT)

    draw = ImageDraw.Draw(canvas)
    if not close_crop:
        add_pixel_panel(
            canvas,
            (width - 760, 136, width - 86, 360),
            "NEON MACHINE // REBORN",
            [
                "Punch-first cyber brawler",
                "Damaged visor // live chest core",
                "Runtime sheet regenerated from scratch",
            ],
        )
    else:
        draw.rectangle((width - 356, 88, width - 84, 286), fill=(8, 12, 24, 214), outline=(72, 136, 186, 180), width=3)
        draw.text((width - 330, 116), "YUAN // CLOSE CROP", fill=WHITE)
        draw.text((width - 330, 162), "pixel HD title art", fill=(168, 220, 255, 255))
        draw.text((width - 330, 206), "fist-first start", fill=(168, 220, 255, 255))
    return canvas


def save(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path)


def main() -> None:
    ensure_dirs()

    portrait = make_portrait()
    save(portrait, UI_DIR / "portrait_yuan_stage_01.png")

    clean_bg = make_menu_background(1920, 1080, close_crop=False)
    save(clean_bg, UI_DIR / "bg_start_menu_yuan_face_clean_1920.png")
    save(clean_bg, HIGHRES_SRC_DIR / "bg_start_menu_yuan_face_clean_1920_source.png")

    print("Generated cyber fist identity assets:")
    print(UI_DIR)


if __name__ == "__main__":
    main()
