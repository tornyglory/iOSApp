import Foundation

// MARK: - Helper Types

enum StringOrNumber: Codable {
    case string(String)
    case double(Double)
    case int(Int)

    var stringValue: String {
        switch self {
        case .string(let str):
            return str
        case .double(let value):
            return String(value)
        case .int(let value):
            return String(value)
        }
    }

    var doubleValue: Double {
        switch self {
        case .string(let str):
            return Double(str) ?? 0
        case .double(let value):
            return value
        case .int(let value):
            return Double(value)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Check for null values first
        if container.decodeNil() {
            // Default to 0 for null values
            self = .double(0)
            return
        }

        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(StringOrNumber.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Value is not string, double, or int"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        }
    }
}

// MARK: - Progress Chart Data Models

struct ProgressChartResponse: Codable {
    let sport: String
    let period: String
    let groupBy: String
    let totalPeriods: Int
    let dateRange: DateRange
    let chartData: ProgressChartData
    let trends: ProgressAnalyticsTrends
    let recentMilestones: [RecentMilestone]
    let summary: ChartProgressSummary?
    let lastUpdated: String

    enum CodingKeys: String, CodingKey {
        case sport
        case period
        case groupBy = "group_by"
        case totalPeriods = "total_periods"
        case dateRange = "date_range"
        case chartData = "chart_data"
        case trends
        case recentMilestones = "recent_milestones"
        case summary
        case lastUpdated = "last_updated"
    }
}

struct DateRange: Codable {
    let start: String
    let end: String
}

struct ProgressChartData: Codable {
    let accuracyTrend: [AccuracyTrendPoint]
    let volumeData: [VolumeDataPoint]
    let scoreProgression: [ScoreProgressionPoint]
    let conditionsAnalysis: [ConditionsAnalysisPoint]

    enum CodingKeys: String, CodingKey {
        case accuracyTrend = "accuracy_trend"
        case volumeData = "volume_data"
        case scoreProgression = "score_progression"
        case conditionsAnalysis = "conditions_analysis"
    }
}

struct AccuracyTrendPoint: Codable, Identifiable {
    let id = UUID()
    let x: String
    let period: String
    let overallAccuracy: Double
    let drawAccuracy: Double
    let weightedAccuracy: Double?
    let sessions: Int
    let totalShots: Int
    let index: Int

    enum CodingKeys: String, CodingKey {
        case x
        case period
        case overallAccuracy = "overall_accuracy"
        case drawAccuracy = "draw_accuracy"
        case weightedAccuracy = "weighted_accuracy"
        case sessions
        case totalShots = "total_shots"
        case index
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        x = try container.decode(String.self, forKey: .x)

        // Handle period that can be string or number
        let periodValue = try container.decode(StringOrNumber.self, forKey: .period)
        period = periodValue.stringValue

        // Handle accuracy values that may be strings
        let overallAccValue = try container.decode(StringOrNumber.self, forKey: .overallAccuracy)
        overallAccuracy = overallAccValue.doubleValue

        let drawAccValue = try container.decode(StringOrNumber.self, forKey: .drawAccuracy)
        drawAccuracy = drawAccValue.doubleValue

        // Handle optional weighted accuracy
        if let weightedAccValue = try? container.decode(StringOrNumber.self, forKey: .weightedAccuracy) {
            weightedAccuracy = weightedAccValue.doubleValue
        } else {
            weightedAccuracy = nil
        }

        sessions = try container.decode(Int.self, forKey: .sessions)
        totalShots = try container.decode(Int.self, forKey: .totalShots)
        index = try container.decode(Int.self, forKey: .index)
    }
}

struct VolumeDataPoint: Codable, Identifiable {
    let id = UUID()
    let x: String
    let period: String
    let sessions: Int
    let shots: Int
    let avgShotsPerSession: Double
    let index: Int

    enum CodingKeys: String, CodingKey {
        case x
        case period
        case sessions
        case shots
        case avgShotsPerSession = "avg_shots_per_session"
        case index
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        x = try container.decode(String.self, forKey: .x)

        // Handle period that can be string or number
        let periodValue = try container.decode(StringOrNumber.self, forKey: .period)
        period = periodValue.stringValue

        sessions = try container.decode(Int.self, forKey: .sessions)
        shots = try container.decode(Int.self, forKey: .shots)
        avgShotsPerSession = try container.decode(Double.self, forKey: .avgShotsPerSession)
        index = try container.decode(Int.self, forKey: .index)
    }
}

struct ScoreProgressionPoint: Codable, Identifiable {
    let id = UUID()
    let x: String
    let period: String
    let points: Int
    let maxPoints: Int
    let percentage: Double
    let index: Int

    enum CodingKeys: String, CodingKey {
        case x
        case period
        case points
        case maxPoints = "max_points"
        case percentage
        case index
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        x = try container.decode(String.self, forKey: .x)

        // Handle period that can be string or number
        let periodValue = try container.decode(StringOrNumber.self, forKey: .period)
        period = periodValue.stringValue

        // Handle points that may be string or int
        if let pointsString = try? container.decode(String.self, forKey: .points) {
            points = Int(pointsString) ?? 0
        } else {
            points = try container.decode(Int.self, forKey: .points)
        }

        maxPoints = try container.decode(Int.self, forKey: .maxPoints)

        // Handle percentage that may be string or double
        if let percentageString = try? container.decode(String.self, forKey: .percentage) {
            percentage = Double(percentageString) ?? 0
        } else {
            percentage = try container.decode(Double.self, forKey: .percentage)
        }

        index = try container.decode(Int.self, forKey: .index)
    }
}

struct ConditionsAnalysisPoint: Codable, Identifiable {
    let id = UUID()
    let x: String
    let period: String
    let avgGreenSpeed: Double
    let outdoorPercentage: Int
    let indoorPercentage: Int
    let index: Int

    enum CodingKeys: String, CodingKey {
        case x
        case period
        case avgGreenSpeed = "avg_green_speed"
        case outdoorPercentage = "outdoor_percentage"
        case indoorPercentage = "indoor_percentage"
        case index
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        x = try container.decode(String.self, forKey: .x)

        // Handle period that can be string or number
        let periodValue = try container.decode(StringOrNumber.self, forKey: .period)
        period = periodValue.stringValue

        avgGreenSpeed = try container.decode(Double.self, forKey: .avgGreenSpeed)
        outdoorPercentage = try container.decode(Int.self, forKey: .outdoorPercentage)
        indoorPercentage = try container.decode(Int.self, forKey: .indoorPercentage)
        index = try container.decode(Int.self, forKey: .index)
    }
}

struct ProgressAnalyticsTrends: Codable {
    let accuracy: String?
    let volume: String?
    let consistency: String?
}

struct RecentMilestone: Codable, Identifiable {
    let id = UUID()
    let sessionDate: String
    let sessionId: Int
    let shotsInSession: Int
    let sessionAccuracy: Double

    enum CodingKeys: String, CodingKey {
        case sessionDate = "session_date"
        case sessionId = "session_id"
        case shotsInSession = "shots_in_session"
        case sessionAccuracy = "session_accuracy"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        sessionDate = try container.decode(String.self, forKey: .sessionDate)
        sessionId = try container.decode(Int.self, forKey: .sessionId)
        shotsInSession = try container.decode(Int.self, forKey: .shotsInSession)

        // Handle sessionAccuracy that may be string or double
        if let accuracyString = try? container.decode(String.self, forKey: .sessionAccuracy) {
            sessionAccuracy = Double(accuracyString) ?? 0
        } else {
            sessionAccuracy = try container.decode(Double.self, forKey: .sessionAccuracy)
        }
    }
}

struct ChartProgressSummary: Codable {
    let totalSessions: Int
    let totalShots: Int
    let averageAccuracy: Double?
    let bestPeriod: ChartBestPeriod?

    enum CodingKeys: String, CodingKey {
        case totalSessions = "total_sessions"
        case totalShots = "total_shots"
        case averageAccuracy = "average_accuracy"
        case bestPeriod = "best_period"
    }
}

struct ChartBestPeriod: Codable {
    let period: String
    let periodStart: String
    let periodEnd: String
    let sessions: Int
    let totalShots: Int
    let totalPoints: String
    let maxPossiblePoints: Int
    let overallAccuracy: String
    let drawShots: String?
    let drawPoints: String?
    let drawAccuracy: String?
    let yardOnShots: String?
    let yardOnPoints: String?
    let yardOnAccuracy: String?
    let ditchWeightShots: String?
    let ditchWeightPoints: String?
    let ditchWeightAccuracy: String?
    let driveShots: String?
    let drivePoints: String?
    let driveAccuracy: String?
    let shortShots: String?
    let shortPoints: String?
    let shortAccuracy: String?
    let mediumShots: String?
    let mediumPoints: String?
    let mediumAccuracy: String?
    let longShots: String?
    let longPoints: String?
    let longAccuracy: String?
    let forehandShots: String?
    let forehandPoints: String?
    let forehandAccuracy: String?
    let backhandShots: String?
    let backhandPoints: String?
    let backhandAccuracy: String?
    let footShots: String?
    let yardShots: String?
    let missShots: String?
    let footPercentage: String?
    let yardPercentage: String?
    let missPercentage: String?
    let avgGreenSpeed: String?
    let minGreenSpeed: Int?
    let maxGreenSpeed: Int?
    let outdoorSessions: String?
    let indoorSessions: String?

    enum CodingKeys: String, CodingKey {
        case period
        case periodStart = "period_start"
        case periodEnd = "period_end"
        case sessions
        case totalShots = "total_shots"
        case totalPoints = "total_points"
        case maxPossiblePoints = "max_possible_points"
        case overallAccuracy = "overall_accuracy"
        case drawShots = "draw_shots"
        case drawPoints = "draw_points"
        case drawAccuracy = "draw_accuracy"
        case yardOnShots = "yard_on_shots"
        case yardOnPoints = "yard_on_points"
        case yardOnAccuracy = "yard_on_accuracy"
        case ditchWeightShots = "ditch_weight_shots"
        case ditchWeightPoints = "ditch_weight_points"
        case ditchWeightAccuracy = "ditch_weight_accuracy"
        case driveShots = "drive_shots"
        case drivePoints = "drive_points"
        case driveAccuracy = "drive_accuracy"
        case shortShots = "short_shots"
        case shortPoints = "short_points"
        case shortAccuracy = "short_accuracy"
        case mediumShots = "medium_shots"
        case mediumPoints = "medium_points"
        case mediumAccuracy = "medium_accuracy"
        case longShots = "long_shots"
        case longPoints = "long_points"
        case longAccuracy = "long_accuracy"
        case forehandShots = "forehand_shots"
        case forehandPoints = "forehand_points"
        case forehandAccuracy = "forehand_accuracy"
        case backhandShots = "backhand_shots"
        case backhandPoints = "backhand_points"
        case backhandAccuracy = "backhand_accuracy"
        case footShots = "foot_shots"
        case yardShots = "yard_shots"
        case missShots = "miss_shots"
        case footPercentage = "foot_percentage"
        case yardPercentage = "yard_percentage"
        case missPercentage = "miss_percentage"
        case avgGreenSpeed = "avg_green_speed"
        case minGreenSpeed = "min_green_speed"
        case maxGreenSpeed = "max_green_speed"
        case outdoorSessions = "outdoor_sessions"
        case indoorSessions = "indoor_sessions"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Handle period that can be string or number
        let periodValue = try container.decode(StringOrNumber.self, forKey: .period)
        period = periodValue.stringValue

        periodStart = try container.decode(String.self, forKey: .periodStart)
        periodEnd = try container.decode(String.self, forKey: .periodEnd)
        sessions = try container.decode(Int.self, forKey: .sessions)
        totalShots = try container.decode(Int.self, forKey: .totalShots)
        totalPoints = try container.decode(String.self, forKey: .totalPoints)
        maxPossiblePoints = try container.decode(Int.self, forKey: .maxPossiblePoints)
        overallAccuracy = try container.decode(String.self, forKey: .overallAccuracy)

        // All shot type fields are optional
        drawShots = try? container.decode(String.self, forKey: .drawShots)
        drawPoints = try? container.decode(String.self, forKey: .drawPoints)
        drawAccuracy = try? container.decode(String.self, forKey: .drawAccuracy)
        yardOnShots = try? container.decode(String.self, forKey: .yardOnShots)
        yardOnPoints = try? container.decode(String.self, forKey: .yardOnPoints)
        yardOnAccuracy = try? container.decode(String.self, forKey: .yardOnAccuracy)
        ditchWeightShots = try? container.decode(String.self, forKey: .ditchWeightShots)
        ditchWeightPoints = try? container.decode(String.self, forKey: .ditchWeightPoints)
        ditchWeightAccuracy = try? container.decode(String.self, forKey: .ditchWeightAccuracy)
        driveShots = try? container.decode(String.self, forKey: .driveShots)
        drivePoints = try? container.decode(String.self, forKey: .drivePoints)
        driveAccuracy = try? container.decode(String.self, forKey: .driveAccuracy)
        shortShots = try? container.decode(String.self, forKey: .shortShots)
        shortPoints = try? container.decode(String.self, forKey: .shortPoints)
        shortAccuracy = try? container.decode(String.self, forKey: .shortAccuracy)
        mediumShots = try? container.decode(String.self, forKey: .mediumShots)
        mediumPoints = try? container.decode(String.self, forKey: .mediumPoints)
        mediumAccuracy = try? container.decode(String.self, forKey: .mediumAccuracy)
        longShots = try? container.decode(String.self, forKey: .longShots)
        longPoints = try? container.decode(String.self, forKey: .longPoints)
        longAccuracy = try? container.decode(String.self, forKey: .longAccuracy)
        forehandShots = try? container.decode(String.self, forKey: .forehandShots)
        forehandPoints = try? container.decode(String.self, forKey: .forehandPoints)
        forehandAccuracy = try? container.decode(String.self, forKey: .forehandAccuracy)
        backhandShots = try? container.decode(String.self, forKey: .backhandShots)
        backhandPoints = try? container.decode(String.self, forKey: .backhandPoints)
        backhandAccuracy = try? container.decode(String.self, forKey: .backhandAccuracy)
        footShots = try? container.decode(String.self, forKey: .footShots)
        yardShots = try? container.decode(String.self, forKey: .yardShots)
        missShots = try? container.decode(String.self, forKey: .missShots)
        footPercentage = try? container.decode(String.self, forKey: .footPercentage)
        yardPercentage = try? container.decode(String.self, forKey: .yardPercentage)
        missPercentage = try? container.decode(String.self, forKey: .missPercentage)
        avgGreenSpeed = try? container.decode(String.self, forKey: .avgGreenSpeed)
        minGreenSpeed = try? container.decode(Int.self, forKey: .minGreenSpeed)
        maxGreenSpeed = try? container.decode(Int.self, forKey: .maxGreenSpeed)
        outdoorSessions = try? container.decode(String.self, forKey: .outdoorSessions)
        indoorSessions = try? container.decode(String.self, forKey: .indoorSessions)
    }
}

// MARK: - Query Parameters

struct ProgressChartQuery {
    let groupBy: String // "day"|"week"|"month"
    let period: String // "week"|"month"|"year"|"all"
    let limit: Int
    let shotType: String?
    let sport: String

    init(groupBy: String = "week", period: String = "all", limit: Int = 24, shotType: String? = nil, sport: String = "lawn_bowls") {
        self.groupBy = groupBy
        self.period = period
        self.limit = limit
        self.shotType = shotType
        self.sport = sport
    }

    var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "group_by", value: groupBy),
            URLQueryItem(name: "period", value: period),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "sport", value: sport)
        ]

        if let shotType = shotType {
            items.append(URLQueryItem(name: "shot_type", value: shotType))
        }

        return items
    }
}

// MARK: - Chart View Data Models

struct ProgressChartViewData {
    let accuracyTrend: [AccuracyTrendPoint]
    let volumeData: [VolumeDataPoint]
    let scoreProgression: [ScoreProgressionPoint]
    let conditionsAnalysis: [ConditionsAnalysisPoint]
    let trends: ProgressAnalyticsTrends
    let milestones: [RecentMilestone]
    let dateRange: DateRange

    var hasData: Bool {
        return !accuracyTrend.isEmpty || !volumeData.isEmpty
    }

    var accuracyTrendDescription: String {
        guard let accuracy = trends.accuracy else {
            return "📊 No trend data available"
        }
        if accuracy.hasPrefix("+") {
            return "📈 Improving by \(accuracy)"
        } else if accuracy.hasPrefix("-") {
            return "📉 Declining by \(accuracy)"
        } else {
            return "📊 \(accuracy)"
        }
    }

    var volumeTrendDescription: String {
        guard let volume = trends.volume else {
            return "📊 No trend data available"
        }
        if let value = Double(volume.replacingOccurrences(of: "+", with: "")), value > 0 {
            return "📈 Up \(volume) shots/week"
        } else {
            return "📊 \(volume) shots/week"
        }
    }

    var consistencyDescription: String {
        guard let consistency = trends.consistency else {
            return "📊 No trend data available"
        }
        switch consistency.lowercased() {
        case "improving":
            return "🎯 Getting more consistent"
        case "declining":
            return "⚠️ Consistency declining"
        default:
            return "📊 \(consistency.capitalized)"
        }
    }
}