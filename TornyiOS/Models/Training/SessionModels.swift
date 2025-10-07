import Foundation
import SwiftUI

// MARK: - Training Session Models

// Equipment details for a session
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
    let startedAt: Date?
    let endedAt: Date?
    let durationSeconds: Int?
    let isActive: Bool?

    // Statistics
    let totalShots: Int?
    let successfulShots: Int?
    let overallAccuracy: Double?
    let drawShots: Int?
    let drawAccuracy: Double?
    let yardOnShots: Int?
    let yardOnAccuracy: Double?
    let ditchWeightShots: Int?
    let ditchWeightAccuracy: Double?
    let driveShots: Int?
    let driveAccuracy: Double?

    // Club details
    let clubId: Int?
    let clubName: String?
    let clubDescription: String?

    // Equipment details
    let equipment: SessionEquipment?

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
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case durationSeconds = "duration_seconds"
        case isActive = "is_active"
        case totalShots = "total_shots"
        case successfulShots = "successful_shots"
        case overallAccuracy = "overall_accuracy"
        case drawShots = "draw_shots"
        case drawAccuracy = "draw_accuracy"
        case yardOnShots = "yard_on_shots"
        case yardOnAccuracy = "yard_on_accuracy"
        case ditchWeightShots = "ditch_weight_shots"
        case ditchWeightAccuracy = "ditch_weight_accuracy"
        case driveShots = "drive_shots"
        case driveAccuracy = "drive_accuracy"
        case clubId = "club_id"
        case clubName = "club_name"
        case clubDescription = "club_description"
        case equipment
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Basic fields
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
        durationSeconds = try container.decodeIfPresent(Int.self, forKey: .durationSeconds)

        // Boolean fields - handle as Int from MySQL
        if let activeInt = try container.decodeIfPresent(Int.self, forKey: .isActive) {
            isActive = activeInt == 1
        } else {
            isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive)
        }

        // Statistics
        totalShots = try container.decodeIfPresent(Int.self, forKey: .totalShots)
        successfulShots = try container.decodeIfPresent(Int.self, forKey: .successfulShots)

        // Handle accuracy fields that might come as strings
        if let drawAccuracyString = try container.decodeIfPresent(String.self, forKey: .drawAccuracy) {
            drawAccuracy = Double(drawAccuracyString)
        } else {
            drawAccuracy = try container.decodeIfPresent(Double.self, forKey: .drawAccuracy)
        }

        if let yardOnAccuracyString = try container.decodeIfPresent(String.self, forKey: .yardOnAccuracy) {
            yardOnAccuracy = Double(yardOnAccuracyString)
        } else {
            yardOnAccuracy = try container.decodeIfPresent(Double.self, forKey: .yardOnAccuracy)
        }

        if let ditchWeightAccuracyString = try container.decodeIfPresent(String.self, forKey: .ditchWeightAccuracy) {
            ditchWeightAccuracy = Double(ditchWeightAccuracyString)
        } else {
            ditchWeightAccuracy = try container.decodeIfPresent(Double.self, forKey: .ditchWeightAccuracy)
        }

        if let driveAccuracyString = try container.decodeIfPresent(String.self, forKey: .driveAccuracy) {
            driveAccuracy = Double(driveAccuracyString)
        } else {
            driveAccuracy = try container.decodeIfPresent(Double.self, forKey: .driveAccuracy)
        }

        if let overallAccuracyString = try container.decodeIfPresent(String.self, forKey: .overallAccuracy) {
            overallAccuracy = Double(overallAccuracyString)
        } else {
            overallAccuracy = try container.decodeIfPresent(Double.self, forKey: .overallAccuracy)
        }

        drawShots = try container.decodeIfPresent(Int.self, forKey: .drawShots)
        yardOnShots = try container.decodeIfPresent(Int.self, forKey: .yardOnShots)
        ditchWeightShots = try container.decodeIfPresent(Int.self, forKey: .ditchWeightShots)
        driveShots = try container.decodeIfPresent(Int.self, forKey: .driveShots)

        // Date parsing with multiple formats
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter1.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter1.timeZone = TimeZone(secondsFromGMT: 0)

        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
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
    }

    // Computed properties
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
}

