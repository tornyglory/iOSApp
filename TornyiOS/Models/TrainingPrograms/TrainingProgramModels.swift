import Foundation

// MARK: - Training Program Models

struct TrainingProgram: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let shortDescription: String?
    let imageUrl: String?
    let category: String?
    let difficulty: Difficulty
    let totalShots: Int
    let estimatedDurationMinutes: Int?
    let isFeatured: Bool
    let isActive: Bool
    var isFavorited: Bool
    let createdAt: Date
    let updatedAt: Date
    let shotsPreview: [ProgramShot]?
    let completionStats: CompletionStats?

    enum Difficulty: String, Codable {
        case beginner
        case intermediate
        case advanced

        var displayName: String {
            rawValue.capitalized
        }

        var color: String {
            switch self {
            case .beginner: return "green"
            case .intermediate: return "orange"
            case .advanced: return "red"
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, category, difficulty
        case shortDescription = "short_description"
        case imageUrl = "image_url"
        case totalShots = "total_shots"
        case estimatedDurationMinutes = "estimated_duration_minutes"
        case isFeatured = "is_featured"
        case isActive = "is_active"
        case isFavorited = "is_favorited"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case shotsPreview = "shots_preview"
        case completionStats = "completion_stats"
    }
}

struct ProgramShot: Codable, Identifiable {
    var id: Int { sequenceOrder }
    let sequenceOrder: Int
    let shotType: ShotType
    let hand: Hand
    let length: Length
    let notes: String?

    enum ShotType: String, Codable {
        case draw
        case yardOn = "yard_on"
        case ditchWeight = "ditch_weight"
        case drive

        var displayName: String {
            switch self {
            case .draw: return "Draw"
            case .yardOn: return "Yard On"
            case .ditchWeight: return "Ditch Weight"
            case .drive: return "Drive"
            }
        }

        var icon: String {
            switch self {
            case .draw: return "target"
            case .yardOn: return "bolt.fill"
            case .ditchWeight: return "wind"
            case .drive: return "flame.fill"
            }
        }
    }

    enum Hand: String, Codable {
        case forehand
        case backhand

        var displayName: String {
            rawValue.capitalized
        }

        var icon: String {
            switch self {
            case .forehand: return "hand.point.right.fill"
            case .backhand: return "hand.point.left.fill"
            }
        }
    }

    enum Length: String, Codable {
        case short
        case medium
        case long
        case full

        var displayName: String {
            rawValue.capitalized
        }

        var abbreviation: String {
            switch self {
            case .short: return "S"
            case .medium: return "M"
            case .long: return "L"
            case .full: return "F"
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case sequenceOrder = "sequence_order"
        case shotType = "shot_type"
        case hand, length, notes
    }
}

struct CompletionStats: Codable {
    let timesCompleted: Int
    let bestScore: Int?
    let averageScore: Double?
    let lastCompleted: Date?

    enum CodingKeys: String, CodingKey {
        case timesCompleted = "times_completed"
        case bestScore = "best_score"
        case averageScore = "average_score"
        case lastCompleted = "last_completed"
    }
}

// MARK: - Programs List Response

struct ProgramsListResponse: Codable {
    let programs: [TrainingProgram]
    let total: Int
    let limit: Int
    let offset: Int
}

// MARK: - Training Session Models

struct TrainingSessionResponse: Codable {
    let status: String
    let message: String
    let session: SessionInfo
    let nextShot: ProgramShot?

    enum CodingKeys: String, CodingKey {
        case status, message, session
        case nextShot = "next_shot"
    }
}

struct SessionInfo: Codable {
    let id: Int
    let programId: Int
    let programTitle: String
    let currentShotIndex: Int
    let totalShots: Int
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case programId = "program_id"
        case programTitle = "program_title"
        case currentShotIndex = "current_shot_index"
        case totalShots = "total_shots"
        case isActive = "is_active"
    }
}

// MARK: - Shot Recording Models

struct RecordProgramShotRequest: Codable {
    let distanceFromJack: String // "foot", "yard", or "miss"
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case distanceFromJack = "distance_from_jack"
        case notes
    }
}

struct RecordProgramShotResponse: Codable, Identifiable {
    var id: Int { shot.id }
    let message: String
    let shot: RecordedShot
    let progress: Progress
    let nextShot: ProgramShot?
    let sessionStats: ProgramSessionStats

    enum CodingKeys: String, CodingKey {
        case message, shot, progress
        case nextShot = "next_shot"
        case sessionStats = "session_stats"
    }
}

struct RecordedShot: Codable {
    let id: Int
    let sessionId: Int
    let shotType: String
    let hand: String
    let length: String
    let distanceFromJack: String
    let score: Int
    let notes: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case shotType = "shot_type"
        case hand, length
        case distanceFromJack = "distance_from_jack"
        case score, notes
        case createdAt = "created_at"
    }
}

struct Progress: Codable {
    let currentShot: Int
    let totalShots: Int
    let completed: Bool

    enum CodingKeys: String, CodingKey {
        case currentShot = "current_shot"
        case totalShots = "total_shots"
        case completed
    }
}

struct ProgramSessionStats: Codable {
    let totalShots: Int
    let totalPoints: Int
    let maxPossiblePoints: Int
    let averageScore: Double
    let accuracyPercentage: Double

    let drawShots: Int
    let drawPoints: Int
    let drawAccuracyPercentage: Double?

    let yardOnShots: Int
    let yardOnPoints: Int
    let yardOnAccuracyPercentage: Double?

    let ditchWeightShots: Int
    let ditchWeightPoints: Int
    let ditchWeightAccuracyPercentage: Double?

    let driveShots: Int
    let drivePoints: Int
    let driveAccuracyPercentage: Double?

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
    }

    // Custom decoder to handle backend sending strings instead of numbers
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        totalShots = try container.decode(Int.self, forKey: .totalShots)
        totalPoints = try Self.decodeIntOrString(from: container, forKey: .totalPoints)
        maxPossiblePoints = try container.decode(Int.self, forKey: .maxPossiblePoints)
        averageScore = try Self.decodeDoubleOrString(from: container, forKey: .averageScore)
        accuracyPercentage = try Self.decodeDoubleOrString(from: container, forKey: .accuracyPercentage)

        drawShots = try Self.decodeIntOrString(from: container, forKey: .drawShots)
        drawPoints = try Self.decodeIntOrString(from: container, forKey: .drawPoints)
        drawAccuracyPercentage = try Self.decodeOptionalDoubleOrString(from: container, forKey: .drawAccuracyPercentage)

        yardOnShots = try Self.decodeIntOrString(from: container, forKey: .yardOnShots)
        yardOnPoints = try Self.decodeIntOrString(from: container, forKey: .yardOnPoints)
        yardOnAccuracyPercentage = try Self.decodeOptionalDoubleOrString(from: container, forKey: .yardOnAccuracyPercentage)

        ditchWeightShots = try Self.decodeIntOrString(from: container, forKey: .ditchWeightShots)
        ditchWeightPoints = try Self.decodeIntOrString(from: container, forKey: .ditchWeightPoints)
        ditchWeightAccuracyPercentage = try Self.decodeOptionalDoubleOrString(from: container, forKey: .ditchWeightAccuracyPercentage)

        driveShots = try Self.decodeIntOrString(from: container, forKey: .driveShots)
        drivePoints = try Self.decodeIntOrString(from: container, forKey: .drivePoints)
        driveAccuracyPercentage = try Self.decodeOptionalDoubleOrString(from: container, forKey: .driveAccuracyPercentage)
    }

    // Helper to decode Int that might come as String
    private static func decodeIntOrString(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Int {
        if let intValue = try? container.decode(Int.self, forKey: key) {
            return intValue
        } else if let stringValue = try? container.decode(String.self, forKey: key),
                  let intValue = Int(stringValue) {
            return intValue
        }
        throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
            codingPath: container.codingPath,
            debugDescription: "Expected Int or String convertible to Int for key \(key)"
        ))
    }

    // Helper to decode Double that might come as String
    private static func decodeDoubleOrString(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Double {
        if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return doubleValue
        } else if let stringValue = try? container.decode(String.self, forKey: key),
                  let doubleValue = Double(stringValue) {
            return doubleValue
        }
        throw DecodingError.typeMismatch(Double.self, DecodingError.Context(
            codingPath: container.codingPath,
            debugDescription: "Expected Double or String convertible to Double for key \(key)"
        ))
    }

    // Helper to decode optional Double that might come as String or null
    private static func decodeOptionalDoubleOrString(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Double? {
        if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return doubleValue
        } else if let stringValue = try? container.decode(String.self, forKey: key),
                  let doubleValue = Double(stringValue) {
            return doubleValue
        }
        return nil
    }
}

// MARK: - Favorite Toggle Response

struct FavoriteToggleResponse: Codable {
    let programId: Int
    let isFavorited: Bool
    let message: String

    enum CodingKeys: String, CodingKey {
        case programId = "program_id"
        case isFavorited = "is_favorited"
        case message
    }
}

// MARK: - Start Program Request

struct StartProgramRequest: Codable {
    let location: String
    let greenType: String
    let greenSpeed: Int
    let rinkNumber: Int?
    let weather: String?
    let windConditions: String?
    let notes: String?
    let equipment: Equipment?
    let clubId: Int?

    struct Equipment: Codable {
        let bowls: String?
        let bowlSize: String?
        let shoes: String?

        enum CodingKeys: String, CodingKey {
            case bowls
            case bowlSize = "bowl_size"
            case shoes
        }
    }

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
