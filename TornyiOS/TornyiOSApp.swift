import SwiftUI
import Foundation

@main
struct TornyiOSApp: App {
    @StateObject private var navigationManager = NavigationManager.shared

    init() {
        loadCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationManager)
                .onOpenURL { url in
                    navigationManager.handleDeepLink(url)
                }
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
