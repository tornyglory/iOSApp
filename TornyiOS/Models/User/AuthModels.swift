import Foundation

// MARK: - Authentication Request Models

struct RegisterRequest: Codable {
    let email: String
    let name: String
    let password: String
    let sport: String = "Lawn Bowls"
    let accountType: String = "player"
    let membershipType: String = "founder"
    let phone: String?
    let address: String?
    let description: String?
    let avatarUrl: String?
    let club: String?
    let achievements: [String] = []
    let gender: String?
    let country: String?
    let state: String?
    let region: String?

    enum CodingKeys: String, CodingKey {
        case email, name, password, sport, phone, address, description, club, achievements
        case accountType = "account_type"
        case membershipType = "membership_type"
        case avatarUrl = "avatar_url"
        case gender, country, state, region
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct ProfileUpdateRequest: Codable {
    let userId: Int
    let email: String?
    let name: String?
    let userType: String?
    let phone: String?
    let address: String?
    let description: String?
    let avatarUrl: String?
    let bannerUrl: String?
    let club: String?
    let sport: String?
    let profileCompleted: Int?
    let gender: String?
    let country: String?
    let state: String?
    let region: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email, name, phone, address, description, club, sport
        case userType = "user_type"
        case avatarUrl = "avatar_url"
        case bannerUrl = "banner_url"
        case profileCompleted = "profile_completed"
        case gender, country, state, region
    }
}

// MARK: - Authentication Response Models

struct AuthResponse: Codable {
    let status: String
    let message: String
    let user: User?
    let token: String?
}

struct PasswordResetRequest: Codable {
    let email: String
}

struct PasswordResetResponse: Codable {
    let status: String
    let message: String
}

struct TokenValidationResponse: Codable {
    let status: String
    let message: String
    let valid: Bool?
}

struct UserListResponse: Codable {
    let status: String
    let users: [User]
}

struct ProfileUpdateResponse: Codable {
    let status: String?
    let message: String?
    let user: User?
}

struct ClubListResponse: Codable {
    let status: String
    let clubs: [Club]
}

struct ClubCreateResponse: Codable {
    let status: String
    let message: String
    let club: Club?
}