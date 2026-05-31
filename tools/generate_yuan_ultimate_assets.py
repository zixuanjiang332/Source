from __future__ import annotations

import math
import shutil
import wave
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
GEN_DIR = Path.home() / ".codex" / "generated_images" / "019e7ca5-b4a3-7481-8feb-2c4f1d6ae76e"

SOURCE_FILES = {
    "blue_slash_reference": "ig_011538b3e9abe0ed016a1c54e06c208191bd825e2a3a9d1d41.png",
    "red_slam_reference": "ig_011538b3e9abe0ed016a1c553f95b48191976556541f166245.png",
    "ultimate_slam_reference": "ig_011538b3e9abe0ed016a1c55909e988191b073a5bcd3a6d4e5.png",
}

VFX_DIR = ROOT / "assets" / "pixel" / "vfx" / "yuan_ultimate"
PLAYER_DIR = ROOT / "assets" / "pixel" / "characters" / "player_yuan_early_clone"
AUDIO_DIR = ROOT / "assets" / "audio" / "sfx"
SOURCE_DIR = ROOT / "art_src" / "generated_frames" / "vfx" / "yuan_ultimate" / "_source"


def ensure_dirs() -> None:
    for path in [VFX_DIR, PLAYER_DIR, AUDIO_DIR, SOURCE_DIR]:
        path.mkdir(parents=True, exist_ok=True)


def copy_sources() -> None:
    for name, filename in SOURCE_FILES.items():
        src = GEN_DIR / filename
        if not src.exists():
            raise FileNotFoundError(src)
        shutil.copy2(src, SOURCE_DIR / f"{name}.png")


def draw_glow_line(draw: ImageDraw.ImageDraw, points: list[tuple[float, float]], core, glow, width: int) -> None:
    for w, alpha in [(width + 14, 34), (width + 8, 72), (width + 4, 120)]:
        color = (*glow[:3], min(alpha, glow[3]))
        draw.line(points, fill=color, width=w, joint="curve")
    draw.line(points, fill=core, width=width, joint="curve")


def make_slash_frame(size: tuple[int, int], frame: int, frames: int, angle: float, cyan_shift: float) -> Image.Image:
    w, h = size
    im = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(im, "RGBA")
    progress = frame / max(1, frames - 1)
    length = 0.76 + progress * 0.46
    fade = 1.0 - max(0.0, progress - 0.68) / 0.32
    cx = w * (0.45 + 0.05 * math.sin(cyan_shift))
    cy = h * (0.5 + 0.16 * math.sin(angle))
    dx = math.cos(angle) * w * 0.78 * length
    dy = math.sin(angle) * h * 0.88 * length
    start = (cx - dx * 0.45, cy - dy * 0.45)
    end = (cx + dx * 0.55, cy + dy * 0.55)
    mid = ((start[0] + end[0]) * 0.5, (start[1] + end[1]) * 0.5 - 10 * math.cos(cyan_shift))
    alpha = int(255 * fade)
    core = (218, 255, 255, alpha)
    glow = (18, 196, 255, alpha)
    draw_glow_line(draw, [start, mid, end], core, glow, 12 if frame < 3 else 9)

    normal = angle + math.pi * 0.5
    blade_width = 12.0 * fade
    poly = [
        (start[0] + math.cos(normal) * blade_width, start[1] + math.sin(normal) * blade_width),
        (mid[0] + math.cos(normal) * blade_width * 0.8, mid[1] + math.sin(normal) * blade_width * 0.8),
        (end[0] + math.cos(normal) * 2.0, end[1] + math.sin(normal) * 2.0),
        (end[0] - math.cos(normal) * 2.0, end[1] - math.sin(normal) * 2.0),
        (mid[0] - math.cos(normal) * blade_width * 0.8, mid[1] - math.sin(normal) * blade_width * 0.8),
        (start[0] - math.cos(normal) * blade_width, start[1] - math.sin(normal) * blade_width),
    ]
    draw.polygon(poly, fill=(56, 214, 255, int(92 * fade)))

    magenta = (255, 42, 178, int(120 * fade))
    for i in range(9):
        t = (i + frame * 0.7) / 9.0
        x = start[0] + (end[0] - start[0]) * t + math.sin(i * 1.8 + frame) * 16
        y = start[1] + (end[1] - start[1]) * t + math.cos(i * 1.4 + frame) * 10
        draw.rectangle((x, y, x + 5, y + 3), fill=magenta)
    return im


def make_blue_slashes() -> None:
    size = (256, 128)
    frames = 6
    angles = [-0.12, 0.16, -0.34, 0.32, -0.24, 0.08, -0.42]
    for idx, angle in enumerate(angles, start=1):
        sheet = Image.new("RGBA", (size[0] * frames, size[1]), (0, 0, 0, 0))
        for f in range(frames):
            frame = make_slash_frame(size, f, frames, angle, idx * 0.9)
            sheet.paste(frame, (f * size[0], 0), frame)
        sheet.save(VFX_DIR / f"vfx_yuan_ult_blue_slash_{idx:02d}.png")


def make_afterimage() -> None:
    size = (96, 96)
    frames = 7
    sheet = Image.new("RGBA", (size[0] * frames, size[1]), (0, 0, 0, 0))
    for f in range(frames):
        im = Image.new("RGBA", size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(im, "RGBA")
        alpha = 185 - f * 18
        x_shift = 10 - f * 3
        draw.polygon(
            [(36 + x_shift, 22), (56 + x_shift, 22), (66 + x_shift, 75), (27 + x_shift, 75)],
            fill=(25, 214, 255, alpha),
        )
        draw.line([(22 + x_shift, 42), (72 + x_shift, 38)], fill=(230, 255, 255, alpha), width=3)
        for i in range(8):
            x = 18 + i * 8 - f * 2
            y = 18 + ((i * 11 + f * 7) % 58)
            draw.rectangle((x, y, x + 3, y + 2), fill=(255, 42, 188, max(0, alpha - 70)))
        sheet.paste(im, (f * size[0], 0), im)
    sheet.save(VFX_DIR / "vfx_yuan_ult_afterimage.png")


def make_red_vfx() -> None:
    size = (256, 128)
    frames = 6
    arc_sheet = Image.new("RGBA", (size[0] * frames, size[1]), (0, 0, 0, 0))
    impact_sheet = Image.new("RGBA", (size[0] * frames, size[1]), (0, 0, 0, 0))
    for f in range(frames):
        p = f / (frames - 1)
        arc = Image.new("RGBA", size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(arc, "RGBA")
        alpha = int(255 * (1 - max(0.0, p - 0.72) / 0.28))
        draw_glow_line(
            draw,
            [(86, 8 + p * 18), (122, 58), (162, 122 - p * 8)],
            (255, 238, 238, alpha),
            (255, 24, 38, alpha),
            8,
        )
        for i in range(12):
            x = 92 + i * 7 + math.sin(f + i) * 8
            y = 18 + i * 8
            draw.rectangle((x, y, x + 3, y + 6), fill=(255, 32, 64, int(alpha * 0.62)))
        arc_sheet.paste(arc, (f * size[0], 0), arc)

        impact = Image.new("RGBA", size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(impact, "RGBA")
        radius = 18 + f * 16
        fade = 1 - p * 0.85
        for i in range(18):
            ang = -math.pi + i * math.pi / 17
            length = radius * (0.65 + 0.45 * math.sin(i * 2.1))
            sx, sy = 128, 90
            ex = sx + math.cos(ang) * length
            ey = sy + math.sin(ang) * length * 0.55
            color = (255, 30, 42, int(230 * fade))
            draw.line([(sx, sy), (ex, ey)], fill=color, width=3 if i % 2 else 5)
        draw.ellipse((116 - f * 2, 78 - f, 140 + f * 2, 102 + f), fill=(255, 244, 230, int(200 * fade)))
        impact_sheet.paste(impact, (f * size[0], 0), impact)
    arc_sheet.save(VFX_DIR / "vfx_yuan_ult_red_slam_arc.png")
    impact_sheet.save(VFX_DIR / "vfx_yuan_ult_red_impact.png")


def chroma_alpha(im: Image.Image) -> Image.Image:
    rgba = im.convert("RGBA")
    px = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            r, g, b, a = px[x, y]
            if g > 160 and r < 90 and b < 90:
                px[x, y] = (0, 0, 0, 0)
    return rgba


def make_character_slam() -> None:
    src = chroma_alpha(Image.open(SOURCE_DIR / "ultimate_slam_reference.png"))
    frames = 8
    frame_w = src.width // frames
    sheet = Image.new("RGBA", (96 * frames, 96), (0, 0, 0, 0))
    for f in range(frames):
        seg = src.crop((f * frame_w, 0, (f + 1) * frame_w, src.height))
        alpha = seg.getchannel("A")
        bbox = alpha.getbbox()
        if bbox is None:
            continue
        crop = seg.crop(bbox)
        scale = min(86 / crop.width, 90 / crop.height)
        new_size = (max(1, round(crop.width * scale)), max(1, round(crop.height * scale)))
        crop = crop.resize(new_size, Image.Resampling.NEAREST)
        out = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
        x = (96 - crop.width) // 2
        y = 96 - crop.height - 1
        out.paste(crop, (x, y), crop)
        sheet.paste(out, (f * 96, 0), out)
    sheet.save(PLAYER_DIR / "spr_player_yuan_ultimate_slam.png")


def oscillator(freq: float, t: float, duty: float = 0.5) -> float:
    phase = (t * freq) % 1.0
    return 1.0 if phase < duty else -1.0


def write_wav(path: Path, duration: float, base_freq: float, sweep: float, drive: float, thump: float = 0.0) -> None:
    sr = 44100
    samples = []
    for n in range(int(sr * duration)):
        t = n / sr
        p = t / duration
        env = math.sin(math.pi * min(1.0, p)) ** 0.45 * (1.0 - p * 0.42)
        freq = base_freq + sweep * p
        tone = math.sin(2 * math.pi * freq * t) * 0.55
        edge = oscillator(freq * 1.98, t, 0.42) * 0.18
        noise = math.sin(2 * math.pi * (freq * 7.1) * t + math.sin(t * 220)) * 0.08
        low = math.sin(2 * math.pi * 72 * t) * thump * math.exp(-p * 9.0)
        sample = (tone + edge + noise + low) * env * drive
        samples.append(max(-1.0, min(1.0, sample)))
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(sr)
        data = bytearray()
        for sample in samples:
            value = int(sample * 32767)
            data += value.to_bytes(2, "little", signed=True)
        wav.writeframes(bytes(data))


def make_audio() -> None:
    write_wav(AUDIO_DIR / "sfx_yuan_ult_charge_01.wav", 0.46, 420, 680, 0.42)
    write_wav(AUDIO_DIR / "sfx_yuan_ult_afterimage_01.wav", 0.14, 980, 420, 0.32)
    for i in range(1, 8):
        write_wav(AUDIO_DIR / f"sfx_yuan_ult_blue_slash_{i:02d}.wav", 0.17, 820 + i * 36, 640 + i * 20, 0.36)
    write_wav(AUDIO_DIR / "sfx_yuan_ult_red_drop_01.wav", 0.34, 260, -120, 0.52, 0.28)
    write_wav(AUDIO_DIR / "sfx_yuan_ult_red_impact_01.wav", 0.42, 130, 90, 0.78, 0.92)


def main() -> None:
    ensure_dirs()
    copy_sources()
    make_blue_slashes()
    make_afterimage()
    make_red_vfx()
    make_character_slam()
    make_audio()


if __name__ == "__main__":
    main()
