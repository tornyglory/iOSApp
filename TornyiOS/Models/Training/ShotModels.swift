import Foundation

// MARK: - Training Shot Models

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

// MARK: - Shot Statistics Models

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

    // Computed properties to match the old interface
    var successfulShots: Int {
        // Calculate successful shots from total shots and accuracy percentage
        let accuracy = Double(accuracyPercentage) ?? 0.0
        return Int(round(Double(totalShots) * accuracy / 100.0))
    }

    var overallAccuracy: Double {
        return Double(accuracyPercentage) ?? 0.0
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

    func displayAccuracyForType(_ type: String) -> String? {
        let shots = Int(shotCountForType(type)) ?? 0
        let points = Int(pointsForType(type)) ?? 0

        // If no shots, return nil
        guard shots > 0 else { return nil }

        // Calculate accuracy: (points / (shots * 2)) * 100
        // Each shot can score 0, 1, or 2 points, so max possible is shots * 2
        let maxPossiblePoints = shots * 2
        let accuracy = (Double(points) / Double(maxPossiblePoints)) * 100.0

        return String(format: "%.1f", accuracy)
    }
}

struct DrawBreakdown: Codable {
    let foot: Int
    let yard: Int
    let miss: Int
}