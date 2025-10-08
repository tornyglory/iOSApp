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

// MARK: - AI Insights Models

struct AIInsightsResponse: Codable {
    let period: String
    let analysisDate: String
    let overallAssessment: String
    let keyInsights: [String]
    let strengths: [String]
    let areasForImprovement: [AreaForImprovement]
    let recommendedDrills: [RecommendedDrill]
    let nextSessionFocus: String
    let equipmentPerformance: [EquipmentPerformance]?
    let clubPerformance: [ClubPerformance]?

    enum CodingKeys: String, CodingKey {
        case period
        case analysisDate = "analysis_date"
        case overallAssessment = "overall_assessment"
        case keyInsights = "key_insights"
        case strengths
        case areasForImprovement = "areas_for_improvement"
        case recommendedDrills = "recommended_drills"
        case nextSessionFocus = "next_session_focus"
        case equipmentPerformance = "equipment_performance"
        case clubPerformance = "club_performance"
    }
}

struct EquipmentPerformance: Codable, Identifiable {
    var id: String {
        "\(equipment.bowlsBrand ?? "unknown")_\(equipment.bowlsModel ?? "unknown")_\(equipment.size ?? 0)"
    }
    let equipment: SessionEquipment
    let sessions: Int
    let shots: Int
    let _accuracy: String

    var accuracy: Double {
        Double(_accuracy) ?? 0.0
    }

    enum CodingKeys: String, CodingKey {
        case equipment
        case sessions
        case shots
        case _accuracy = "accuracy"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        equipment = try container.decode(SessionEquipment.self, forKey: .equipment)
        sessions = try container.decode(Int.self, forKey: .sessions)
        shots = try container.decode(Int.self, forKey: .shots)

        // Handle accuracy as either String or Double
        if let accuracyDouble = try? container.decode(Double.self, forKey: ._accuracy) {
            _accuracy = String(accuracyDouble)
        } else {
            _accuracy = try container.decode(String.self, forKey: ._accuracy)
        }
    }
}

struct ClubPerformance: Codable, Identifiable {
    let clubId: Int
    let clubName: String
    let clubDescription: String?
    let sessions: Int
    let shots: Int
    let _accuracy: String

    var accuracy: Double {
        Double(_accuracy) ?? 0.0
    }

    var id: Int { clubId }

    enum CodingKeys: String, CodingKey {
        case clubId = "club_id"
        case clubName = "club_name"
        case clubDescription = "club_description"
        case sessions
        case shots
        case _accuracy = "accuracy"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        clubId = try container.decode(Int.self, forKey: .clubId)
        clubName = try container.decode(String.self, forKey: .clubName)
        clubDescription = try container.decodeIfPresent(String.self, forKey: .clubDescription)
        sessions = try container.decode(Int.self, forKey: .sessions)
        shots = try container.decode(Int.self, forKey: .shots)

        // Handle accuracy as either String or Double
        if let accuracyDouble = try? container.decode(Double.self, forKey: ._accuracy) {
            _accuracy = String(accuracyDouble)
        } else {
            _accuracy = try container.decode(String.self, forKey: ._accuracy)
        }
    }
}

struct AreaForImprovement: Codable, Identifiable {
    var id: UUID = UUID()
    let area: String
    let currentPerformance: String
    let target: String
    let priority: String

    enum CodingKeys: String, CodingKey {
        case area
        case currentPerformance = "current_performance"
        case target
        case priority
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.area = try container.decode(String.self, forKey: .area)
        self.currentPerformance = try container.decode(String.self, forKey: .currentPerformance)
        self.target = try container.decode(String.self, forKey: .target)
        self.priority = try container.decode(String.self, forKey: .priority)
        self.id = UUID()
    }
}

struct PerformancePatterns: Codable {
    let bestConditions: String?
    let challengingConditions: String?
    let greenSpeedAnalysis: String?
    let greenTypeAnalysis: String?
    let handAnalysis: String?
    let lengthAnalysis: String?
    let locationAnalysis: String?
    let consistencyRating: String?

    enum CodingKeys: String, CodingKey {
        case bestConditions = "best_conditions"
        case challengingConditions = "challenging_conditions"
        case greenSpeedAnalysis = "green_speed_analysis"
        case greenTypeAnalysis = "green_type_analysis"
        case handAnalysis = "hand_analysis"
        case lengthAnalysis = "length_analysis"
        case locationAnalysis = "location_analysis"
        case consistencyRating = "consistency_rating"
    }
}

struct RecommendedDrill: Codable, Identifiable {
    var id: UUID = UUID()
    let drillName: String
    let description: String
    let targetMetrics: String
    let duration: String

    enum CodingKeys: String, CodingKey {
        case drillName = "drill_name"
        case description
        case targetMetrics = "target_metrics"
        case duration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.drillName = try container.decode(String.self, forKey: .drillName)
        self.description = try container.decode(String.self, forKey: .description)
        self.targetMetrics = try container.decode(String.self, forKey: .targetMetrics)
        self.duration = try container.decode(String.self, forKey: .duration)
        self.id = UUID()
    }
}
// MARK: - Session AI Analysis Models

struct SessionAIAnalysis: Codable {
    let sessionId: Int
    let analysisDate: String
    let overallAssessment: String
    let keyInsights: [String]
    let strengths: [String]
    let areasForImprovement: [AreaForImprovement]
    let recommendedDrills: [RecommendedDrill]
    let nextSessionFocus: String

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case analysisDate = "analysis_date"
        case overallAssessment = "overall_assessment"
        case keyInsights = "key_insights"
        case strengths
        case areasForImprovement = "areas_for_improvement"
        case recommendedDrills = "recommended_drills"
        case nextSessionFocus = "next_session_focus"
    }
}
