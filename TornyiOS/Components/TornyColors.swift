import SwiftUI
import Foundation
import UIKit

extension Color {
    // MARK: - Torny Brand Colors
    
    // Primary Colors
    static let tornyBlue = Color(hex: "2563EB")      // Blue-600
    static let tornyDarkBlue = Color(hex: "1E40AF")  // Blue-800
    static let tornyLightBlue = Color(hex: "DBEAFE") // Blue-100
    static let tornySkyBlue = Color(hex: "87CEEB")   // Sky Blue
    
    // Accent Colors
    static let tornyPurple = Color(hex: "7C3AED")    // Purple-600
    static let tornyDarkPurple = Color(hex: "6B21A8") // Purple-800
    static let tornyGreen = Color(hex: "16A34A")     // Green-600
    
    // Neutral Colors
    static let tornyTextPrimary = Color(hex: "1E293B")    // Slate-800
    static let tornyTextSecondary = Color(hex: "475569")  // Slate-600
    static let tornyBackgroundLight = Color(hex: "F8FAFC") // Slate-50
    
    // Gradient Colors
    static let tornyGradientTop = Color(hex: "87CEEB")    // Sky Blue
    static let tornyGradientMiddle = Color(hex: "98D8E8") // Light Sky
    static let tornyGradientBottom = Color(hex: "B0E0E6") // Powder Blue
    static let tornyGradientPale = Color(hex: "E0F6FF")   // Pale Cyan
    
    // Helper initializer for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    // MARK: - Torny Brand Colors for UIKit
    
    static let tornyBlue = UIColor(hex: "2563EB")
    static let tornyDarkBlue = UIColor(hex: "1E40AF")
    static let tornyLightBlue = UIColor(hex: "DBEAFE")
    static let tornySkyBlue = UIColor(hex: "87CEEB")
    static let tornyPurple = UIColor(hex: "7C3AED")
    static let tornyDarkPurple = UIColor(hex: "6B21A8")
    static let tornyGreen = UIColor(hex: "16A34A")
    static let tornyTextPrimary = UIColor(hex: "1E293B")
    static let tornyTextSecondary = UIColor(hex: "475569")
    static let tornyBackgroundLight = UIColor(hex: "F8FAFC")
    
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

// MARK: - Torny Gradients

struct TornyGradients {
    static let skyGradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: .tornyGradientTop, location: 0.0),
            .init(color: .tornyGradientMiddle, location: 0.5),
            .init(color: .tornyGradientBottom, location: 0.8),
            .init(color: .tornyGradientPale, location: 1.0)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [.tornyBlue, .tornyDarkBlue]),
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Torny Typography

struct TornyFonts {
    // Headers - using system font with bold weight for iOS consistency
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)
    static let title2 = Font.system(size: 22, weight: .bold, design: .default)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
    
    // Body Text
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySecondary = Font.system(size: 14, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    
    // Button Text
    static let button = Font.system(size: 16, weight: .semibold, design: .default)
    static let buttonLarge = Font.system(size: 18, weight: .semibold, design: .default)
    
    // Brand Typography - using custom Permanent Marker font
    static let brandTitle = Font.custom("PermanentMarker-Regular", size: 32)
    static let brandLarge = Font.custom("PermanentMarker-Regular", size: 28)
    static let brandMedium = Font.custom("PermanentMarker-Regular", size: 24)

    // Fallback brand fonts (if custom font fails)
    static let brandTitleFallback = Font.system(size: 32, weight: .black, design: .rounded)
    static let brandLargeFallback = Font.system(size: 28, weight: .black, design: .rounded)
    static let brandMediumFallback = Font.system(size: 24, weight: .black, design: .rounded)
}