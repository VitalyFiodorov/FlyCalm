from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "store_assets" / "screenshots_v3"
SOURCE = OUTPUT / "source_ui"
BACKGROUND = OUTPUT / "pastel_sky_background.png"
FONT_DIR = Path("C:/Users/vfiodorov/flutter/bin/cache/artifacts/material_fonts")

W, H = 1080, 1920
PRIMARY = "#0F172A"
SECONDARY = "#475569"
SKY = "#60A5FA"
WHITE = "#F8FAFC"

SCREENS = [
    ("01_flying_feels_scary.png", "01_home.png", "Flying feels scary?", "Open FlyCalm. Find your next calm step.", "#60A5FA"),
    ("02_before_takeoff.png", "02_takeoff.png", "Feel steadier\nbefore takeoff.", "Guided breathing for the moments that feel biggest.", "#A7F3D0"),
    ("03_turbulence_support.png", "03_turbulence.png", "Understand turbulence.\nStay grounded.", "Calm explanations and step-by-step support.", "#DDD6FE"),
    ("04_panic_support.png", "04_panic.png", "When panic rises,\nfollow one gentle step.", "Breathe. Ground. Reconnect with the cabin.", "#C4B5FD"),
    ("05_guided_journey.png", "05_journey.png", "Guidance from boarding\nto landing.", "A complete journey that stays with you.", "#60A5FA"),
    ("06_offline_support.png", "06_offline.png", "Your calm tools\nwork offline.", "Keep support close—even in airplane mode.", "#A7F3D0"),
    ("07_land_with_confidence.png", "07_landing.png", "Land with more\nconfidence.", "Turn each flight into proof you can do this.", "#DDD6FE"),
]


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_DIR / name, size)


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, *size), radius=radius, fill=255)
    return mask


def fit_cover(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    scale = max(size[0] / image.width, size[1] / image.height)
    resized = image.resize((round(image.width * scale), round(image.height * scale)), Image.Resampling.LANCZOS)
    left = (resized.width - size[0]) // 2
    top = (resized.height - size[1]) // 2
    return resized.crop((left, top, left + size[0], top + size[1]))


def draw_brand(canvas: Image.Image) -> None:
    draw = ImageDraw.Draw(canvas)
    icon = Image.open(ROOT / "assets" / "FlyCalmLauncher.png").convert("RGBA")
    icon.thumbnail((54, 54), Image.Resampling.LANCZOS)
    icon_mask = rounded_mask(icon.size, 13)
    canvas.paste(icon, (64, 58), icon_mask)
    draw.text((132, 65), "FlyCalm", font=font("roboto-bold.ttf", 34), fill=PRIMARY)


def build_one(filename: str, source_name: str, headline: str, subtitle: str, accent: str) -> None:
    background = fit_cover(Image.open(BACKGROUND).convert("RGB"), (W, H)).convert("RGBA")
    veil = Image.new("RGBA", (W, H), (248, 250, 252, 0))
    veil_draw = ImageDraw.Draw(veil)
    for y in range(0, 680):
        alpha = round(150 * (1 - y / 680))
        veil_draw.line((0, y, W, y), fill=(248, 250, 252, alpha))
    background.alpha_composite(veil)

    draw = ImageDraw.Draw(background)
    draw.rounded_rectangle((64, 132, 194, 144), radius=6, fill=accent)
    draw.multiline_text(
        (64, 166), headline, font=font("roboto-bold.ttf", 68), fill=PRIMARY,
        spacing=2,
    )
    headline_lines = headline.count("\n") + 1
    subtitle_y = 166 + headline_lines * 78 + 18
    draw.text((64, subtitle_y), subtitle, font=font("roboto-regular.ttf", 31), fill=SECONDARY)

    source = Image.open(SOURCE / source_name).convert("RGBA")
    if source_name == "01_home.png":
        source_draw = ImageDraw.Draw(source)
        button_bounds = (72, 654, 1008, 856)
        source_draw.rounded_rectangle(
            button_bounds,
            radius=100,
            fill="#FFFFFF",
            outline=SKY,
            width=6,
        )
        button_text = "Add next flight"
        button_font = font("roboto-bold.ttf", 48)
        text_box = source_draw.textbbox((0, 0), button_text, font=button_font)
        text_x = (W - (text_box[2] - text_box[0])) // 2
        text_y = 755 - (text_box[3] - text_box[1]) // 2 - text_box[1]
        source_draw.text((text_x, text_y), button_text, font=button_font, fill=PRIMARY)
    phone_w = 820
    phone_h = round(source.height * phone_w / source.width)
    source = source.resize((phone_w, phone_h), Image.Resampling.LANCZOS)

    frame_pad = 14
    frame_size = (phone_w + frame_pad * 2, phone_h + frame_pad * 2)
    phone = Image.new("RGBA", frame_size, (0, 0, 0, 0))
    phone_draw = ImageDraw.Draw(phone)
    phone_draw.rounded_rectangle((0, 0, frame_size[0] - 1, frame_size[1] - 1), radius=56, fill="#111827")
    screen_mask = rounded_mask(source.size, 43)
    phone.paste(source, (frame_pad, frame_pad), screen_mask)

    shadow = Image.new("RGBA", (frame_size[0] + 100, frame_size[1] + 100), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((50, 35, 50 + frame_size[0], 35 + frame_size[1]), radius=60, fill=(15, 23, 42, 100))
    shadow = shadow.filter(ImageFilter.GaussianBlur(28))

    phone_x = (W - frame_size[0]) // 2
    phone_y = max(500, subtitle_y + 78)
    background.alpha_composite(shadow, (phone_x - 50, phone_y - 35))
    background.alpha_composite(phone, (phone_x, phone_y))

    background.convert("RGB").save(OUTPUT / filename, quality=96, optimize=True)


def contact_sheet() -> None:
    thumb_w, thumb_h = 270, 480
    sheet = Image.new("RGB", (thumb_w * 4, thumb_h * 2), "#EAF3FF")
    for index, (filename, *_rest) in enumerate(SCREENS):
        image = Image.open(OUTPUT / filename).convert("RGB")
        image.thumbnail((thumb_w - 16, thumb_h - 16), Image.Resampling.LANCZOS)
        x = (index % 4) * thumb_w + (thumb_w - image.width) // 2
        y = (index // 4) * thumb_h + (thumb_h - image.height) // 2
        sheet.paste(image, (x, y))
    sheet.save(OUTPUT / "contact_sheet.png", optimize=True)


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for spec in SCREENS:
        build_one(*spec)
    contact_sheet()


if __name__ == "__main__":
    main()
