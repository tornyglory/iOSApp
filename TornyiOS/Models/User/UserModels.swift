import Foundation

// MARK: - API Response Wrappers

struct ProfileResponse: Codable {
    let status: String
    let data: User
}

// MARK: - User Model

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let name: String
    let userType: String
    let phone: String?
    let address: String?
    let description: String?
    let avatarUrl: String?
    let bannerUrl: String?
    let created: String?
    let updated: String?
    let profileCompleted: Int
    let club: String?
    let sport: String?
    let images: [String]?
    let achievements: [String]?
    let clubData: Club?
    let gender: String?
    let country: String?
    let state: String?
    let region: String?

    enum CodingKeys: String, CodingKey {
        case id, email, name
        case userType = "user_type"
        case phone, address, description
        case avatarUrl = "avatar_url"
        case bannerUrl = "banner_url"
        case created, updated
        case profileCompleted = "profile_completed"
        case club, sport, images, achievements
        case clubData = "club_data"
        case gender, country, state, region
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        userType = try container.decode(String.self, forKey: .userType)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        bannerUrl = try container.decodeIfPresent(String.self, forKey: .bannerUrl)
        created = try container.decodeIfPresent(String.self, forKey: .created)
        updated = try container.decodeIfPresent(String.self, forKey: .updated)
        profileCompleted = try container.decode(Int.self, forKey: .profileCompleted)
        club = try container.decodeIfPresent(String.self, forKey: .club)
        sport = try container.decodeIfPresent(String.self, forKey: .sport)
        clubData = try container.decodeIfPresent(Club.self, forKey: .clubData)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        region = try container.decodeIfPresent(String.self, forKey: .region)

        // Handle null or missing arrays
        images = try container.decodeIfPresent([String].self, forKey: .images) ?? []
        achievements = try container.decodeIfPresent([String].self, forKey: .achievements) ?? []
    }

    // Computed properties for backwards compatibility
    var firstName: String {
        let components = name.components(separatedBy: " ")
        return components.first ?? name
    }

    var lastName: String {
        let components = name.components(separatedBy: " ")
        return components.count > 1 ? components.dropFirst().joined(separator: " ") : ""
    }
}

// MARK: - Club Model

struct Club: Codable, Identifiable {
    let id: Int
    let clubId: Int?
    let name: String
    let location: String?
    let logoUrl: String?
    let bannerUrl: String?
    let bannerImage: String?
    let avatar: String?
    let websiteUrl: String?
    let website: String?
    let description: String?
    let sport: String?
    let country: String?
    let state: String?
    let region: String?
    let latitude: String?
    let longitude: String?
    let email: String?
    let phone: String?
    let achievements: [String]?
    let created: String?

    enum CodingKeys: String, CodingKey {
        case id
        case clubId = "club_id"
        case name, location, sport
        case logoUrl = "logo_url"
        case bannerUrl = "banner_url"
        case bannerImage = "banner_image"
        case avatar
        case websiteUrl = "website_url"
        case website
        case description
        case country, state, region
        case latitude, longitude
        case email, phone
        case achievements
        case created
    }

    // Computed property to get the best available banner image
    var displayBannerUrl: String? {
        return bannerImage ?? bannerUrl
    }

    // Computed property to get the best available logo
    var displayLogoUrl: String? {
        return avatar ?? logoUrl
    }
}