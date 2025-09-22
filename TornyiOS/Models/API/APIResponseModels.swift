import Foundation

// MARK: - General API Response Models

struct ErrorResponse: Codable {
    let status: String?
    let message: String?
}

// MARK: - Session API Response Models

struct CreateSessionRequest: Codable {
    let playerId: Int
    let sport: String
    let sessionDate: String
    let location: String
    let greenType: String
    let greenSpeed: Int
    let rinkNumber: Int?
    let weather: String?
    let windConditions: String?
    let notes: String?

    enum CodingKeys: String, CodingKey {
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
    }
}

struct CreateSessionResponse: Codable {
    let message: String
    let session: TrainingSession
}

struct EndSessionRequest: Codable {
    let sessionId: Int

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
    }
}

struct EndSessionResponse: Codable {
    let message: String
    let session: TrainingSession?
}

struct DeleteSessionResponse: Codable {
    let status: String?
    let message: String
}

struct RecordShotRequest: Codable {
    let sessionId: Int
    let shotType: String
    let hand: String
    let length: String
    let distanceFromJack: String?
    let score: Int?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case shotType = "shot_type"
        case hand
        case length
        case distanceFromJack = "distance_from_jack"
        case score
        case notes
    }
}

struct RecordShotResponse: Codable {
    let message: String
    let shot: TrainingShot
}

struct SessionStatisticsResponse: Codable {
    let status: String
    let statistics: SessionStatistics
}

// MARK: - Paginated Response Models

struct Pagination: Codable {
    let total: Int
    let limit: Int
    let offset: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case total
        case limit
        case offset
        case hasMore = "has_more"
    }
}

struct SessionListResponse: Codable {
    let sessions: [TrainingSession]
    let pagination: Pagination
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

// MARK: - Image Upload Response

struct ImageUploadRequest: Codable {
    let userId: Int
    let imageType: String
    let imageData: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case imageType = "image_type"
        case imageData = "image_data"
    }
}

struct ImageUploadResponse: Codable {
    let status: String
    let message: String
    let url: String?
}