import Foundation

// MARK: - Centralized Error System

enum TornyError: LocalizedError {
    // Network Errors
    case networkError(String)
    case apiError(statusCode: Int, message: String)
    case decodingError(String)
    case encodingError(String)
    case urlError(String)
    case unauthorized
    case serverError
    case noInternetConnection

    // Validation Errors
    case validationError(field: String, message: String)
    case emptyField(field: String)
    case invalidEmail
    case invalidPhone
    case passwordTooShort
    case passwordMismatch

    // Business Logic Errors
    case userNotFound
    case sessionNotFound
    case shotNotRecorded
    case profileNotComplete
    case clubNotFound
    case invalidSessionState

    // Storage Errors
    case dataNotFound
    case saveFailed
    case deleteFailed

    var errorDescription: String? {
        switch self {
        // Network Errors
        case .networkError(let message):
            return "Network Error: \(message)"
        case .apiError(_, let message):
            return message
        case .decodingError(let message):
            return "Data Error: \(message)"
        case .encodingError(let message):
            return "Encoding Error: \(message)"
        case .urlError(let message):
            return "URL Error: \(message)"
        case .unauthorized:
            return "Your session has expired. Please log in again."
        case .serverError:
            return "Server error. Please try again later."
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."

        // Validation Errors
        case .validationError(_, let message):
            return message
        case .emptyField(let field):
            return "\(field) cannot be empty"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .invalidPhone:
            return "Please enter a valid phone number"
        case .passwordTooShort:
            return "Password must be at least 8 characters"
        case .passwordMismatch:
            return "Passwords do not match"

        // Business Logic Errors
        case .userNotFound:
            return "User not found"
        case .sessionNotFound:
            return "Training session not found"
        case .shotNotRecorded:
            return "Failed to record shot"
        case .profileNotComplete:
            return "Please complete your profile first"
        case .clubNotFound:
            return "Club not found"
        case .invalidSessionState:
            return "Invalid session state"

        // Storage Errors
        case .dataNotFound:
            return "Data not found"
        case .saveFailed:
            return "Failed to save data"
        case .deleteFailed:
            return "Failed to delete data"
        }
    }

    var failureReason: String? {
        switch self {
        case .apiError(let statusCode, _):
            return "HTTP Status Code: \(statusCode)"
        default:
            return nil
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unauthorized:
            return "Please log in again to continue."
        case .noInternetConnection:
            return "Check your internet connection and try again."
        case .serverError:
            return "The server is experiencing issues. Please try again in a few minutes."
        case .passwordTooShort:
            return "Use a password with at least 8 characters including letters and numbers."
        default:
            return nil
        }
    }
}