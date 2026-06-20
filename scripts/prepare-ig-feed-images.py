#!/usr/bin/env python3
"""Format Stepasaurus simulator shots like the Android IG carousel exports."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "marketing" / "screenshots" / "ig"
OUTPUT_DIR = ROOT / "marketing" / "screenshots" / "ig" / "instagram"

TARGET_W = 1080
TARGET_H = 1350

# Same 3-slide story as Android: legendary egg -> rare egg 80% -> volcanic trex baby.
CAROUSEL_ITEMS: tuple[tuple[str, str, str], ...] = (
    ("01-legendary-egg.png", "01-legendary-egg", "1/3"),
    ("02-rare-egg-80.png", "02-rare-egg-80", "2/3"),
    ("03-volcanic-trex-baby.png", "03-volcanic-trex-baby", "3/3"),
)

try:
    TITLE_FONT = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 44)
    SUB_FONT = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 28)
    SLIDE_FONT = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 24)
except OSError:
    TITLE_FONT = SUB_FONT = SLIDE_FONT = ImageFont.load_default()


# iOS layout needs a tighter crop than Android raw percentages so we keep only the game card.
DEFAULT_CROP = (0.04, 0.145, 0.96, 0.655)
CROP_OVERRIDES: dict[str, tuple[float, float, float, float]] = {
    "03-volcanic-trex-baby.png": (0.04, 0.132, 0.96, 0.605),
}


def crop_ui_card(image: Image.Image, source_name: str) -> Image.Image:
    width, height = image.size
    left_frac, top_frac, right_frac, bottom_frac = CROP_OVERRIDES.get(
        source_name,
        DEFAULT_CROP,
    )
    return image.crop(
        (
            int(width * left_frac),
            int(height * top_frac),
            int(width * right_frac),
            int(height * bottom_frac),
        )
    )


def background_color(image: Image.Image) -> tuple[int, int, int]:
    width, height = image.size
    sample = image.getpixel((width // 2, int(height * 0.16)))
    return tuple(max(0, channel - 8) for channel in sample[:3])


def format_for_instagram(source: Path, slide_label: str) -> Image.Image:
    original = Image.open(source).convert("RGB")
    cropped = crop_ui_card(original, source.name)
    cropped_width, cropped_height = cropped.size
    background = background_color(original)

    content_height = TARGET_H - 150
    content_width = TARGET_W - 60
    scale = min(content_width / cropped_width, content_height / cropped_height)
    resized_width = int(cropped_width * scale)
    resized_height = int(cropped_height * scale)
    resized = cropped.resize((resized_width, resized_height), Image.Resampling.LANCZOS)

    canvas = Image.new("RGB", (TARGET_W, TARGET_H), background)
    x_offset = (TARGET_W - resized_width) // 2
    y_offset = (TARGET_H - 150 - resized_height) // 2 + 10
    canvas.paste(resized, (x_offset, y_offset))

    draw = ImageDraw.Draw(canvas)
    draw.rectangle([(0, TARGET_H - 130), (TARGET_W, TARGET_H)], fill=(10, 14, 12))
    draw.rounded_rectangle(
        [(28, 28), (108, 68)],
        radius=14,
        fill=(30, 36, 32),
        outline=(255, 214, 90),
        width=2,
    )
    draw.text((68, 48), slide_label, fill=(255, 214, 90), font=SLIDE_FONT, anchor="mm")
    draw.text(
        (TARGET_W // 2, TARGET_H - 100),
        "Stepasaurus",
        fill=(255, 214, 90),
        font=TITLE_FONT,
        anchor="mm",
    )
    draw.text(
        (TARGET_W // 2, TARGET_H - 52),
        "Walk. Sync. Hatch.",
        fill=(210, 218, 212),
        font=SUB_FONT,
        anchor="mm",
    )
    return canvas


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Formatting Android-style IG carousel -> {OUTPUT_DIR}")

    for source_name, output_name, slide_label in CAROUSEL_ITEMS:
        source = SOURCE_DIR / source_name
        if not source.exists():
            raise SystemExit(f"Missing source screenshot: {source}")

        output = OUTPUT_DIR / f"stepasaurus-ig-{output_name}.png"
        formatted = format_for_instagram(source, slide_label)
        formatted.save(output, optimize=True)
        print(f"  {source.name} -> {output.relative_to(ROOT)}")

    print("Done.")


if __name__ == "__main__":
    main()
