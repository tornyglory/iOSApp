import Foundation

// MARK: - Password Reset Service

class PasswordResetService: ObservableObject {
    private let baseURL = "https://ieg3lhlyy0.execute-api.ap-southeast-2.amazonaws.com/Prod"

    /// Request a password reset for the given email
    func requestPasswordReset(email: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/api/request-password-reset") else {
            throw PasswordResetError.invalidURL
        }

        let requestBody = ["email": email]

        do {
            let jsonData = try JSONEncoder().encode(requestBody)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PasswordResetError.invalidResponse
            }

            let responseData = try JSONDecoder().decode(PasswordResetResponse.self, from: data)

            if httpResponse.statusCode == 200 && responseData.status == "success" {
                return true
            } else {
                throw PasswordResetError.serverError(responseData.message)
            }
        } catch let error as PasswordResetError {
            throw error
        } catch {
            throw PasswordResetError.networkError
        }
    }

    /// Validate a reset token
    func validateResetToken(_ token: String) async throws -> TokenValidationResponse {
        guard let url = URL(string: "\(baseURL)/api/validate-reset-token?token=\(token)") else {
            throw PasswordResetError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PasswordResetError.invalidResponse
            }

            let responseData = try JSONDecoder().decode(TokenValidationResponse.self, from: data)

            if httpResponse.statusCode == 200 && responseData.status == "success" {
                return responseData
            } else {
                throw PasswordResetError.serverError(responseData.message)
            }
        } catch let error as PasswordResetError {
            throw error
        } catch {
            throw PasswordResetError.networkError
        }
    }

    /// Reset password with token and new password
    func resetPassword(token: String, newPassword: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/api/reset-password") else {
            throw PasswordResetError.invalidURL
        }

        let requestBody = [
            "token": token,
            "newPassword": newPassword
        ]

        do {
            let jsonData = try JSONEncoder().encode(requestBody)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PasswordResetError.invalidResponse
            }

            let responseData = try JSONDecoder().decode(PasswordResetResponse.self, from: data)

            if httpResponse.statusCode == 200 && responseData.status == "success" {
                return true
            } else {
                throw PasswordResetError.serverError(responseData.message)
            }
        } catch let error as PasswordResetError {
            throw error
        } catch {
            throw PasswordResetError.networkError
        }
    }
}

// MARK: - Response Models

struct PasswordResetResponse: Codable {
    let status: String
    let message: String
}

struct TokenValidationResponse: Codable {
    let status: String
    let message: String
    let data: TokenData?

    struct TokenData: Codable {
        let email: String
        let expiresAt: String
    }
}

// MARK: - Error Types

enum PasswordResetError: Error, LocalizedError {
    case serverError(String)
    case networkError
    case invalidResponse
    case invalidURL
    case invalidEmail
    case weakPassword
    case passwordMismatch

    var errorDescription: String? {
        switch self {
        case .serverError(let message):
            return message
        case .networkError:
            return "Network connection failed. Please check your internet connection and try again."
        case .invalidResponse:
            return "Invalid response from server. Please try again."
        case .invalidURL:
            return "Invalid request. Please try again."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Password must be at least 8 characters long."
        case .passwordMismatch:
            return "Passwords do not match."
        }
    }
}

// MARK: - Validation Helpers

extension PasswordResetService {
    /// Validate email format
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    /// Validate password strength
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8
    }

    /// Check if passwords match
    static func passwordsMatch(_ password: String, _ confirmPassword: String) -> Bool {
        return !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
    }
}