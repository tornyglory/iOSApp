import SwiftUI
import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var name = ""
    @Published var isLoading = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var isAuthenticated = false
    @Published var needsProfileSetup = false

    private let apiService = APIService.shared

    var isLoginFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }

    var isRegisterFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !name.isEmpty && password == confirmPassword
    }

    func login() async {
        guard isLoginFormValid else {
            alertMessage = "Please fill in all fields"
            showingAlert = true
            return
        }

        isLoading = true

        do {
            let request = LoginRequest(email: email, password: password)
            let response = try await apiService.login(request)

            let user = response.user
            let token = response.token

            apiService.setAuthToken(token)
            apiService.currentUser = user

            let userId = user.id
            UserDefaults.standard.set(String(userId), forKey: "current_user_id")

            isAuthenticated = true
            needsProfileSetup = user.profileCompleted != 1

            isLoading = false
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
            isLoading = false
        }
    }

    func register() async {
        guard isRegisterFormValid else {
            alertMessage = "Please fill in all fields and ensure passwords match"
            showingAlert = true
            return
        }

        guard validateEmail(email) else {
            alertMessage = "Please enter a valid email address"
            showingAlert = true
            return
        }

        guard password.count >= 8 else {
            alertMessage = "Password must be at least 8 characters"
            showingAlert = true
            return
        }

        isLoading = true

        do {
            let request = RegisterRequest(
                email: email,
                name: name,
                password: password,
                phone: nil,
                address: nil,
                description: nil,
                avatarUrl: nil,
                club: nil
            )

            let response = try await apiService.register(request)

            let user = response.user
            let token = response.token

            apiService.setAuthToken(token)
            apiService.currentUser = user

            let userId = user.id
            UserDefaults.standard.set(String(userId), forKey: "current_user_id")

            isAuthenticated = true
            needsProfileSetup = true

            isLoading = false
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
            isLoading = false
        }
    }

    func logout() {
        apiService.logout()

        email = ""
        password = ""
        confirmPassword = ""
        name = ""
        isAuthenticated = false
        needsProfileSetup = false
    }

    func resetPassword() async {
        guard validateEmail(email) else {
            alertMessage = "Please enter a valid email address"
            showingAlert = true
            return
        }

        isLoading = true

        do {
            let request = PasswordResetRequest(email: email)
            _ = try await apiService.resetPassword(request)

            alertMessage = "Password reset email sent. Please check your inbox."
            showingAlert = true
            isLoading = false
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
            isLoading = false
        }
    }

    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func checkAuthenticationStatus() {
        // Check if session is still valid
        if apiService.validateSession() {
            isAuthenticated = apiService.isAuthenticated
            if let user = apiService.currentUser {
                needsProfileSetup = user.profileCompleted != 1
            }
        } else {
            // Session expired, clear authentication
            logout()
        }
    }

    func getSessionTimeRemaining() -> String {
        let timeRemaining = apiService.sessionTimeRemaining()
        guard timeRemaining > 0 else { return "Session expired" }

        let days = Int(timeRemaining) / (24 * 60 * 60)
        let hours = Int(timeRemaining) % (24 * 60 * 60) / (60 * 60)

        if days > 0 {
            return "\(days) day\(days == 1 ? "" : "s")"
        } else if hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            return "Less than 1 hour"
        }
    }
}