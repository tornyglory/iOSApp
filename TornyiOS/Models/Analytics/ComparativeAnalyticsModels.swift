import Foundation

// MARK: - Helper Types

enum StringOrDouble: Codable {
    case string(String)
    case double(Double)
    case int(Int)

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
            throw DecodingError.typeMismatch(StringOrDouble.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Value is not string, double, or int"))
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

// MARK: - Comparative Analytics Models

struct ComparativeAnalyticsResponse: Codable {
    let sport: String
    let period: String
    let dateRange: DateRange
    let radarChart: RadarChartData
    let heatmapData: [HeatmapDataPoint]
    let lengthMatrix: LengthMatrix
    let timePerformance: [TimePerformancePoint]
    let sequenceAnalysis: [SequenceAnalysisPoint]
    let weatherAnalysis: [WeatherAnalysisPoint]?
    let windAnalysis: [WindAnalysisPoint]?
    let handShotBreakdown: [HandShotBreakdown]?
    let insights: AnalyticsInsights

    enum CodingKeys: String, CodingKey {
        case sport
        case period
        case dateRange = "date_range"
        case radarChart = "radar_chart"
        case heatmapData = "heatmap_data"
        case lengthMatrix = "length_matrix"
        case timePerformance = "time_performance"
        case sequenceAnalysis = "sequence_analysis"
        case weatherAnalysis = "weather_analysis"
        case windAnalysis = "wind_analysis"
        case handShotBreakdown = "hand_shot_breakdown"
        case insights
    }
}

struct RadarChartData: Codable {
    let categories: [String]
    let series: [RadarSeries]
}

struct RadarSeries: Codable, Identifiable {
    let id = UUID()
    let name: String
    let data: [Double]

    enum CodingKeys: String, CodingKey {
        case name
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)

        // Handle data array that may contain strings or numbers
        let dataArray = try container.decode([StringOrDouble].self, forKey: .data)
        data = dataArray.map { $0.doubleValue }
    }

    init(name: String, data: [Double]) {
        self.name = name
        self.data = data
    }
}

struct HeatmapDataPoint: Codable, Identifiable {
    let id = UUID()
    let x: String
    let y: String
    let value: Double
    let sessions: Int
    let shots: Int
    let conditions: PlayingConditions

    enum CodingKeys: String, CodingKey {
        case x
        case y
        case value
        case sessions
        case shots
        case conditions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        x = try container.decode(String.self, forKey: .x)
        y = try container.decode(String.self, forKey: .y)

        // Handle value that may be string or double
        if let stringValue = try? container.decode(String.self, forKey: .value) {
            value = Double(stringValue) ?? 0
        } else {
            value = try container.decode(Double.self, forKey: .value)
        }

        sessions = try container.decode(Int.self, forKey: .sessions)
        shots = try container.decode(Int.self, forKey: .shots)
        conditions = try container.decode(PlayingConditions.self, forKey: .conditions)
    }

    struct PlayingConditions: Codable {
        let location: String
        let greenType: String
        let greenSpeed: Int
        let weather: String?
        let windConditions: String?

        enum CodingKeys: String, CodingKey {
            case location
            case greenType = "green_type"
            case greenSpeed = "green_speed"
            case weather
            case windConditions = "wind_conditions"
        }
    }
}

struct LengthMatrix: Codable {
    let short: [String: LengthMatrixData]?
    let medium: [String: LengthMatrixData]
    let long: [String: LengthMatrixData]?

    struct LengthMatrixData: Codable {
        let shots: Int
        let accuracy: Double
        let points: Int

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            shots = try container.decode(Int.self, forKey: .shots)

            // Handle accuracy that may be string or double
            if let stringValue = try? container.decode(String.self, forKey: .accuracy) {
                accuracy = Double(stringValue) ?? 0
            } else {
                accuracy = try container.decode(Double.self, forKey: .accuracy)
            }

            // Handle points that may be string or int
            if let stringValue = try? container.decode(String.self, forKey: .points) {
                points = Int(stringValue) ?? 0
            } else {
                points = try container.decode(Int.self, forKey: .points)
            }
        }

        enum CodingKeys: String, CodingKey {
            case shots
            case accuracy
            case points
        }
    }
}

struct TimePerformancePoint: Codable, Identifiable {
    let id = UUID()
    let hour: Int
    let period: String
    let accuracy: Double
    let sessions: Int
    let shots: Int

    enum CodingKeys: String, CodingKey {
        case hour
        case period
        case accuracy
        case sessions
        case shots
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hour = try container.decode(Int.self, forKey: .hour)
        period = try container.decode(String.self, forKey: .period)

        // Handle accuracy that may be string or double
        if let stringValue = try? container.decode(String.self, forKey: .accuracy) {
            accuracy = Double(stringValue) ?? 0
        } else {
            accuracy = try container.decode(Double.self, forKey: .accuracy)
        }

        sessions = try container.decode(Int.self, forKey: .sessions)
        shots = try container.decode(Int.self, forKey: .shots)
    }
}

struct SequenceAnalysisPoint: Codable, Identifiable {
    let id = UUID()
    let position: Int
    let accuracy: Double
    let avgScore: Double
    let shots: Int

    enum CodingKeys: String, CodingKey {
        case position
        case accuracy
        case avgScore = "avg_score"
        case shots
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        position = try container.decode(Int.self, forKey: .position)

        // Handle accuracy that may be string or double
        if let stringValue = try? container.decode(String.self, forKey: .accuracy) {
            accuracy = Double(stringValue) ?? 0
        } else {
            accuracy = try container.decode(Double.self, forKey: .accuracy)
        }

        // Handle avgScore that may be string or double
        if let stringValue = try? container.decode(String.self, forKey: .avgScore) {
            avgScore = Double(stringValue) ?? 0
        } else {
            avgScore = try container.decode(Double.self, forKey: .avgScore)
        }

        shots = try container.decode(Int.self, forKey: .shots)
    }
}

struct WeatherAnalysisPoint: Codable {
    let weather: String
    let sessions: Int
    let totalShots: Int
    let totalPoints: StringOrDouble
    let accuracy: StringOrDouble

    enum CodingKeys: String, CodingKey {
        case weather
        case sessions
        case totalShots = "total_shots"
        case totalPoints = "total_points"
        case accuracy
    }
}

struct WindAnalysisPoint: Codable {
    let windConditions: String
    let sessions: Int
    let totalShots: Int
    let totalPoints: StringOrDouble
    let accuracy: StringOrDouble

    enum CodingKeys: String, CodingKey {
        case windConditions = "wind_conditions"
        case sessions
        case totalShots = "total_shots"
        case totalPoints = "total_points"
        case accuracy
    }
}

struct HandShotBreakdown: Codable {
    let hand: String
    let shotType: String
    let shots: Int
    let points: StringOrDouble
    let maxPoints: Int
    let accuracy: StringOrDouble

    enum CodingKeys: String, CodingKey {
        case hand
        case shotType = "shot_type"
        case shots
        case points
        case maxPoints = "max_points"
        case accuracy
    }
}

struct AnalyticsInsights: Codable {
    let bestHandShotCombo: BestHandShotCombo
    let optimalConditions: OptimalConditions
    let sessionFatigue: SessionFatigue
    let bestWeather: BestWeather?
    let bestWindConditions: BestWindConditions?

    enum CodingKeys: String, CodingKey {
        case bestHandShotCombo = "best_hand_shot_combo"
        case optimalConditions = "optimal_conditions"
        case sessionFatigue = "session_fatigue"
        case bestWeather = "best_weather"
        case bestWindConditions = "best_wind_conditions"
    }

    struct BestHandShotCombo: Codable {
        let hand: String
        let shotType: String
        let accuracy: Double
        let shots: Int

        enum CodingKeys: String, CodingKey {
            case hand
            case shotType = "shot_type"
            case accuracy
            case shots
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            hand = try container.decode(String.self, forKey: .hand)
            shotType = try container.decode(String.self, forKey: .shotType)

            // Handle accuracy that may be string or double
            if let stringValue = try? container.decode(String.self, forKey: .accuracy) {
                accuracy = Double(stringValue) ?? 0
            } else {
                accuracy = try container.decode(Double.self, forKey: .accuracy)
            }

            shots = try container.decode(Int.self, forKey: .shots)
        }
    }

    struct OptimalConditions: Codable {
        let description: String
        let accuracy: Double
        let sessions: Int

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            description = try container.decode(String.self, forKey: .description)

            // Handle accuracy that may be string or double
            if let stringValue = try? container.decode(String.self, forKey: .accuracy) {
                accuracy = Double(stringValue) ?? 0
            } else {
                accuracy = try container.decode(Double.self, forKey: .accuracy)
            }

            sessions = try container.decode(Int.self, forKey: .sessions)
        }

        enum CodingKeys: String, CodingKey {
            case description
            case accuracy
            case sessions
        }
    }

    struct SessionFatigue: Codable {
        let earlyAccuracy: Double?
        let lateAccuracy: Double?

        enum CodingKeys: String, CodingKey {
            case earlyAccuracy = "early_accuracy"
            case lateAccuracy = "late_accuracy"
        }
    }

    struct BestWeather: Codable {
        let weather: String
        let accuracy: StringOrDouble
        let sessions: Int
    }

    struct BestWindConditions: Codable {
        let windConditions: String
        let accuracy: StringOrDouble
        let sessions: Int

        enum CodingKeys: String, CodingKey {
            case windConditions = "wind_conditions"
            case accuracy
            case sessions
        }
    }
}

// MARK: - Query Parameters

struct ComparativeAnalyticsQuery {
    let period: String // "week"|"month"|"year"|"all"
    let sport: String

    init(period: String = "all", sport: String = "lawn_bowls") {
        self.period = period
        self.sport = sport
    }

    var queryItems: [URLQueryItem] {
        return [
            URLQueryItem(name: "period", value: period),
            URLQueryItem(name: "sport", value: sport)
        ]
    }
}

// MARK: - Chart View Data Models

struct ComparativeAnalyticsViewData {
    let radarChart: RadarChartData
    let heatmapData: [HeatmapDataPoint]
    let lengthMatrix: LengthMatrix
    let timePerformance: [TimePerformancePoint]
    let sequenceAnalysis: [SequenceAnalysisPoint]
    let insights: AnalyticsInsights

    var hasData: Bool {
        return !radarChart.categories.isEmpty || !heatmapData.isEmpty
    }

    var bestPerformanceTime: String {
        let bestTime = timePerformance.max { $0.accuracy < $1.accuracy }
        if let best = bestTime {
            return "\(best.period) (\(String(format: "%.1f%%", best.accuracy)))"
        }
        return "N/A"
    }

    var worstPerformanceTime: String {
        let worstTime = timePerformance.min { $0.accuracy < $1.accuracy }
        if let worst = worstTime {
            return "\(worst.period) (\(String(format: "%.1f%%", worst.accuracy)))"
        }
        return "N/A"
    }

    var fatigueEffect: String {
        let fatigue = insights.sessionFatigue

        guard let earlyAcc = fatigue.earlyAccuracy,
              let lateAcc = fatigue.lateAccuracy else {
            return "📊 Insufficient data for fatigue analysis"
        }

        let difference = earlyAcc - lateAcc

        if difference > 5 {
            return "⚠️ Notable fatigue effect (\(String(format: "%.1f%%", difference)) drop)"
        } else if difference > 0 {
            return "📊 Mild fatigue effect (\(String(format: "%.1f%%", difference)) drop)"
        } else {
            return "🎯 No significant fatigue effect"
        }
    }

    var bestConditionsDescription: String {
        let conditions = insights.optimalConditions
        return "\(conditions.description) - \(String(format: "%.1f%%", conditions.accuracy)) accuracy"
    }

    var bestComboDescription: String {
        let combo = insights.bestHandShotCombo
        return "\(combo.hand.capitalized) \(combo.shotType.replacingOccurrences(of: "_", with: " ")) - \(String(format: "%.1f%%", combo.accuracy))"
    }

    // Helper functions for chart data
    var radarChartPoints: [(category: String, forehand: Double, backhand: Double)] {
        guard radarChart.categories.count == radarChart.series.first?.data.count,
              let forehandSeries = radarChart.series.first(where: { $0.name == "forehand" }),
              let backhandSeries = radarChart.series.first(where: { $0.name == "backhand" }) else {
            return []
        }

        return zip3(radarChart.categories, forehandSeries.data, backhandSeries.data)
            .map { (category: $0, forehand: $1, backhand: $2) }
    }

    var heatmapMatrix: [[HeatmapCell]] {
        // Group heatmap data into a matrix format for display
        let xValues = Set(heatmapData.map { $0.x }).sorted()
        let yValues = Set(heatmapData.map { $0.y }).sorted()

        return yValues.map { y in
            xValues.map { x in
                let point = heatmapData.first { $0.x == x && $0.y == y }
                return HeatmapCell(
                    x: x,
                    y: y,
                    value: point?.value ?? 0,
                    hasData: point != nil
                )
            }
        }
    }
}

struct HeatmapCell {
    let x: String
    let y: String
    let value: Double
    let hasData: Bool
}

// Helper function for zip3
func zip3<A, B, C>(_ a: [A], _ b: [B], _ c: [C]) -> [(A, B, C)] {
    return Array(zip(zip(a, b), c).map { ($0.0, $0.1, $1) })
}