import SwiftUI
import Foundation

// MARK: - Navigation Manager

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()

    @Published var showingPasswordReset = false
    @Published var showingForgotPassword = false
    @Published var passwordResetToken: String?

    private init() {}

    /// Show password reset screen with token
    func showPasswordReset(token: String) {
        DispatchQueue.main.async {
            self.passwordResetToken = token
            self.showingPasswordReset = true
        }
    }

    /// Show forgot password screen
    func showForgotPassword() {
        DispatchQueue.main.async {
            self.showingForgotPassword = true
        }
    }

    /// Navigate to login screen (dismiss current screens)
    func showLogin() {
        DispatchQueue.main.async {
            self.showingPasswordReset = false
            self.showingForgotPassword = false
            self.passwordResetToken = nil
        }
    }

    /// Handle deep link URLs
    func handleDeepLink(_ url: URL) {
        print("🔗 Handling deep link: \(url.absoluteString)")

        guard url.scheme == "torny" else {
            print("❌ Invalid URL scheme: \(url.scheme ?? "nil")")
            return
        }

        switch url.host {
        case "reset-password":
            handlePasswordResetLink(url)
        case "forgot-password":
            showForgotPassword()
        default:
            print("❌ Unknown deep link host: \(url.host ?? "nil")")
        }
    }

    private func handlePasswordResetLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let tokenItem = queryItems.first(where: { $0.name == "token" }),
              let token = tokenItem.value else {
            print("❌ Invalid password reset URL - no token found")
            return
        }

        print("✅ Found password reset token in deep link")
        showPasswordReset(token: token)
    }
}

// MARK: - Deep Link Helper

struct DeepLinkHandler {
    /// Create a password reset deep link URL
    static func createPasswordResetURL(token: String) -> URL? {
        var components = URLComponents()
        components.scheme = "torny"
        components.host = "reset-password"
        components.queryItems = [URLQueryItem(name: "token", value: token)]
        return components.url
    }

    /// Create a forgot password deep link URL
    static func createForgotPasswordURL() -> URL? {
        var components = URLComponents()
        components.scheme = "torny"
        components.host = "forgot-password"
        return components.url
    }
}