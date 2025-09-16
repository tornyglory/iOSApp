# Adding Permanent Marker Font to Torny iOS App

## Steps to Add Custom Font:

1. **Download Permanent Marker Font**
   - Go to Google Fonts: https://fonts.google.com/specimen/Permanent+Marker
   - Download the font file (PermanentMarker-Regular.ttf)

2. **Add Font to Xcode Project**
   - Drag the .ttf file into your Xcode project
   - Make sure "Add to target" is checked for your app target
   - Choose "Create groups" (not folder references)

3. **Update Info.plist**
   - Add the following key to your Info.plist:
   ```xml
   <key>UIAppFonts</key>
   <array>
       <string>PermanentMarker-Regular.ttf</string>
   </array>
   ```

4. **Font Usage in Code**
   The code is already set up to use Permanent Marker. Once you add the font file, these will work:
   - `Font.custom("Permanent Marker", size: 32)`
   - The logo uses the system font as a fallback until you add the custom font

## Current Fallback
The app currently uses `.rounded` system font with `.black` weight as a close approximation to Permanent Marker's bold, casual style.

## Alternative Approach
If you can't add custom fonts, you can use the current system font fallback which provides a bold, rounded appearance similar to the Permanent Marker style.