#!/bin/bash

# Create app icons from torny_thumbnail.png
# This script uses sips (built into macOS) to resize the source image

SOURCE_IMAGE="torny_thumbnail.png"
OUTPUT_DIR="TornyiOS/Assets.xcassets/AppIcon.appiconset"

# Check if source image exists
if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "Error: Source image '$SOURCE_IMAGE' not found"
    exit 1
fi

echo "Creating app icons from $SOURCE_IMAGE..."

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Generate each icon size
generate_icon() {
    local filename=$1
    local size=$2
    local output_path="$OUTPUT_DIR/$filename"

    echo "Generating $filename (${size}x${size})..."
    sips -z "$size" "$size" "$SOURCE_IMAGE" --out "$output_path" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "✓ Created $filename"
    else
        echo "✗ Failed to create $filename"
    fi
}

# Icon sizes for iOS
generate_icon "icon-20.png" "20"
generate_icon "icon-20@2x.png" "40"
generate_icon "icon-20@3x.png" "60"
generate_icon "icon-29.png" "29"
generate_icon "icon-29@2x.png" "58"
generate_icon "icon-29@3x.png" "87"
generate_icon "icon-40.png" "40"
generate_icon "icon-40@2x.png" "80"
generate_icon "icon-40@3x.png" "120"
generate_icon "icon-60@2x.png" "120"
generate_icon "icon-60@3x.png" "180"
generate_icon "icon-76.png" "76"
generate_icon "icon-76@2x.png" "152"
generate_icon "icon-83.5@2x.png" "167"
generate_icon "icon-1024.png" "1024"

echo ""
echo "App icon generation complete!"
echo "Icons saved to: $OUTPUT_DIR"
