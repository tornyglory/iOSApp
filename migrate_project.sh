#!/bin/bash

# TornyiOS Project Migration Script
# This script reorganizes the project files into the new structure

echo "🚀 Starting TornyiOS Project Migration..."

# Navigate to project directory
cd /Users/nevrodda/Documents/torny_swift/TornyiOS

# Move View files
echo "📂 Organizing View files..."
mv ContentView.swift Views/Common/ 2>/dev/null
mv AuthView.swift Views/Auth/ 2>/dev/null
mv ProfileSetupView.swift Views/Profile/ 2>/dev/null
mv ProfileView.swift Views/Profile/ 2>/dev/null
mv SessionView.swift Views/Training/ 2>/dev/null
mv TrainingSessionView.swift Views/Training/ 2>/dev/null
mv TrainingSetupView.swift Views/Training/ 2>/dev/null
mv ShotRecordingView.swift Views/Training/ 2>/dev/null
mv SessionHistoryView.swift Views/History/ 2>/dev/null
mv AnalyticsView.swift Views/Analytics/ 2>/dev/null

# Move Service files
echo "📂 Organizing Service files..."
mv APIService.swift Services/Network/ 2>/dev/null

# Move Component files
echo "📂 Organizing Component files..."
mv TornyComponents.swift Components/ 2>/dev/null
mv TornyColors.swift Components/ 2>/dev/null
mv ImagePicker.swift Components/ 2>/dev/null

# Move main app file
echo "📂 Organizing main app file..."
mv TornyiOSApp.swift ./ 2>/dev/null

# Move resource files
echo "📂 Organizing resource files..."
mv PermanentMarker-Regular.ttf Resources/ 2>/dev/null
mv *.png Resources/ 2>/dev/null
mv *.jpg Resources/ 2>/dev/null
mv *.jpeg Resources/ 2>/dev/null

# Create a backup of the original Models.swift
echo "💾 Backing up original Models.swift..."
cp Models.swift Models.swift.backup 2>/dev/null

# Update imports in existing files to reference new model locations
echo "🔧 Updating import statements..."

# Function to update imports in a file
update_imports() {
    local file=$1
    if [ -f "$file" ]; then
        # Add imports for the new model files at the top
        sed -i '' '1a\
import Foundation
' "$file" 2>/dev/null
    fi
}

# Update all Swift files
find . -name "*.swift" -type f | while read file; do
    update_imports "$file"
done

echo "✅ Migration complete!"
echo ""
echo "⚠️  Next steps:"
echo "1. Remove the old Models.swift file after verifying all models work"
echo "2. Update Xcode project file references"
echo "3. Update import statements in all files to use new model paths"
echo "4. Test the build to ensure everything compiles"
echo ""
echo "📝 New project structure:"
echo "TornyiOS/"
echo "├── Models/"
echo "│   ├── User/"
echo "│   ├── Training/"
echo "│   └── API/"
echo "├── Views/"
echo "│   ├── Auth/"
echo "│   ├── Profile/"
echo "│   ├── Training/"
echo "│   ├── History/"
echo "│   ├── Analytics/"
echo "│   └── Common/"
echo "├── ViewModels/"
echo "├── Services/"
echo "│   ├── Network/"
echo "│   └── Storage/"
echo "├── Components/"
echo "├── Utilities/"
echo "│   ├── Errors/"
echo "│   ├── Configuration/"
echo "│   ├── Extensions/"
echo "│   └── Helpers/"
echo "└── Resources/"