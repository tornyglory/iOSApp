import Foundation

// MARK: - App Configuration

enum Environment {
    case development
    case staging
    case production

    var baseURL: String {
        switch self {
        case .development:
            return "https://ieg3lhlyy0.execute-api.ap-southeast-2.amazonaws.com/Prod"
        case .staging:
            return "https://ieg3lhlyy0.execute-api.ap-southeast-2.amazonaws.com/Staging"
        case .production:
            return "https://ieg3lhlyy0.execute-api.ap-southeast-2.amazonaws.com/Prod"
        }
    }

    var apiPath: String {
        return "/api"
    }

    var isDebugEnabled: Bool {
        switch self {
        case .development, .staging:
            return true
        case .production:
            return false
        }
    }
}

class AppConfiguration {
    static let shared = AppConfiguration()

    private init() {}

    // Current environment - can be changed based on build configuration
    #if DEBUG
    let currentEnvironment: Environment = .development
    #else
    let currentEnvironment: Environment = .production
    #endif

    var baseURL: String {
        return currentEnvironment.baseURL
    }

    var apiURL: String {
        return currentEnvironment.baseURL + currentEnvironment.apiPath
    }

    var isDebugEnabled: Bool {
        return currentEnvironment.isDebugEnabled
    }

    // App Info
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // Feature Flags
    var isOfflineModeEnabled: Bool = false
    var isAnalyticsEnabled: Bool = true
    var isCrashReportingEnabled: Bool = true

    // API Configuration
    var apiTimeout: TimeInterval = 30.0
    var maxRetryAttempts: Int = 3
    var cacheExpirationTime: TimeInterval = 300 // 5 minutes

    // UI Configuration
    var maxProfileImageSize: Int = 5 * 1024 * 1024 // 5MB
    var supportedImageFormats = ["jpg", "jpeg", "png", "heic"]
    var defaultPageSize: Int = 20

    // Validation Rules
    var minPasswordLength: Int = 8
    var maxNameLength: Int = 100
    var maxDescriptionLength: Int = 500
    var phoneNumberRegex = "^[+]?[0-9]{10,15}$"
    var emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
}