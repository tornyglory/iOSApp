import Foundation

// MARK: - Chart Data Models

struct ChartDataResponse: Codable {
    let sessionId: String
    let isActive: Bool
    let startedAt: String
    let endedAt: String?
    let durationSeconds: Int
    let totalShots: Int
    let currentScore: Int
    let maxPossibleScore: Int
    let overallAccuracy: Double
    let chartData: ChartDataSimple
    let lastUpdated: String

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case isActive = "is_active"
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case durationSeconds = "duration_seconds"
        case totalShots = "total_shots"
        case currentScore = "current_score"
        case maxPossibleScore = "max_possible_score"
        case overallAccuracy = "overall_accuracy"
        case chartData = "chart_data"
        case lastUpdated = "last_updated"
    }
}

struct ChartDataSimple: Codable {
    let accuracyOverTime: [AccuracyPointSimple]
    let scoreProgression: [ScorePoint]
    let shotTypeSeries: [ShotTypeSeries]

    enum CodingKeys: String, CodingKey {
        case accuracyOverTime = "accuracy_over_time"
        case scoreProgression = "score_progression"
        case shotTypeSeries = "shot_type_series"
    }
}

struct AccuracyPointSimple: Codable {
    let x: Int
    let y: Double
    let timestamp: String
}

struct ScorePoint: Codable {
    let x: Int
    let y: Int
    let maxY: Int?
    let timestamp: String

    enum CodingKeys: String, CodingKey {
        case x
        case y
        case maxY = "max_y"
        case timestamp
    }
}

struct ShotTypeSeries: Codable {
    let x: Int
    let type: String
    let score: Int
    let timestamp: String
}

struct AccuracyPoint: Codable, Identifiable {
    let id = UUID()
    let shotNumber: Int
    let cumulativeAccuracy: Double
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case shotNumber = "shot_number"
        case cumulativeAccuracy = "cumulative_accuracy"
        case timestamp
    }

    init(shotNumber: Int, cumulativeAccuracy: Double, timestamp: Date) {
        self.shotNumber = shotNumber
        self.cumulativeAccuracy = cumulativeAccuracy
        self.timestamp = timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shotNumber = try container.decode(Int.self, forKey: .shotNumber)
        cumulativeAccuracy = try container.decode(Double.self, forKey: .cumulativeAccuracy)

        // Parse timestamp
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: timestampString) {
            timestamp = date
        } else {
            // Fallback to basic ISO8601
            let basicFormatter = ISO8601DateFormatter()
            if let date = basicFormatter.date(from: timestampString) {
                timestamp = date
            } else {
                throw DecodingError.dataCorruptedError(forKey: .timestamp, in: container, debugDescription: "Cannot decode timestamp string \(timestampString)")
            }
        }
    }
}

struct ShotTypeData: Codable, Identifiable {
    let id = UUID()
    let type: String
    let count: Int
    let percentage: Double
    let averageAccuracy: Double

    enum CodingKeys: String, CodingKey {
        case type
        case count
        case percentage
        case averageAccuracy = "average_accuracy"
    }

    init(type: String, count: Int, percentage: Double, averageAccuracy: Double) {
        self.type = type
        self.count = count
        self.percentage = percentage
        self.averageAccuracy = averageAccuracy
    }
}

struct PerformanceMetrics: Codable {
    let totalShots: Int
    let successfulShots: Int
    let overallAccuracy: Double
    let currentStreak: Int
    let bestStreak: Int
    let averageDistanceFromTarget: Double?
    let improvementTrend: String

    enum CodingKeys: String, CodingKey {
        case totalShots = "total_shots"
        case successfulShots = "successful_shots"
        case overallAccuracy = "overall_accuracy"
        case currentStreak = "current_streak"
        case bestStreak = "best_streak"
        case averageDistanceFromTarget = "average_distance_from_target"
        case improvementTrend = "improvement_trend"
    }

    init(totalShots: Int, successfulShots: Int, overallAccuracy: Double, currentStreak: Int, bestStreak: Int, averageDistanceFromTarget: Double?, improvementTrend: String) {
        self.totalShots = totalShots
        self.successfulShots = successfulShots
        self.overallAccuracy = overallAccuracy
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.averageDistanceFromTarget = averageDistanceFromTarget
        self.improvementTrend = improvementTrend
    }
}

struct RecentShotData: Codable, Identifiable {
    let id = UUID()
    let shotNumber: Int
    let type: String
    let points: Int
    let distanceFromTarget: Double?
    let notes: String?
    let timestamp: Date
    let wasSuccessful: Bool

    enum CodingKeys: String, CodingKey {
        case shotNumber = "shot_number"
        case type
        case points
        case distanceFromTarget = "distance_from_target"
        case notes
        case timestamp
        case wasSuccessful = "was_successful"
    }

    init(shotNumber: Int, type: String, points: Int, distanceFromTarget: Double?, notes: String?, timestamp: Date, wasSuccessful: Bool) {
        self.shotNumber = shotNumber
        self.type = type
        self.points = points
        self.distanceFromTarget = distanceFromTarget
        self.notes = notes
        self.timestamp = timestamp
        self.wasSuccessful = wasSuccessful
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shotNumber = try container.decode(Int.self, forKey: .shotNumber)
        type = try container.decode(String.self, forKey: .type)
        points = try container.decode(Int.self, forKey: .points)
        distanceFromTarget = try container.decodeIfPresent(Double.self, forKey: .distanceFromTarget)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        wasSuccessful = try container.decode(Bool.self, forKey: .wasSuccessful)

        // Parse timestamp
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: timestampString) {
            timestamp = date
        } else {
            // Fallback to basic ISO8601
            let basicFormatter = ISO8601DateFormatter()
            if let date = basicFormatter.date(from: timestampString) {
                timestamp = date
            } else {
                throw DecodingError.dataCorruptedError(forKey: .timestamp, in: container, debugDescription: "Cannot decode timestamp string \(timestampString)")
            }
        }
    }
}

struct ChartMetadata: Codable {
    let lastUpdated: Date
    let sessionStartTime: Date
    let refreshIntervalSeconds: Int
    let dataPoints: Int

    enum CodingKeys: String, CodingKey {
        case lastUpdated = "last_updated"
        case sessionStartTime = "session_start_time"
        case refreshIntervalSeconds = "refresh_interval_seconds"
        case dataPoints = "data_points"
    }

    init(lastUpdated: Date, sessionStartTime: Date, refreshIntervalSeconds: Int, dataPoints: Int) {
        self.lastUpdated = lastUpdated
        self.sessionStartTime = sessionStartTime
        self.refreshIntervalSeconds = refreshIntervalSeconds
        self.dataPoints = dataPoints
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        refreshIntervalSeconds = try container.decode(Int.self, forKey: .refreshIntervalSeconds)
        dataPoints = try container.decode(Int.self, forKey: .dataPoints)

        // Parse timestamps
        let lastUpdatedString = try container.decode(String.self, forKey: .lastUpdated)
        let sessionStartString = try container.decode(String.self, forKey: .sessionStartTime)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: lastUpdatedString) {
            lastUpdated = date
        } else {
            let basicFormatter = ISO8601DateFormatter()
            if let date = basicFormatter.date(from: lastUpdatedString) {
                lastUpdated = date
            } else {
                throw DecodingError.dataCorruptedError(forKey: .lastUpdated, in: container, debugDescription: "Cannot decode lastUpdated string \(lastUpdatedString)")
            }
        }

        if let date = formatter.date(from: sessionStartString) {
            sessionStartTime = date
        } else {
            let basicFormatter = ISO8601DateFormatter()
            if let date = basicFormatter.date(from: sessionStartString) {
                sessionStartTime = date
            } else {
                throw DecodingError.dataCorruptedError(forKey: .sessionStartTime, in: container, debugDescription: "Cannot decode sessionStartTime string \(sessionStartString)")
            }
        }
    }
}

// MARK: - Chart View Data Models

struct ChartViewData {
    let accuracyPoints: [AccuracyPoint]
    let shotTypeData: [ShotTypeData]
    let metrics: PerformanceMetrics
    let recentShots: [RecentShotData]
    let metadata: ChartMetadata

    var formattedOverallAccuracy: String {
        return String(format: "%.1f%%", metrics.overallAccuracy)
    }

    var formattedTotalShots: String {
        return "\(metrics.totalShots)"
    }

    var formattedSuccessfulShots: String {
        return "\(metrics.successfulShots)"
    }

    var sessionDuration: String {
        let duration = Date().timeIntervalSince(metadata.sessionStartTime)
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }

    var lastUpdatedFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: metadata.lastUpdated)
    }
}