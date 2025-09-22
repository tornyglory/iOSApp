import Foundation

// MARK: - Analytics Response Model
struct AnalyticsResponse: Codable {
    let sport: String
    let period: String
    let totalSessions: Int
    let totalShots: Int
    let totalPoints: String
    let maxPossiblePoints: Int
    let averageScore: String
    let drawAccuracy: String
    let weightedAccuracy: String
    let overallAccuracy: String
    let bestHand: String
    let bestLength: String
    let improvementTrend: AnalyticsImprovementTrend
    let shotBreakdown: AnalyticsShotBreakdown
    let drawBreakdown: AnalyticsDrawBreakdown
    let detailedStats: AnalyticsDetailedStats

    enum CodingKeys: String, CodingKey {
        case sport, period
        case totalSessions = "total_sessions"
        case totalShots = "total_shots"
        case totalPoints = "total_points"
        case maxPossiblePoints = "max_possible_points"
        case averageScore = "average_score"
        case drawAccuracy = "draw_accuracy"
        case weightedAccuracy = "weighted_accuracy"
        case overallAccuracy = "overall_accuracy"
        case bestHand = "best_hand"
        case bestLength = "best_length"
        case improvementTrend = "improvement_trend"
        case shotBreakdown = "shot_breakdown"
        case drawBreakdown = "draw_breakdown"
        case detailedStats = "detailed_stats"
    }
}

struct AnalyticsImprovementTrend: Codable {
    let draw: String?
    let weighted: String?
}

struct AnalyticsShotBreakdown: Codable {
    let draw: String
    let weighted: String
}

struct AnalyticsDrawBreakdown: Codable {
    let foot: Int
    let yard: Int
    let miss: Int
}

struct AnalyticsDetailedStats: Codable {
    let byHand: [AnalyticsHandStat]
    let byLength: [AnalyticsLengthStat]
    let byShotType: [AnalyticsShotTypeStat]
    let byDrawDistance: [AnalyticsDrawDistanceStat]

    enum CodingKeys: String, CodingKey {
        case byHand = "by_hand"
        case byLength = "by_length"
        case byShotType = "by_shot_type"
        case byDrawDistance = "by_draw_distance"
    }
}

struct AnalyticsHandStat: Codable, Identifiable {
    var id: String { hand }
    let hand: String
    let shots: Int
    let totalPoints: String
    let accuracy: String

    enum CodingKeys: String, CodingKey {
        case hand, shots
        case totalPoints = "total_points"
        case accuracy
    }
}

struct AnalyticsLengthStat: Codable, Identifiable {
    var id: String { length }
    let length: String
    let shots: Int
    let totalPoints: String
    let accuracy: String

    enum CodingKeys: String, CodingKey {
        case length, shots
        case totalPoints = "total_points"
        case accuracy
    }
}

struct AnalyticsShotTypeStat: Codable, Identifiable {
    var id: String { shotType }
    let shotType: String
    let count: Int
    let totalPoints: String
    let maxPoints: Int
    let accuracy: String

    enum CodingKeys: String, CodingKey {
        case shotType = "shot_type"
        case count
        case totalPoints = "total_points"
        case maxPoints = "max_points"
        case accuracy
    }
}

struct AnalyticsDrawDistanceStat: Codable, Identifiable {
    var id: String { distanceFromJack }
    let distanceFromJack: String
    let count: Int
    let distance: String
    let pointsPerShot: Int

    enum CodingKeys: String, CodingKey {
        case distanceFromJack = "distance_from_jack"
        case count, distance
        case pointsPerShot = "points_per_shot"
    }
}