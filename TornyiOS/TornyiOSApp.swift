import SwiftUI
import Foundation

@main
struct TornyiOSApp: App {
    init() {
        loadCustomFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func loadCustomFonts() {
        guard let fontPath = Bundle.main.path(forResource: "PermanentMarker-Regular", ofType: "ttf"),
              let fontData = NSData(contentsOfFile: fontPath),
              let dataProvider = CGDataProvider(data: fontData),
              let cgFont = CGFont(dataProvider) else {
            print("❌ Failed to load PermanentMarker font from bundle")
            return
        }
        
        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(cgFont, &error) {
            print("✅ PermanentMarker font registered successfully")
        } else {
            print("❌ Font registration failed: \(error?.takeUnretainedValue().localizedDescription ?? "Unknown error")")
        }
    }
}
