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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        sport = try container.decode(String.self, forKey: .sport)
        period = try container.decode(String.self, forKey: .period)
        totalSessions = try container.decode(Int.self, forKey: .totalSessions)
        totalShots = try container.decode(Int.self, forKey: .totalShots)

        // Helper function to decode String or number fields
        func decodeStringOrNumber(_ key: CodingKeys) -> String {
            if let stringValue = try? container.decode(String.self, forKey: key) {
                return stringValue
            } else if let intValue = try? container.decode(Int.self, forKey: key) {
                return String(intValue)
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                return String(doubleValue)
            }
            return "0"
        }

        // Helper function to decode String or number or null fields
        func decodeStringOrNumberOrNull(_ key: CodingKeys) -> String {
            if container.contains(key) {
                if let stringValue = try? container.decode(String.self, forKey: key) {
                    return stringValue
                } else if let intValue = try? container.decode(Int.self, forKey: key) {
                    return String(intValue)
                } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                    return String(doubleValue)
                }
            }
            return "N/A"
        }

        totalPoints = decodeStringOrNumber(.totalPoints)
        maxPossiblePoints = try container.decode(Int.self, forKey: .maxPossiblePoints)
        averageScore = decodeStringOrNumber(.averageScore)
        drawAccuracy = decodeStringOrNumber(.drawAccuracy)
        weightedAccuracy = decodeStringOrNumber(.weightedAccuracy)
        overallAccuracy = decodeStringOrNumber(.overallAccuracy)
        bestHand = decodeStringOrNumberOrNull(.bestHand)
        bestLength = decodeStringOrNumberOrNull(.bestLength)
        improvementTrend = try container.decode(AnalyticsImprovementTrend.self, forKey: .improvementTrend)
        shotBreakdown = try container.decode(AnalyticsShotBreakdown.self, forKey: .shotBreakdown)
        drawBreakdown = try container.decode(AnalyticsDrawBreakdown.self, forKey: .drawBreakdown)
        detailedStats = try container.decode(AnalyticsDetailedStats.self, forKey: .detailedStats)
    }
}

struct AnalyticsImprovementTrend: Codable {
    let draw: String?
    let weighted: String?
}

struct AnalyticsShotBreakdown: Codable {
    let draw: String
    let weighted: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Handle draw as either String or Int
        if let drawString = try? container.decode(String.self, forKey: .draw) {
            draw = drawString
        } else if let drawInt = try? container.decode(Int.self, forKey: .draw) {
            draw = String(drawInt)
        } else {
            draw = "0"
        }

        // Handle weighted as either String or Int
        if let weightedString = try? container.decode(String.self, forKey: .weighted) {
            weighted = weightedString
        } else if let weightedInt = try? container.decode(Int.self, forKey: .weighted) {
            weighted = String(weightedInt)
        } else {
            weighted = "0"
        }
    }

    enum CodingKeys: String, CodingKey {
        case draw, weighted
    }
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
    let statistics: AIStatistics?
    let practicePatterns: PracticePatterns?
    let overallAssessment: String
    let keyInsights: [String]
    let strengths: [String]
    let areasForImprovement: [AreaForImprovement]
    let recommendedDrills: [RecommendedDrill]
    let recommendedPrograms: [RecommendedProgram]?
    let primaryProgramRecommendation: String?
    let nextSessionFocus: String
    let equipmentPerformance: [EquipmentPerformance]?
    let clubPerformance: [ClubPerformance]?

    enum CodingKeys: String, CodingKey {
        case period
        case analysisDate = "analysis_date"
        case statistics
        case practicePatterns = "practice_patterns"
        case overallAssessment = "overall_assessment"
        case keyInsights = "key_insights"
        case strengths
        case areasForImprovement = "areas_for_improvement"
        case recommendedDrills = "recommended_drills"
        case recommendedPrograms = "recommended_programs"
        case primaryProgramRecommendation = "primary_program_recommendation"
        case nextSessionFocus = "next_session_focus"
        case equipmentPerformance = "equipment_performance"
        case clubPerformance = "club_performance"
    }
}

struct AIStatistics: Codable {
    let totalSessions: Int
    let totalShots: Int
    let totalPoints: String
    let maxPossiblePoints: Int
    let overallAccuracy: String
    let successfulShots: String?
    let successRate: String?
    let excellentShots: String?
    let excellenceRate: String?
    let drawAccuracy: String
    let weightedAccuracy: String
    let improvementTrend: AnalyticsImprovementTrend

    enum CodingKeys: String, CodingKey {
        case totalSessions = "total_sessions"
        case totalShots = "total_shots"
        case totalPoints = "total_points"
        case maxPossiblePoints = "max_possible_points"
        case overallAccuracy = "overall_accuracy"
        case successfulShots = "successful_shots"
        case successRate = "success_rate"
        case excellentShots = "excellent_shots"
        case excellenceRate = "excellence_rate"
        case drawAccuracy = "draw_accuracy"
        case weightedAccuracy = "weighted_accuracy"
        case improvementTrend = "improvement_trend"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Helper to decode Int or String as Int
        func decodeIntOrString(_ key: CodingKeys) throws -> Int {
            if let intValue = try? container.decode(Int.self, forKey: key) {
                return intValue
            } else if let stringValue = try? container.decode(String.self, forKey: key),
                      let intValue = Int(stringValue) {
                return intValue
            }
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Expected Int or String for key \(key)"
            ))
        }

        // Helper to decode number or string as String
        func decodeNumberOrString(_ key: CodingKeys) throws -> String {
            if let stringValue = try? container.decode(String.self, forKey: key) {
                return stringValue
            } else if let intValue = try? container.decode(Int.self, forKey: key) {
                return String(intValue)
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                return String(doubleValue)
            }
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Expected String, Int, or Double for key \(key)"
            ))
        }

        // Helper for optional string/number fields
        func decodeOptionalNumberOrString(_ key: CodingKeys) -> String? {
            if let stringValue = try? container.decode(String.self, forKey: key) {
                return stringValue
            } else if let intValue = try? container.decode(Int.self, forKey: key) {
                return String(intValue)
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                return String(doubleValue)
            }
            return nil
        }

        totalSessions = try decodeIntOrString(.totalSessions)
        totalShots = try decodeIntOrString(.totalShots)
        totalPoints = try decodeNumberOrString(.totalPoints)
        maxPossiblePoints = try decodeIntOrString(.maxPossiblePoints)
        overallAccuracy = try decodeNumberOrString(.overallAccuracy)
        successfulShots = decodeOptionalNumberOrString(.successfulShots)
        successRate = decodeOptionalNumberOrString(.successRate)
        excellentShots = decodeOptionalNumberOrString(.excellentShots)
        excellenceRate = decodeOptionalNumberOrString(.excellenceRate)
        drawAccuracy = try decodeNumberOrString(.drawAccuracy)
        weightedAccuracy = try decodeNumberOrString(.weightedAccuracy)
        improvementTrend = try container.decode(AnalyticsImprovementTrend.self, forKey: .improvementTrend)
    }
}

struct PracticePatterns: Codable {
    let sessionsPerWeek: Int
    let avgDurationMinutes: Int
    let totalPracticeHours: Double
    let minDurationMinutes: Int
    let maxDurationMinutes: Int
    let weeklyFrequency: [WeeklyFrequency]

    enum CodingKeys: String, CodingKey {
        case sessionsPerWeek = "sessions_per_week"
        case avgDurationMinutes = "avg_duration_minutes"
        case totalPracticeHours = "total_practice_hours"
        case minDurationMinutes = "min_duration_minutes"
        case maxDurationMinutes = "max_duration_minutes"
        case weeklyFrequency = "weekly_frequency"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Helper to decode Int or String as Int
        func decodeIntOrString(_ key: CodingKeys) throws -> Int {
            // Check if value is null first
            if let isNull = try? container.decodeNil(forKey: key), isNull {
                return 0
            }
            if let intValue = try? container.decode(Int.self, forKey: key) {
                return intValue
            } else if let stringValue = try? container.decode(String.self, forKey: key),
                      let intValue = Int(stringValue) {
                return intValue
            } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
                return Int(doubleValue)
            }
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Expected Int or String for key \(key), got something else"
            ))
        }

        // Helper to decode Double or String as Double
        func decodeDoubleOrString(_ key: CodingKeys) throws -> Double {
            // Check if value is null first
            if let isNull = try? container.decodeNil(forKey: key), isNull {
                return 0.0
            }
            if let doubleValue = try? container.decode(Double.self, forKey: key) {
                return doubleValue
            } else if let stringValue = try? container.decode(String.self, forKey: key),
                      let doubleValue = Double(stringValue) {
                return doubleValue
            } else if let intValue = try? container.decode(Int.self, forKey: key) {
                return Double(intValue)
            }
            throw DecodingError.typeMismatch(Double.self, DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Expected Double or String for key \(key), got something else"
            ))
        }

        sessionsPerWeek = try decodeIntOrString(.sessionsPerWeek)
        avgDurationMinutes = try decodeIntOrString(.avgDurationMinutes)
        totalPracticeHours = try decodeDoubleOrString(.totalPracticeHours)
        minDurationMinutes = try decodeIntOrString(.minDurationMinutes)
        maxDurationMinutes = try decodeIntOrString(.maxDurationMinutes)
        weeklyFrequency = try container.decode([WeeklyFrequency].self, forKey: .weeklyFrequency)
    }
}

struct WeeklyFrequency: Codable, Identifiable {
    var id: Int { week }
    let week: Int
    let sessions: Int
    let avgDurationMinutes: Int

    enum CodingKeys: String, CodingKey {
        case week
        case sessions
        case avgDurationMinutes = "avg_duration_minutes"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Helper to decode Int or String as Int
        func decodeIntOrString(_ key: CodingKeys) throws -> Int {
            if let intValue = try? container.decode(Int.self, forKey: key) {
                return intValue
            } else if let stringValue = try? container.decode(String.self, forKey: key),
                      let intValue = Int(stringValue) {
                return intValue
            }
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Expected Int or String for key \(key)"
            ))
        }

        week = try decodeIntOrString(.week)
        sessions = try decodeIntOrString(.sessions)
        avgDurationMinutes = try decodeIntOrString(.avgDurationMinutes)
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(area, forKey: .area)
        try container.encode(currentPerformance, forKey: .currentPerformance)
        try container.encode(target, forKey: .target)
        try container.encode(priority, forKey: .priority)
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(drillName, forKey: .drillName)
        try container.encode(description, forKey: .description)
        try container.encode(targetMetrics, forKey: .targetMetrics)
        try container.encode(duration, forKey: .duration)
    }
}
// MARK: - Program Recommendation Models

struct RecommendedProgram: Codable, Identifiable {
    var id: Int { programId }
    let programId: Int
    let programTitle: String
    let relevance: String
    let expectedBenefit: String
    let priority: String

    enum CodingKeys: String, CodingKey {
        case programId = "program_id"
        case programTitle = "program_title"
        case relevance
        case expectedBenefit = "expected_benefit"
        case priority
    }
}

// MARK: - Session AI Analysis Models

struct SessionAIAnalysis: Codable {
    let sessionId: Int
    let analysisDate: String
    let session: SessionDetails?
    let statistics: SessionAIStatistics?
    let overallAssessment: String
    let keyInsights: [String]
    let strengths: [String]
    let areasForImprovement: [AreaForImprovement]
    let recommendedDrills: [RecommendedDrill]
    let recommendedPrograms: [RecommendedProgram]?
    let primaryProgramRecommendation: String?
    let nextSessionFocus: String

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case analysisDate = "analysis_date"
        case session
        case statistics
        case overallAssessment = "overall_assessment"
        case keyInsights = "key_insights"
        case strengths
        case areasForImprovement = "areas_for_improvement"
        case recommendedDrills = "recommended_drills"
        case recommendedPrograms = "recommended_programs"
        case primaryProgramRecommendation = "primary_program_recommendation"
        case nextSessionFocus = "next_session_focus"
    }

    // Encoding is synthesized automatically for all fields
}

struct SessionDetails: Codable {
    let id: Int
    let sessionDate: String
    let location: String
    let clubId: Int?
    let clubName: String?
    let clubDescription: String?
    let greenType: String
    let greenSpeed: Int
    let weather: String?
    let windConditions: String?
    let equipment: SessionEquipment?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case sessionDate = "session_date"
        case location
        case clubId = "club_id"
        case clubName = "club_name"
        case clubDescription = "club_description"
        case greenType = "green_type"
        case greenSpeed = "green_speed"
        case weather
        case windConditions = "wind_conditions"
        case equipment
        case notes
    }
}

struct SessionAIStatistics: Codable {
    let totalShots: Int
    let totalPoints: Int
    let maxPossiblePoints: Int
    let averageScore: Double
    let accuracyPercentage: Double
    let successfulShots: Int
    let successRate: Double
    let excellentShots: Int
    let excellenceRate: Double
    let byHandBreakdown: String?
    let byLengthBreakdown: String?
    let drawShots: Int?
    let drawPoints: Int?
    let drawAccuracyPercentage: Double?
    let yardOnShots: Int?
    let yardOnPoints: Int?
    let yardOnAccuracyPercentage: Double?
    let ditchWeightShots: Int?
    let ditchWeightPoints: Int?
    let ditchWeightAccuracyPercentage: Double?
    let driveShots: Int?
    let drivePoints: Int?
    let driveAccuracyPercentage: Double?

    enum CodingKeys: String, CodingKey {
        case totalShots = "total_shots"
        case totalPoints = "total_points"
        case maxPossiblePoints = "max_possible_points"
        case averageScore = "average_score"
        case accuracyPercentage = "accuracy_percentage"
        case successfulShots = "successful_shots"
        case successRate = "success_rate"
        case excellentShots = "excellent_shots"
        case excellenceRate = "excellence_rate"
        case byHandBreakdown = "by_hand_breakdown"
        case byLengthBreakdown = "by_length_breakdown"
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Helper to decode Int or String as Int
        func decodeIntOrString(_ key: CodingKeys) throws -> Int {
            if let intValue = try? container.decode(Int.self, forKey: key) {
                return intValue
            } else if let stringValue = try? container.decode(String.self, forKey: key),
                      let intValue = Int(stringValue) {
                return intValue
            }
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Expected Int or String for key \(key)"
            ))
        }

        // Helper to decode Double or String as Double
        func decodeDoubleOrString(_ key: CodingKeys) throws -> Double {
            if let doubleValue = try? container.decode(Double.self, forKey: key) {
                return doubleValue
            } else if let stringValue = try? container.decode(String.self, forKey: key),
                      let doubleValue = Double(stringValue) {
                return doubleValue
            } else if let intValue = try? container.decode(Int.self, forKey: key) {
                return Double(intValue)
            }
            throw DecodingError.typeMismatch(Double.self, DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Expected Double or String for key \(key)"
            ))
        }

        // Helper to decode optional Double or String as Double?
        func decodeOptionalDoubleOrString(_ key: CodingKeys) -> Double? {
            if let doubleValue = try? container.decode(Double.self, forKey: key) {
                return doubleValue
            } else if let stringValue = try? container.decode(String.self, forKey: key),
                      let doubleValue = Double(stringValue) {
                return doubleValue
            } else if let intValue = try? container.decode(Int.self, forKey: key) {
                return Double(intValue)
            }
            return nil
        }

        // Helper to decode optional Int or String as Int?
        func decodeOptionalIntOrString(_ key: CodingKeys) -> Int? {
            if let intValue = try? container.decode(Int.self, forKey: key) {
                return intValue
            } else if let stringValue = try? container.decode(String.self, forKey: key),
                      let intValue = Int(stringValue) {
                return intValue
            }
            return nil
        }

        totalShots = try decodeIntOrString(.totalShots)
        totalPoints = try decodeIntOrString(.totalPoints)
        maxPossiblePoints = try decodeIntOrString(.maxPossiblePoints)
        averageScore = try decodeDoubleOrString(.averageScore)
        accuracyPercentage = try decodeDoubleOrString(.accuracyPercentage)
        successfulShots = try decodeIntOrString(.successfulShots)
        successRate = try decodeDoubleOrString(.successRate)
        excellentShots = try decodeIntOrString(.excellentShots)
        excellenceRate = try decodeDoubleOrString(.excellenceRate)
        byHandBreakdown = try container.decodeIfPresent(String.self, forKey: .byHandBreakdown)
        byLengthBreakdown = try container.decodeIfPresent(String.self, forKey: .byLengthBreakdown)
        drawShots = decodeOptionalIntOrString(.drawShots)
        drawPoints = decodeOptionalIntOrString(.drawPoints)
        drawAccuracyPercentage = decodeOptionalDoubleOrString(.drawAccuracyPercentage)
        yardOnShots = decodeOptionalIntOrString(.yardOnShots)
        yardOnPoints = decodeOptionalIntOrString(.yardOnPoints)
        yardOnAccuracyPercentage = decodeOptionalDoubleOrString(.yardOnAccuracyPercentage)
        ditchWeightShots = decodeOptionalIntOrString(.ditchWeightShots)
        ditchWeightPoints = decodeOptionalIntOrString(.ditchWeightPoints)
        ditchWeightAccuracyPercentage = decodeOptionalDoubleOrString(.ditchWeightAccuracyPercentage)
        driveShots = decodeOptionalIntOrString(.driveShots)
        drivePoints = decodeOptionalIntOrString(.drivePoints)
        driveAccuracyPercentage = decodeOptionalDoubleOrString(.driveAccuracyPercentage)
    }
}

// MARK: - Shot Type Summary Models
struct ShotTypeSummaryResponse: Codable {
    let status: String
    let data: ShotTypeSummaryData
}

struct ShotTypeSummaryData: Codable {
    let draw: ShotTypeSummaryStats
    let yardOn: ShotTypeSummaryStats
    let ditchWeight: ShotTypeSummaryStats
    let drive: ShotTypeSummaryStats

    enum CodingKeys: String, CodingKey {
        case draw
        case yardOn = "yard_on"
        case ditchWeight = "ditch_weight"
        case drive
    }
}

struct ShotTypeSummaryStats: Codable {
    let totalShots: Int
    let totalPoints: Int
    let accuracyPercentage: Double

    enum CodingKeys: String, CodingKey {
        case totalShots = "total_shots"
        case totalPoints = "total_points"
        case accuracyPercentage = "accuracy_percentage"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // totalShots as Int
        totalShots = try container.decode(Int.self, forKey: .totalShots)

        // totalPoints can be String or Int
        if let pointsString = try? container.decode(String.self, forKey: .totalPoints) {
            totalPoints = Int(pointsString) ?? 0
        } else {
            totalPoints = try container.decode(Int.self, forKey: .totalPoints)
        }

        // accuracyPercentage can be String or Double
        if let accuracyString = try? container.decode(String.self, forKey: .accuracyPercentage) {
            accuracyPercentage = Double(accuracyString) ?? 0.0
        } else {
            accuracyPercentage = try container.decode(Double.self, forKey: .accuracyPercentage)
        }
    }
}
