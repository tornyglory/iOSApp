import Foundation
import Foundation

// MARK: - Error Response

struct ErrorResponse: Codable {
    let status: String?
    let message: String?
}

// MARK: - API Response Wrappers

struct ProfileResponse: Codable {
    let status: String
    let data: User
}

// MARK: - User Models

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
    let images: [String] = []
    
    enum CodingKeys: String, CodingKey {
        case email
        case name
        case password
        case sport
        case accountType = "account_type"
        case membershipType = "membership_type"
        case phone
        case address
        case description
        case avatarUrl = "avatar_url"
        case club
        case achievements
        case images
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct UpdateProfileRequest: Codable {
    let firstName: String
    let lastName: String
    let phone: String?
    let dateOfBirth: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case phone
        case dateOfBirth = "date_of_birth"
    }
}

struct AuthResponse: Codable {
    let status: String
    let message: String
    let token: String
    let user: User
}

struct RegisterResponse: Codable {
    let status: String
    let message: String
    let token: String?
    let user: User?
}

struct PasswordResetRequest: Codable {
    let email: String
}

// MARK: - Profile Models
struct ProfileUpdateRequest: Codable {
    let name: String
    let email: String
    let phone: String
    let gender: String
    let description: String
    let shortDescription: String
    let avatarUrl: String?
    let bannerUrl: String?
    let avatarBase64: String?
    let bannerBase64: String?
    let country: String
    let state: String
    let region: String
    let sport: String = "Lawn Bowls"
    let sportId: Int = 1
    let club: String
    let clubId: String
    let profileCompleted: Int = 1

    enum CodingKeys: String, CodingKey {
        case name, email, phone, gender, description
        case shortDescription = "short_description"
        case avatarUrl = "avatar_url"
        case bannerUrl = "banner_url"
        case avatarBase64 = "avatar_base64"
        case bannerBase64 = "banner_base64"
        case country, state, region, sport
        case sportId = "sport_id"
        case club
        case clubId = "club_id"
        case profileCompleted = "profile_completed"
    }
}

struct Club: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let avatar: String
    let bannerImage: String
    let country: String
    let state: String
    let region: String

    enum CodingKeys: String, CodingKey {
        case id
        case name, description, avatar
        case bannerImage = "banner_image"
        case country, state, region
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try to decode id from either "id" or "club_id"
        if let idValue = try? container.decode(Int.self, forKey: .id) {
            id = idValue
        } else if let clubIdValue = try? decoder.container(keyedBy: AlternativeCodingKeys.self).decode(Int.self, forKey: .clubId) {
            id = clubIdValue
        } else {
            throw DecodingError.keyNotFound(CodingKeys.id, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Neither 'id' nor 'club_id' found"))
        }

        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        avatar = try container.decode(String.self, forKey: .avatar)
        bannerImage = try container.decode(String.self, forKey: .bannerImage)
        country = try container.decode(String.self, forKey: .country)
        state = try container.decode(String.self, forKey: .state)
        region = try container.decode(String.self, forKey: .region)
    }

    enum AlternativeCodingKeys: String, CodingKey {
        case clubId = "club_id"
    }
    
    // Computed property for string ID compatibility
    var stringId: String {
        return String(id)
    }

    // Computed property to get the banner image URL
    var displayBannerUrl: String? {
        return bannerImage.isEmpty ? nil : bannerImage
    }

    // Computed property to get the logo URL
    var displayLogoUrl: String? {
        return avatar.isEmpty ? nil : avatar
    }
}

struct ClubsSearchResponse: Codable {
    let status: String
    let data: [Club]
}

struct UpdateProfileResponse: Codable {
    let status: String
    let message: String?
    let data: ProfileUpdateData?

    struct ProfileUpdateData: Codable {
        let avatarUrl: String?
        let bannerUrl: String?

        enum CodingKeys: String, CodingKey {
            case avatarUrl = "avatar_url"
            case bannerUrl = "banner_url"
        }
    }
}

// MARK: - Enums

enum Location: String, CaseIterable, Codable {
    case indoor = "indoor"
    case outdoor = "outdoor"
}

enum GreenType: String, CaseIterable, Codable {
    case couch = "couch"
    case tift = "tift"
    case bent = "bent"
    case grass = "grass"
    case synthetic = "synthetic"
    case carpet = "carpet"
}

enum Weather: String, CaseIterable, Codable {
    case cold = "cold"
    case warm = "warm"
    case hot = "hot"
}

enum WindConditions: String, CaseIterable, Codable {
    case noWind = "no_wind"
    case light = "light"
    case moderate = "moderate"
    case strong = "strong"
}

enum ShotType: String, CaseIterable, Codable {
    case draw = "draw"
    case yardOn = "yard_on"
    case ditchWeight = "ditch_weight"
    case drive = "drive"
}

enum Hand: String, CaseIterable, Codable {
    case forehand = "forehand"
    case backhand = "backhand"
}

enum Length: String, CaseIterable, Codable {
    case short = "short"
    case medium = "medium"
    case long = "long"
}

enum DistanceFromJack: String, CaseIterable, Codable {
    case foot = "foot"
    case yard = "yard"
    case miss = "miss"
}

// MARK: - Request Models

struct EquipmentData: Codable {
    let bowlsBrand: String?
    let bowlsModel: String?
    let size: Int?
    let biasType: String?
    let bag: String?
    let shoes: String?
    let accessories: [String]?
    let stickUsed: Bool?

    enum CodingKeys: String, CodingKey {
        case bowlsBrand = "bowls_brand"
        case bowlsModel = "bowls_model"
        case size
        case biasType = "bias_type"
        case bag
        case shoes
        case accessories
        case stickUsed = "stick_used"
    }
}

// Equipment details for a session (response model)
struct SessionEquipment: Codable {
    let size: Int?
    let biasType: String?
    let stickUsed: Bool?
    let bowlsBrand: String?
    let bowlsModel: String?

    enum CodingKeys: String, CodingKey {
        case size
        case biasType = "bias_type"
        case stickUsed = "stick_used"
        case bowlsBrand = "bowls_brand"
        case bowlsModel = "bowls_model"
    }
}

struct CreateSessionRequest: Codable {
    let location: Location
    let greenType: GreenType
    let greenSpeed: Int
    let rinkNumber: Int?
    let weather: Weather?
    let windConditions: WindConditions?
    let notes: String?
    let equipment: EquipmentData?
    let clubId: Int?

    enum CodingKeys: String, CodingKey {
        case location
        case greenType = "green_type"
        case greenSpeed = "green_speed"
        case rinkNumber = "rink_number"
        case weather
        case windConditions = "wind_conditions"
        case notes
        case equipment
        case clubId = "club_id"
    }
}

struct RecordShotRequest: Codable {
    let sessionId: Int
    let shotType: ShotType
    let hand: Hand
    let length: Length
    let distanceFromJack: DistanceFromJack
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case shotType = "shot_type"
        case hand
        case length
        case distanceFromJack = "distance_from_jack"
        case notes
    }
}

struct EndSessionRequest: Codable {
    let endedAt: String         // Required - ISO string
    let durationSeconds: Int    // Required - seconds
    let notes: String?          // Optional - session notes

    enum CodingKeys: String, CodingKey {
        case endedAt = "ended_at"
        case durationSeconds = "duration_seconds"
        case notes
    }
}

// MARK: - Core Models

struct TrainingSession: Codable, Identifiable {
    let id: Int
    let playerId: Int
    let sport: String
    let sessionDate: Date
    let location: Location
    let greenType: GreenType
    let greenSpeed: Int
    let rinkNumber: Int?
    let weather: Weather?
    let windConditions: WindConditions?
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
    let totalShots: Int?
    let _drawShots: String?
    let _weightedShots: String?
    let drawAccuracy: Double?
    let weightedAccuracy: Double?
    let overallAccuracy: Double?
    let startedAt: Date?
    let endedAt: Date?
    let durationSeconds: Int?
    let _isActive: Int?

    // New fields from updated API
    let _totalPoints: String?
    let _averageScore: String?
    let _accuracyPercentage: String?
    let _yardOnShots: String?
    let yardOnAccuracy: Double?
    let _ditchWeightShots: String?
    let ditchWeightAccuracy: Double?
    let _driveShots: String?
    let driveAccuracy: Double?

    // Club details
    let clubId: Int?
    let clubName: String?
    let clubDescription: String?

    // Equipment details
    let equipment: SessionEquipment?

    // Training program details (if session is from a program)
    let programId: Int?
    let programTitle: String?


    // Computed property to convert MySQL TINYINT (0/1) to Bool
    var isActive: Bool? {
        guard let value = _isActive else { return nil }
        return value == 1
    }

    // Computed properties to convert string values to integers/doubles for compatibility
    var drawShots: Int? {
        guard let value = _drawShots else { return nil }
        return Int(value)
    }

    var weightedShots: Int? {
        guard let value = _weightedShots else { return nil }
        return Int(value)
    }

    var totalPoints: Int? {
        guard let value = _totalPoints else { return nil }
        return Int(value)
    }

    var averageScore: Double? {
        guard let value = _averageScore else { return nil }
        return Double(value)
    }

    var accuracyPercentage: Double? {
        guard let value = _accuracyPercentage else { return nil }
        return Double(value)
    }

    var yardOnShots: Int? {
        guard let value = _yardOnShots else { return nil }
        return Int(value)
    }

    var ditchWeightShots: Int? {
        guard let value = _ditchWeightShots else { return nil }
        return Int(value)
    }

    var driveShots: Int? {
        guard let value = _driveShots else { return nil }
        return Int(value)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case playerId = "player_id"
        case sport
        case sessionDate = "session_date"
        case location
        case greenType = "green_type"
        case greenSpeed = "green_speed"
        case rinkNumber = "rink_number"
        case weather
        case windConditions = "wind_conditions"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case totalShots = "total_shots"
        case _drawShots = "draw_shots"
        case _weightedShots = "weighted_shots"
        case drawAccuracy = "draw_accuracy"
        case weightedAccuracy = "weighted_accuracy"
        case overallAccuracy = "overall_accuracy"
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case durationSeconds = "duration_seconds"
        case _isActive = "is_active"
        case _totalPoints = "total_points"
        case _averageScore = "average_score"
        case _accuracyPercentage = "accuracy_percentage"
        case _yardOnShots = "yard_on_shots"
        case yardOnAccuracy = "yard_on_accuracy"
        case _ditchWeightShots = "ditch_weight_shots"
        case ditchWeightAccuracy = "ditch_weight_accuracy"
        case _driveShots = "drive_shots"
        case driveAccuracy = "drive_accuracy"
        case clubId = "club_id"
        case clubName = "club_name"
        case clubDescription = "club_description"
        case equipment
        case programId = "program_id"
        case programTitle = "program_title"
    }

    // Memberwise initializer for preview/test purposes
    init(id: Int, playerId: Int, sport: String, sessionDate: Date, location: Location, greenType: GreenType, greenSpeed: Int, rinkNumber: Int?, weather: Weather?, windConditions: WindConditions?, notes: String?, createdAt: Date, updatedAt: Date, totalShots: Int?, _drawShots: String?, _weightedShots: String?, drawAccuracy: Double?, weightedAccuracy: Double?, overallAccuracy: Double?, startedAt: Date?, endedAt: Date?, durationSeconds: Int?, _isActive: Int?, _totalPoints: String?, _averageScore: String?, _accuracyPercentage: String?, _yardOnShots: String?, yardOnAccuracy: Double?, _ditchWeightShots: String?, ditchWeightAccuracy: Double?, _driveShots: String?, driveAccuracy: Double?, clubId: Int? = nil, clubName: String? = nil, clubDescription: String? = nil, equipment: SessionEquipment? = nil, programId: Int? = nil, programTitle: String? = nil) {
        self.id = id
        self.playerId = playerId
        self.sport = sport
        self.sessionDate = sessionDate
        self.location = location
        self.greenType = greenType
        self.greenSpeed = greenSpeed
        self.rinkNumber = rinkNumber
        self.weather = weather
        self.windConditions = windConditions
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.totalShots = totalShots
        self._drawShots = _drawShots
        self._weightedShots = _weightedShots
        self.drawAccuracy = drawAccuracy
        self.weightedAccuracy = weightedAccuracy
        self.overallAccuracy = overallAccuracy
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationSeconds = durationSeconds
        self._isActive = _isActive
        self._totalPoints = _totalPoints
        self._averageScore = _averageScore
        self._accuracyPercentage = _accuracyPercentage
        self._yardOnShots = _yardOnShots
        self.yardOnAccuracy = yardOnAccuracy
        self._ditchWeightShots = _ditchWeightShots
        self.ditchWeightAccuracy = ditchWeightAccuracy
        self._driveShots = _driveShots
        self.driveAccuracy = driveAccuracy
        self.clubId = clubId
        self.clubName = clubName
        self.clubDescription = clubDescription
        self.equipment = equipment
        self.programId = programId
        self.programTitle = programTitle
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        playerId = try container.decode(Int.self, forKey: .playerId)
        sport = try container.decode(String.self, forKey: .sport)
        location = try container.decode(Location.self, forKey: .location)
        greenType = try container.decode(GreenType.self, forKey: .greenType)
        greenSpeed = try container.decode(Int.self, forKey: .greenSpeed)
        rinkNumber = try container.decodeIfPresent(Int.self, forKey: .rinkNumber)
        weather = try container.decodeIfPresent(Weather.self, forKey: .weather)
        windConditions = try container.decodeIfPresent(WindConditions.self, forKey: .windConditions)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        totalShots = try container.decodeIfPresent(Int.self, forKey: .totalShots)
        _drawShots = try container.decodeIfPresent(String.self, forKey: ._drawShots)
        _weightedShots = try container.decodeIfPresent(String.self, forKey: ._weightedShots)
        // Handle accuracy fields that may come as strings from API
        if let drawAccuracyString = try container.decodeIfPresent(String.self, forKey: .drawAccuracy) {
            drawAccuracy = Double(drawAccuracyString)
        } else {
            drawAccuracy = try container.decodeIfPresent(Double.self, forKey: .drawAccuracy)
        }

        if let weightedAccuracyString = try container.decodeIfPresent(String.self, forKey: .weightedAccuracy) {
            weightedAccuracy = Double(weightedAccuracyString)
        } else {
            weightedAccuracy = try container.decodeIfPresent(Double.self, forKey: .weightedAccuracy)
        }

        if let overallAccuracyString = try container.decodeIfPresent(String.self, forKey: .overallAccuracy) {
            overallAccuracy = Double(overallAccuracyString)
        } else {
            overallAccuracy = try container.decodeIfPresent(Double.self, forKey: .overallAccuracy)
        }
        durationSeconds = try container.decodeIfPresent(Int.self, forKey: .durationSeconds)
        _isActive = try container.decodeIfPresent(Int.self, forKey: ._isActive)
        _totalPoints = try container.decodeIfPresent(String.self, forKey: ._totalPoints)
        _averageScore = try container.decodeIfPresent(String.self, forKey: ._averageScore)
        _accuracyPercentage = try container.decodeIfPresent(String.self, forKey: ._accuracyPercentage)
        _yardOnShots = try container.decodeIfPresent(String.self, forKey: ._yardOnShots)
        // Handle yard on accuracy that may come as string from API
        if let yardOnAccuracyString = try container.decodeIfPresent(String.self, forKey: .yardOnAccuracy) {
            yardOnAccuracy = Double(yardOnAccuracyString)
        } else {
            yardOnAccuracy = try container.decodeIfPresent(Double.self, forKey: .yardOnAccuracy)
        }

        _ditchWeightShots = try container.decodeIfPresent(String.self, forKey: ._ditchWeightShots)
        // Handle ditch weight accuracy that may come as string from API
        if let ditchWeightAccuracyString = try container.decodeIfPresent(String.self, forKey: .ditchWeightAccuracy) {
            ditchWeightAccuracy = Double(ditchWeightAccuracyString)
        } else {
            ditchWeightAccuracy = try container.decodeIfPresent(Double.self, forKey: .ditchWeightAccuracy)
        }

        _driveShots = try container.decodeIfPresent(String.self, forKey: ._driveShots)
        // Handle drive accuracy that may come as string from API
        if let driveAccuracyString = try container.decodeIfPresent(String.self, forKey: .driveAccuracy) {
            driveAccuracy = Double(driveAccuracyString)
        } else {
            driveAccuracy = try container.decodeIfPresent(Double.self, forKey: .driveAccuracy)
        }

        // Handle date decoding with the same logic as the APIService
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter1.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter1.timeZone = TimeZone(secondsFromGMT: 0)

        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter2.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter2.timeZone = TimeZone(secondsFromGMT: 0)

        let iso8601Formatter = ISO8601DateFormatter()

        func decodeDate(_ key: CodingKeys) throws -> Date {
            let dateString = try container.decode(String.self, forKey: key)
            if let date = dateFormatter1.date(from: dateString) {
                return date
            } else if let date = dateFormatter2.date(from: dateString) {
                return date
            } else if let date = iso8601Formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Cannot decode date string \(dateString)")
        }

        func decodeDateOptional(_ key: CodingKeys) -> Date? {
            do {
                guard let dateString = try container.decodeIfPresent(String.self, forKey: key) else {
                    return nil
                }
                if let date = dateFormatter1.date(from: dateString) {
                    return date
                } else if let date = dateFormatter2.date(from: dateString) {
                    return date
                } else if let date = iso8601Formatter.date(from: dateString) {
                    return date
                }
                return nil
            } catch {
                return nil
            }
        }

        sessionDate = try decodeDate(.sessionDate)
        createdAt = try decodeDate(.createdAt)
        updatedAt = try decodeDate(.updatedAt)
        startedAt = decodeDateOptional(.startedAt)
        endedAt = decodeDateOptional(.endedAt)

        // Club details
        clubId = try container.decodeIfPresent(Int.self, forKey: .clubId)
        clubName = try container.decodeIfPresent(String.self, forKey: .clubName)
        clubDescription = try container.decodeIfPresent(String.self, forKey: .clubDescription)

        // Equipment details
        equipment = try container.decodeIfPresent(SessionEquipment.self, forKey: .equipment)

        // Training program details
        programId = try container.decodeIfPresent(Int.self, forKey: .programId)
        programTitle = try container.decodeIfPresent(String.self, forKey: .programTitle)
    }
    
    // Computed property for formatted duration display
    var durationFormatted: String {
        guard let duration = durationSeconds else { 
            return isActive == true ? "In Progress" : "--"
        }
        
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let secs = duration % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    // Computed property for elapsed time (for active sessions)
    var elapsedTime: TimeInterval? {
        guard let startedAt = startedAt else { return nil }
        
        if let endedAt = endedAt {
            return endedAt.timeIntervalSince(startedAt)
        } else if isActive == true {
            return Date().timeIntervalSince(startedAt)
        }
        
        return nil
    }
    
    // Helper methods for shot type statistics
    func shotCountForType(_ type: String) -> String {
        switch type {
        case "draw": return drawShots.map(String.init) ?? "0"
        case "yard_on": return yardOnShots.map(String.init) ?? "0"
        case "ditch_weight": return ditchWeightShots.map(String.init) ?? "0"
        case "drive": return driveShots.map(String.init) ?? "0"
        default: return "0"
        }
    }
    
    func accuracyForType(_ type: String) -> Double? {
        switch type {
        case "draw": return drawAccuracy
        case "yard_on": return yardOnAccuracy
        case "ditch_weight": return ditchWeightAccuracy
        case "drive": return driveAccuracy
        default: return nil
        }
    }
    
    func displayAccuracyForType(_ type: String) -> String? {
        guard let accuracy = accuracyForType(type) else { return nil }
        return String(format: "%.1f", accuracy)
    }

    // Computed property to calculate successful shots based on overall accuracy
    var successfulShots: Int {
        guard let totalShots = self.totalShots, totalShots > 0 else { return 0 }
        let accuracy = self.overallAccuracy ?? 0.0
        return Int(round(Double(totalShots) * accuracy / 100.0))
    }
}

struct TrainingShot: Codable, Identifiable {
    let id: Int
    let sessionId: Int?
    let shotType: ShotType
    let hand: Hand
    let length: Length
    let distanceFromJack: DistanceFromJack?
    let _hitTarget: Int?
    let _withinFoot: Int?
    let _success: Int?
    let score: Int?
    let notes: String?
    let createdAt: Date
    
    // Computed properties to convert MySQL TINYINT to Bool
    var hitTarget: Bool? {
        guard let value = _hitTarget else { return nil }
        return value == 1
    }
    
    var withinFoot: Bool? {
        guard let value = _withinFoot else { return nil }
        return value == 1
    }
    
    var success: Bool? {
        guard let value = _success else { return nil }
        return value == 1
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case shotType = "shot_type"
        case hand
        case length
        case distanceFromJack = "distance_from_jack"
        case _hitTarget = "hit_target"
        case _withinFoot = "within_foot"
        case _success = "success"
        case score
        case notes
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        sessionId = try container.decodeIfPresent(Int.self, forKey: .sessionId)
        shotType = try container.decode(ShotType.self, forKey: .shotType)
        hand = try container.decode(Hand.self, forKey: .hand)
        length = try container.decode(Length.self, forKey: .length)
        distanceFromJack = try container.decodeIfPresent(DistanceFromJack.self, forKey: .distanceFromJack)
        _hitTarget = try container.decodeIfPresent(Int.self, forKey: ._hitTarget)
        _withinFoot = try container.decodeIfPresent(Int.self, forKey: ._withinFoot)
        _success = try container.decodeIfPresent(Int.self, forKey: ._success)
        score = try container.decodeIfPresent(Int.self, forKey: .score)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)

        // Decode date with flexible format support
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter1.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter1.timeZone = TimeZone(secondsFromGMT: 0)

        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter2.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter2.timeZone = TimeZone(secondsFromGMT: 0)

        let iso8601Formatter = ISO8601DateFormatter()

        let dateString = try container.decode(String.self, forKey: .createdAt)
        if let date = dateFormatter1.date(from: dateString) {
            createdAt = date
        } else if let date = dateFormatter2.date(from: dateString) {
            createdAt = date
        } else if let date = iso8601Formatter.date(from: dateString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
    }
}

struct SessionStatistics: Codable {
    let totalShots: Int
    let totalPoints: String?
    let maxPossiblePoints: Int?
    let averageScore: String?
    let accuracyPercentage: String
    
    // Draw shot statistics
    let drawShots: String?
    let drawPoints: String?
    let drawAccuracyPercentage: String?
    
    // Yard on shot statistics
    let yardOnShots: String?
    let yardOnPoints: String?
    let yardOnAccuracyPercentage: String?
    
    // Ditch weight shot statistics
    let ditchWeightShots: String?
    let ditchWeightPoints: String?
    let ditchWeightAccuracyPercentage: String?
    
    // Drive shot statistics
    let driveShots: String?
    let drivePoints: String?
    let driveAccuracyPercentage: String?
    
    // Legacy weighted fields for backward compatibility
    let weightedShots: String?
    let weightedPoints: String?
    let weightedAccuracyPercentage: String?

    // Draw breakdown
    let drawBreakdown: DrawBreakdown?
    
    enum CodingKeys: String, CodingKey {
        case totalShots = "total_shots"
        case totalPoints = "total_points"
        case maxPossiblePoints = "max_possible_points"
        case averageScore = "average_score"
        case accuracyPercentage = "accuracy_percentage"
        
        case drawShots = "draw_shots"
        case drawPoints = "draw_points"
        case drawAccuracyPercentage = "draw_accuracy_percentage"
        
        case yardOnShots = "yard_on_shots"
        case yardOnPoints = "yard_on_points"
        case yardOnAccuracyPercentage = "yard_on_accuracy_percentage"
        
        case ditchWeightShots = "ditch_weight_shots"
        case ditchWeightPoints = "ditch_weight_points"
        case ditchWeightAccuracyPercentage = "ditch_weight_accuracy_percentage"
        
        case driveShots = "drive_shots"
        case drivePoints = "drive_points"
        case driveAccuracyPercentage = "drive_accuracy_percentage"
        
        case weightedShots = "weighted_shots"
        case weightedPoints = "weighted_points"
        case weightedAccuracyPercentage = "weighted_accuracy_percentage"

        case drawBreakdown = "draw_breakdown"
    }

    // Memberwise initializer
    init(totalShots: Int, totalPoints: String?, maxPossiblePoints: Int?, averageScore: String?, accuracyPercentage: String, drawShots: String?, drawPoints: String?, drawAccuracyPercentage: String?, yardOnShots: String?, yardOnPoints: String?, yardOnAccuracyPercentage: String?, ditchWeightShots: String?, ditchWeightPoints: String?, ditchWeightAccuracyPercentage: String?, driveShots: String?, drivePoints: String?, driveAccuracyPercentage: String?, weightedShots: String?, weightedPoints: String?, weightedAccuracyPercentage: String?, drawBreakdown: DrawBreakdown?) {
        self.totalShots = totalShots
        self.totalPoints = totalPoints
        self.maxPossiblePoints = maxPossiblePoints
        self.averageScore = averageScore
        self.accuracyPercentage = accuracyPercentage
        self.drawShots = drawShots
        self.drawPoints = drawPoints
        self.drawAccuracyPercentage = drawAccuracyPercentage
        self.yardOnShots = yardOnShots
        self.yardOnPoints = yardOnPoints
        self.yardOnAccuracyPercentage = yardOnAccuracyPercentage
        self.ditchWeightShots = ditchWeightShots
        self.ditchWeightPoints = ditchWeightPoints
        self.ditchWeightAccuracyPercentage = ditchWeightAccuracyPercentage
        self.driveShots = driveShots
        self.drivePoints = drivePoints
        self.driveAccuracyPercentage = driveAccuracyPercentage
        self.weightedShots = weightedShots
        self.weightedPoints = weightedPoints
        self.weightedAccuracyPercentage = weightedAccuracyPercentage
        self.drawBreakdown = drawBreakdown
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode totalShots as Int
        totalShots = try container.decode(Int.self, forKey: .totalShots)

        // Decode maxPossiblePoints as Int?
        maxPossiblePoints = try container.decodeIfPresent(Int.self, forKey: .maxPossiblePoints)

        // Helper function to decode number or string as String
        func decodeNumberOrString(_ key: CodingKeys) -> String? {
            if let stringValue = try? container.decodeIfPresent(String.self, forKey: key) {
                return stringValue
            } else if let intValue = try? container.decodeIfPresent(Int.self, forKey: key) {
                return String(intValue)
            } else if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: key) {
                return String(format: "%.1f", doubleValue)
            }
            return nil
        }

        // Helper function to decode number or string as String (non-optional)
        func decodeNumberOrStringRequired(_ key: CodingKeys) throws -> String {
            if let stringValue = try? container.decode(String.self, forKey: key) {
                return stringValue
            } else if let intValue = try? container.decode(Int.self, forKey: key) {
                return String(intValue)
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                return String(format: "%.1f", doubleValue)
            }
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Cannot decode as String, Int, or Double")
        }

        // Decode fields that can be numbers or strings
        totalPoints = decodeNumberOrString(.totalPoints)
        averageScore = decodeNumberOrString(.averageScore)
        accuracyPercentage = try decodeNumberOrStringRequired(.accuracyPercentage)

        drawShots = decodeNumberOrString(.drawShots)
        drawPoints = decodeNumberOrString(.drawPoints)
        drawAccuracyPercentage = decodeNumberOrString(.drawAccuracyPercentage)

        yardOnShots = decodeNumberOrString(.yardOnShots)
        yardOnPoints = decodeNumberOrString(.yardOnPoints)
        yardOnAccuracyPercentage = decodeNumberOrString(.yardOnAccuracyPercentage)

        ditchWeightShots = decodeNumberOrString(.ditchWeightShots)
        ditchWeightPoints = decodeNumberOrString(.ditchWeightPoints)
        ditchWeightAccuracyPercentage = decodeNumberOrString(.ditchWeightAccuracyPercentage)

        driveShots = decodeNumberOrString(.driveShots)
        drivePoints = decodeNumberOrString(.drivePoints)
        driveAccuracyPercentage = decodeNumberOrString(.driveAccuracyPercentage)

        weightedShots = decodeNumberOrString(.weightedShots)
        weightedPoints = decodeNumberOrString(.weightedPoints)
        weightedAccuracyPercentage = decodeNumberOrString(.weightedAccuracyPercentage)

        drawBreakdown = try container.decodeIfPresent(DrawBreakdown.self, forKey: .drawBreakdown)
    }

    
    var drawAccuracy: Double {
        return Double(drawAccuracyPercentage ?? "0.0") ?? 0.0
    }
    
    var yardOnAccuracy: Double {
        return Double(yardOnAccuracyPercentage ?? "0.0") ?? 0.0
    }
    
    var ditchWeightAccuracy: Double {
        return Double(ditchWeightAccuracyPercentage ?? "0.0") ?? 0.0
    }
    
    var driveAccuracy: Double {
        return Double(driveAccuracyPercentage ?? "0.0") ?? 0.0
    }
    
    var weightedAccuracy: Double {
        return Double(weightedAccuracyPercentage ?? "0.0") ?? 0.0
    }
    
    // Helper functions for display
    func shotCountForType(_ type: String) -> String {
        switch type {
        case "draw": return drawShots ?? "0"
        case "yard_on": return yardOnShots ?? "0"
        case "ditch_weight": return ditchWeightShots ?? "0"
        case "drive": return driveShots ?? "0"
        default: return "0"
        }
    }
    
    func pointsForType(_ type: String) -> String {
        switch type {
        case "draw": return drawPoints ?? "0"
        case "yard_on": return yardOnPoints ?? "0"
        case "ditch_weight": return ditchWeightPoints ?? "0"
        case "drive": return drivePoints ?? "0"
        default: return "0"
        }
    }
    
    func accuracyForType(_ type: String) -> String? {
        switch type {
        case "draw": return drawAccuracyPercentage
        case "yard_on": return yardOnAccuracyPercentage
        case "ditch_weight": return ditchWeightAccuracyPercentage
        case "drive": return driveAccuracyPercentage
        default: return nil
        }
    }
    
    func displayAccuracyForType(_ type: String) -> String {
        if let accuracy = accuracyForType(type) {
            return "\(accuracy)%"
        } else {
            return "Not practiced"
        }
    }
}

struct Pagination: Codable {
    let total: Int
    let limit: Int
    let offset: Int
    let hasMore: Bool
    
    enum CodingKeys: String, CodingKey {
        case total
        case limit
        case offset
        case hasMore
    }
}

// MARK: - Response Models

struct CreateSessionResponse: Codable {
    let message: String
    let session: TrainingSession
}

struct SessionListResponse: Codable {
    let sessions: [TrainingSession]
    let pagination: Pagination
}

struct DrawBreakdown: Codable {
    let foot: Int
    let yard: Int
    let miss: Int
}

struct SessionDetailResponse: Codable {
    let session: TrainingSession
    let shots: [TrainingShot]
    let statistics: SessionStatistics
    let shotsByType: [String: [TrainingShot]]

    enum CodingKeys: String, CodingKey {
        case session
        case shots
        case statistics
        case shotsByType = "shots_by_type"
    }
}

struct RecordShotResponse: Codable {
    let message: String
    let shot: TrainingShot
    let sessionStats: SessionStatistics
    
    enum CodingKeys: String, CodingKey {
        case message
        case shot
        case sessionStats = "session_stats"
    }
}

struct DeleteResponse: Codable {
    let message: String
    let deletedSessionId: Int
    
    enum CodingKeys: String, CodingKey {
        case message
        case deletedSessionId = "deleted_session_id"
    }
}

struct DeleteShotResponse: Codable {
    let message: String
    let deletedShotId: Int
    let updatedSessionStats: SessionStatistics
    
    enum CodingKeys: String, CodingKey {
        case message
        case deletedShotId = "deleted_shot_id"
        case updatedSessionStats = "updated_session_stats"
    }
}

struct HandStats: Codable {
    let hand: Hand
    let shots: Int
    let accuracy: Double
}

struct LengthStats: Codable {
    let length: Length
    let shots: Int
    let accuracy: Double
}

struct ShotTypeStats: Codable {
    let shotType: ShotType
    let count: Int
    let successful: Int
    let accuracy: Double
    
    enum CodingKeys: String, CodingKey {
        case shotType = "shot_type"
        case count
        case successful
        case accuracy
    }
}

struct DetailedStats: Codable {
    let byHand: [HandStats]
    let byLength: [LengthStats]
    let byShotType: [ShotTypeStats]
    
    enum CodingKeys: String, CodingKey {
        case byHand = "by_hand"
        case byLength = "by_length"
        case byShotType = "by_shot_type"
    }
}

struct ImprovementTrend: Codable {
    let draw: String
    let weighted: String
}

struct ShotBreakdown: Codable {
    let draw: Int
    let weighted: Int
}

struct TrainingStatsResponse: Codable {
    let sport: String
    let period: String
    let totalSessions: Int
    let totalShots: Int
    let drawAccuracy: Double
    let weightedAccuracy: Double
    let overallAccuracy: Double
    let bestHand: Hand
    let bestLength: Length
    let improvementTrend: ImprovementTrend
    let shotBreakdown: ShotBreakdown
    let detailedStats: DetailedStats
    
    enum CodingKeys: String, CodingKey {
        case sport
        case period
        case totalSessions = "total_sessions"
        case totalShots = "total_shots"
        case drawAccuracy = "draw_accuracy"
        case weightedAccuracy = "weighted_accuracy"
        case overallAccuracy = "overall_accuracy"
        case bestHand = "best_hand"
        case bestLength = "best_length"
        case improvementTrend = "improvement_trend"
        case shotBreakdown = "shot_breakdown"
        case detailedStats = "detailed_stats"
    }
}

struct ProgressPeriod: Codable {
    let period: String
    let periodLabel: String
    let periodStart: Date
    let periodEnd: Date
    let sessions: Int
    let totalShots: Int
    let drawShots: Int
    let weightedShots: Int
    let drawAccuracy: Double
    let weightedAccuracy: Double
    let overallAccuracy: Double
    let avgGreenSpeed: Double
    
    enum CodingKeys: String, CodingKey {
        case period
        case periodLabel = "period_label"
        case periodStart = "period_start"
        case periodEnd = "period_end"
        case sessions
        case totalShots = "total_shots"
        case drawShots = "draw_shots"
        case weightedShots = "weighted_shots"
        case drawAccuracy = "draw_accuracy"
        case weightedAccuracy = "weighted_accuracy"
        case overallAccuracy = "overall_accuracy"
        case avgGreenSpeed = "avg_green_speed"
    }
}

struct Milestone: Codable {
    let milestone: String
    let achievedDate: Date
    
    enum CodingKeys: String, CodingKey {
        case milestone
        case achievedDate = "achieved_date"
    }
}

struct BestPeriod: Codable {
    let periodLabel: String
    let overallAccuracy: Double
    
    enum CodingKeys: String, CodingKey {
        case periodLabel = "period_label"
        case overallAccuracy = "overall_accuracy"
    }
}

struct ProgressSummary: Codable {
    let totalPeriods: Int
    let earliestSession: Date
    let latestSession: Date
    let bestPeriod: BestPeriod
    
    enum CodingKeys: String, CodingKey {
        case totalPeriods = "total_periods"
        case earliestSession = "earliest_session"
        case latestSession = "latest_session"
        case bestPeriod = "best_period"
    }
}

struct ProgressTrends: Codable {
    let drawAccuracy: String
    let weightedAccuracy: String
    let overallAccuracy: String
    let sessionFrequency: String
    let shotsPerSession: String
    
    enum CodingKeys: String, CodingKey {
        case drawAccuracy = "draw_accuracy"
        case weightedAccuracy = "weighted_accuracy"
        case overallAccuracy = "overall_accuracy"
        case sessionFrequency = "session_frequency"
        case shotsPerSession = "shots_per_session"
    }
}

struct TrainingProgressResponse: Codable {
    let sport: String
    let groupBy: String
    let limit: Int
    let progressData: [ProgressPeriod]
    let trends: ProgressTrends
    let milestones: [Milestone]
    let summary: ProgressSummary
    
    enum CodingKeys: String, CodingKey {
        case sport
        case groupBy = "group_by"
        case limit
        case progressData = "progress_data"
        case trends
        case milestones
        case summary
    }
}