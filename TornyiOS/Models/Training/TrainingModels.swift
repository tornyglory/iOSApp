import Foundation

// MARK: - Training Enums

enum ShotType: String, Codable, CaseIterable {
    case draw = "draw"
    case yardOn = "yard_on"
    case ditchWeight = "ditch_weight"
    case drive = "drive"

    var displayName: String {
        switch self {
        case .draw: return "Draw"
        case .yardOn: return "Yard On"
        case .ditchWeight: return "Ditch Weight"
        case .drive: return "Drive"
        }
    }
}

enum Hand: String, Codable, CaseIterable {
    case forehand = "forehand"
    case backhand = "backhand"
}

enum Length: String, Codable, CaseIterable {
    case short = "short"
    case medium = "medium"
    case long = "long"
}

enum DistanceFromJack: String, Codable, CaseIterable {
    case foot = "foot"
    case yard = "yard"
    case miss = "miss"
}

enum Location: String, Codable, CaseIterable {
    case indoor = "indoor"
    case outdoor = "outdoor"
}

enum GreenType: String, Codable, CaseIterable {
    case carpet = "carpet"
    case bent = "bent"
    case couch = "couch"
    case cotula = "cotula"
    case synthetic = "synthetic"
}

enum Weather: String, Codable, CaseIterable {
    case sunny = "sunny"
    case cloudy = "cloudy"
    case rainy = "rainy"
    case windy = "windy"
    case hot = "hot"
    case warm = "warm"
    case cool = "cool"
    case cold = "cold"
}

enum WindConditions: String, Codable, CaseIterable {
    case noWind = "no_wind"
    case light = "light"
    case moderate = "moderate"
    case strong = "strong"
    case veryStrong = "very_strong"
}