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
    let shortDescription: String?
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
    // Individual club fields from the API
    let clubId: Int?
    let clubName: String?
    let clubDescription: String?
    let clubAvatar: String?
    let clubBannerImage: String?
    let clubCountry: String?
    let clubState: String?
    let clubRegion: String?

    enum CodingKeys: String, CodingKey {
        case id, email, name
        case userType = "user_type"
        case phone, address, description
        case shortDescription = "short_description"
        case avatarUrl = "avatar_url"
        case bannerUrl = "banner_url"
        case created, updated
        case profileCompleted = "profile_completed"
        case club, sport, images, achievements
        case clubData = "club_data"
        case gender, country, state, region
        // Individual club fields
        case clubId = "club_id"
        case clubName = "club_name"
        case clubDescription = "club_description"
        case clubAvatar = "avatar"
        case clubBannerImage = "banner_image"
        case clubCountry = "club_country"
        case clubState = "club_state"
        case clubRegion = "club_region"
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
        shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        bannerUrl = try container.decodeIfPresent(String.self, forKey: .bannerUrl)
        created = try container.decodeIfPresent(String.self, forKey: .created)
        updated = try container.decodeIfPresent(String.self, forKey: .updated)
        profileCompleted = try container.decode(Int.self, forKey: .profileCompleted)
        club = try container.decodeIfPresent(String.self, forKey: .club)
        sport = try container.decodeIfPresent(String.self, forKey: .sport)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        region = try container.decodeIfPresent(String.self, forKey: .region)

        // Handle null or missing arrays
        images = try container.decodeIfPresent([String].self, forKey: .images) ?? []
        achievements = try container.decodeIfPresent([String].self, forKey: .achievements) ?? []

        // Try to decode club_data as a nested object first
        if let clubDataObject = try? container.decodeIfPresent(Club.self, forKey: .clubData) {
            clubData = clubDataObject
            // Set individual fields to nil when we have nested object
            clubId = nil
            clubName = nil
            clubDescription = nil
            clubAvatar = nil
            clubBannerImage = nil
            clubCountry = nil
            clubState = nil
            clubRegion = nil
        } else {
            // Otherwise decode individual club fields
            clubId = try container.decodeIfPresent(Int.self, forKey: .clubId)
            clubName = try container.decodeIfPresent(String.self, forKey: .clubName)
            clubDescription = try container.decodeIfPresent(String.self, forKey: .clubDescription)
            clubAvatar = try container.decodeIfPresent(String.self, forKey: .clubAvatar)
            clubBannerImage = try container.decodeIfPresent(String.self, forKey: .clubBannerImage)
            clubCountry = try container.decodeIfPresent(String.self, forKey: .clubCountry)
            clubState = try container.decodeIfPresent(String.self, forKey: .clubState)
            clubRegion = try container.decodeIfPresent(String.self, forKey: .clubRegion)

            // Create Club object from individual fields if we have them
            if let clubId = clubId, let clubName = clubName {
                clubData = Club(
                    id: clubId,
                    clubId: nil,
                    name: clubName,
                    location: nil,
                    logoUrl: nil,
                    bannerUrl: nil,
                    bannerImage: clubBannerImage,
                    avatar: clubAvatar,
                    websiteUrl: nil,
                    website: nil,
                    description: clubDescription,
                    sport: nil,
                    country: clubCountry,
                    state: clubState,
                    region: clubRegion,
                    latitude: nil,
                    longitude: nil,
                    email: nil,
                    phone: nil,
                    achievements: nil,
                    created: nil
                )
            } else {
                clubData = nil
            }
        }
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        // club_id is optional and may not be present in the response
        clubId = try container.decodeIfPresent(Int.self, forKey: .clubId)
        name = try container.decode(String.self, forKey: .name)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        logoUrl = try container.decodeIfPresent(String.self, forKey: .logoUrl)
        bannerUrl = try container.decodeIfPresent(String.self, forKey: .bannerUrl)
        bannerImage = try container.decodeIfPresent(String.self, forKey: .bannerImage)
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        websiteUrl = try container.decodeIfPresent(String.self, forKey: .websiteUrl)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        sport = try container.decodeIfPresent(String.self, forKey: .sport)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        latitude = try container.decodeIfPresent(String.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(String.self, forKey: .longitude)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        achievements = try container.decodeIfPresent([String].self, forKey: .achievements) ?? []
        created = try container.decodeIfPresent(String.self, forKey: .created)
    }

    init(id: Int, clubId: Int?, name: String, location: String?, logoUrl: String?, bannerUrl: String?, bannerImage: String?, avatar: String?, websiteUrl: String?, website: String?, description: String?, sport: String?, country: String?, state: String?, region: String?, latitude: String?, longitude: String?, email: String?, phone: String?, achievements: [String]?, created: String?) {
        self.id = id
        self.clubId = clubId
        self.name = name
        self.location = location
        self.logoUrl = logoUrl
        self.bannerUrl = bannerUrl
        self.bannerImage = bannerImage
        self.avatar = avatar
        self.websiteUrl = websiteUrl
        self.website = website
        self.description = description
        self.sport = sport
        self.country = country
        self.state = state
        self.region = region
        self.latitude = latitude
        self.longitude = longitude
        self.email = email
        self.phone = phone
        self.achievements = achievements
        self.created = created
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