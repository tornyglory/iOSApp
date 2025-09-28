#!/usr/bin/env python3

import os
from PIL import Image, ImageDraw, ImageFont
import sys

def create_gradient_background(width, height):
    """Create aqua to green gradient background"""
    image = Image.new('RGBA', (width, height))
    draw = ImageDraw.Draw(image)

    # Create gradient from aqua to green
    for y in range(height):
        # Calculate gradient ratio (0 to 1)
        ratio = y / height

        # Aqua RGB: (0, 255, 255) to Green RGB: (0, 204, 102)
        r = int(0 * (1 - ratio) + 0 * ratio)
        g = int(255 * (1 - ratio) + 204 * ratio)
        b = int(255 * (1 - ratio) + 102 * ratio)

        draw.line([(0, y), (width, y)], fill=(r, g, b, 255))

    return image

def add_trophy_emoji(image, size):
    """Add trophy emoji to the center of the image"""
    draw = ImageDraw.Draw(image)

    # Calculate font size based on image size (trophy should be about 60% of icon)
    font_size = int(size * 0.6)

    # Try multiple approaches to get emoji working
    font = None

    # First try: Apple Color Emoji (macOS)
    try:
        if sys.platform == "darwin":
            font = ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", font_size)
    except:
        pass

    # Second try: SF Pro (macOS)
    if font is None:
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
        except:
            pass

    # Third try: Use a different approach - draw a simple trophy shape
    if font is None:
        # Draw a simple trophy shape instead of emoji
        cup_color = (255, 215, 0)  # Gold color
        handle_color = (255, 215, 0)

        # Calculate trophy dimensions
        trophy_size = int(size * 0.6)
        center_x = size // 2
        center_y = size // 2

        # Cup bowl
        cup_width = int(trophy_size * 0.7)
        cup_height = int(trophy_size * 0.5)
        cup_left = center_x - cup_width // 2
        cup_top = center_y - cup_height // 2 - int(trophy_size * 0.1)

        # Draw cup bowl
        draw.ellipse([cup_left, cup_top, cup_left + cup_width, cup_top + cup_height],
                    fill=cup_color, outline=(200, 170, 0), width=3)

        # Cup handles
        handle_width = int(trophy_size * 0.15)
        handle_height = int(trophy_size * 0.3)

        # Left handle
        left_handle_x = cup_left - handle_width
        handle_y = cup_top + cup_height // 4
        draw.arc([left_handle_x, handle_y, left_handle_x + handle_width * 2, handle_y + handle_height],
                start=90, end=270, fill=handle_color, width=8)

        # Right handle
        right_handle_x = cup_left + cup_width - handle_width
        draw.arc([right_handle_x, handle_y, right_handle_x + handle_width * 2, handle_y + handle_height],
                start=270, end=90, fill=handle_color, width=8)

        # Cup base/stem
        stem_width = int(trophy_size * 0.2)
        stem_height = int(trophy_size * 0.25)
        stem_left = center_x - stem_width // 2
        stem_top = cup_top + cup_height

        draw.rectangle([stem_left, stem_top, stem_left + stem_width, stem_top + stem_height],
                      fill=cup_color, outline=(200, 170, 0), width=2)

        # Base plate
        base_width = int(trophy_size * 0.5)
        base_height = int(trophy_size * 0.1)
        base_left = center_x - base_width // 2
        base_top = stem_top + stem_height

        draw.rectangle([base_left, base_top, base_left + base_width, base_top + base_height],
                      fill=cup_color, outline=(200, 170, 0), width=2)

        return image

    # If we have a font, try to draw the emoji
    trophy = "🏆"

    # Calculate position to center the trophy
    try:
        bbox = draw.textbbox((0, 0), trophy, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]

        x = (size - text_width) // 2
        y = (size - text_height) // 2 - bbox[1]

        # Draw trophy with different approaches
        draw.text((x, y), trophy, font=font, fill=(255, 215, 0, 255))

    except:
        # Fallback: draw simple text
        draw.text((size//2 - 30, size//2 - 30), "🏆", font=font, fill=(255, 215, 0, 255))

    return image

def create_app_icon(size, output_path):
    """Create a single app icon of specified size"""
    # Create gradient background
    image = create_gradient_background(size, size)

    # Add trophy emoji
    image = add_trophy_emoji(image, size)

    # Save as PNG
    image.save(output_path, 'PNG')
    print(f"Created {size}x{size} icon: {output_path}")

def main():
    # Define all required icon sizes
    icon_sizes = [
        (20, "icon-20@1x.png"),
        (40, "icon-20@2x.png"),
        (60, "icon-20@3x.png"),
        (29, "icon-29@1x.png"),
        (58, "icon-29@2x.png"),
        (87, "icon-29@3x.png"),
        (40, "icon-40@1x.png"),
        (80, "icon-40@2x.png"),
        (120, "icon-40@3x.png"),
        (120, "icon-60@2x.png"),
        (180, "icon-60@3x.png"),
        (76, "icon-76@1x.png"),
        (152, "icon-76@2x.png"),
        (167, "icon-83.5@2x.png"),
        (1024, "icon-1024@1x.png")
    ]

    # Output directory
    output_dir = "/Users/nevrodda/Documents/torny_swift/TornyiOS/Assets.xcassets/AppIcon.appiconset/"

    # Create all icon sizes
    for size, filename in icon_sizes:
        output_path = os.path.join(output_dir, filename)
        create_app_icon(size, output_path)

    print(f"\n✅ All app icons created successfully!")
    print(f"Icons saved to: {output_dir}")

if __name__ == "__main__":
    main()