#!/bin/bash

# Torny iOS - TestFlight Upload Script
# Uses App Store Connect API for authentication

set -e  # Exit on error

# Configuration
SCHEME="TornyiOS"
ARCHIVE_PATH="build/TornyiOS.xcarchive"
EXPORT_PATH="build"
IPA_PATH="build/TornyiOS.ipa"

# API Key Configuration
API_KEY_PATH="./private_keys/AuthKey.p8"
API_KEY_ID="XCP5QK9FN6"
API_ISSUER_ID="e0daaf16-785f-4b59-9583-e58a0755dda0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if API credentials are set
if [ -z "$API_KEY_ID" ] || [ -z "$API_ISSUER_ID" ]; then
    echo -e "${RED}❌ Error: API_KEY_ID and API_ISSUER_ID must be set in this script${NC}"
    echo -e "${YELLOW}Follow the setup instructions to get these values${NC}"
    exit 1
fi

# Check if API key file exists
if [ ! -f "$API_KEY_PATH" ]; then
    echo -e "${RED}❌ Error: API Key file not found at $API_KEY_PATH${NC}"
    echo -e "${YELLOW}Download your .p8 file from App Store Connect and place it there${NC}"
    exit 1
fi

echo -e "${BLUE}🏀 Torny iOS - TestFlight Upload${NC}"
echo "================================"

# Step 1: Clean build folder
echo -e "\n${YELLOW}🧹 Cleaning build folder...${NC}"
rm -rf build/

# Step 2: Increment build number
echo -e "\n${YELLOW}🔢 Incrementing build number...${NC}"
CURRENT_BUILD=$(xcrun agvtool what-version -terse)
xcrun agvtool next-version -all
NEW_BUILD=$(xcrun agvtool what-version -terse)
echo -e "${GREEN}Build number: $CURRENT_BUILD → $NEW_BUILD${NC}"

# Step 3: Collect build notes
echo -e "\n${YELLOW}📝 What to Test Notes (optional)${NC}"
echo -e "${BLUE}Enter notes for testers (press Enter to skip, Ctrl+D when done):${NC}"
echo -e "${BLUE}Example: Fixed login bug, added new analytics dashboard${NC}"
echo ""

# Read multi-line input
BUILD_NOTES=""
if read -t 5 -p "> " first_line; then
    if [ -n "$first_line" ]; then
        BUILD_NOTES="$first_line"
        while IFS= read -r line; do
            BUILD_NOTES="$BUILD_NOTES"$'\n'"$line"
        done
    fi
fi

# Save notes if provided
if [ -n "$BUILD_NOTES" ]; then
    mkdir -p build_notes
    echo "$BUILD_NOTES" > "build_notes/build_${NEW_BUILD}.txt"
    echo -e "${GREEN}✅ Notes saved to build_notes/build_${NEW_BUILD}.txt${NC}"
else
    echo -e "${YELLOW}Skipping build notes${NC}"
fi

# Step 4: Archive
echo -e "\n${YELLOW}📦 Archiving app...${NC}"
xcodebuild archive \
  -scheme "$SCHEME" \
  -archivePath "$ARCHIVE_PATH" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  CODE_SIGN_STYLE=Automatic \
  -allowProvisioningUpdates

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Archive failed${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Archive created successfully${NC}"

# Step 5: Export IPA
echo -e "\n${YELLOW}📤 Exporting IPA...${NC}"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist ExportOptions.plist \
  -allowProvisioningUpdates

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Export failed${NC}"
  exit 1
fi
echo -e "${GREEN}✅ IPA exported successfully${NC}"

# Step 6: Validate IPA (optional but recommended)
echo -e "\n${YELLOW}🔍 Validating IPA...${NC}"
xcrun altool --validate-app \
  --type ios \
  --file "$IPA_PATH" \
  --apiKey "$API_KEY_ID" \
  --apiIssuer "$API_ISSUER_ID"

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Validation failed${NC}"
  exit 1
fi
echo -e "${GREEN}✅ IPA validated successfully${NC}"

# Step 7: Upload to TestFlight
echo -e "\n${YELLOW}🚀 Uploading to TestFlight...${NC}"
echo -e "${BLUE}This may take several minutes...${NC}"
xcrun altool --upload-app \
  --type ios \
  --file "$IPA_PATH" \
  --apiKey "$API_KEY_ID" \
  --apiIssuer "$API_ISSUER_ID"

if [ $? -eq 0 ]; then
  echo -e "\n${GREEN}✅ Upload complete!${NC}"
  echo -e "${BLUE}Your build will appear in TestFlight in ~5-10 minutes after processing${NC}"
  echo -e "${BLUE}Check App Store Connect: https://appstoreconnect.apple.com${NC}"

  # Display build notes reminder if notes were provided
  if [ -n "$BUILD_NOTES" ]; then
    echo -e "\n${YELLOW}📝 Build Notes for Testers:${NC}"
    echo -e "${BLUE}─────────────────────────────${NC}"
    echo -e "${BUILD_NOTES}"
    echo -e "${BLUE}─────────────────────────────${NC}"
    echo -e "\n${YELLOW}💡 To add these notes to TestFlight:${NC}"
    echo -e "${BLUE}1. Go to App Store Connect → TestFlight${NC}"
    echo -e "${BLUE}2. Select build ${NEW_BUILD} (after it finishes processing)${NC}"
    echo -e "${BLUE}3. Add the notes above to 'What to Test'${NC}"
    echo -e "${BLUE}4. Or copy from: build_notes/build_${NEW_BUILD}.txt${NC}"
  fi
else
  echo -e "${RED}❌ Upload failed${NC}"
  exit 1
fi
