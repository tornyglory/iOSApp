import SwiftUI

struct SessionRowView: View {
    let session: TrainingSession

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.sessionDate)
    }

    private var formattedDuration: String {
        guard let duration = session.durationSeconds, duration > 0 else {
            return "--"
        }
        let minutes = duration / 60
        let seconds = duration % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    private func calculateSuccessfulShots() -> Int {
        guard let totalShots = session.totalShots,
              totalShots > 0 else {
            return 0
        }
        if let accuracy = session.overallAccuracy {
            return Int(round(Double(totalShots) * accuracy / 100.0))
        }
        return 0
    }

    private var accuracyColor: Color {
        guard let totalShots = session.totalShots,
              totalShots > 0 else {
            return .gray
        }
        let successfulShots = calculateSuccessfulShots()
        let accuracy = Double(successfulShots) / Double(totalShots)
        if accuracy >= 0.8 { return .green }
        if accuracy >= 0.6 { return .orange }
        return .red
    }

    private var shotTypeBadges: [ShotTypeBadgeData] {
        var badges: [ShotTypeBadgeData] = []

        // Draw shots
        if let drawShots = session.drawShots, drawShots > 0 {
            let accuracy = session.drawAccuracy ?? 0.0
            badges.append(ShotTypeBadgeData(
                type: "Draw",
                count: drawShots,
                accuracy: Int(accuracy),
                color: .blue
            ))
        }

        // Yard on shots (Ditch in the screenshot)
        if let yardOnShots = session.yardOnShots, yardOnShots > 0 {
            let accuracy = session.yardOnAccuracy ?? 0.0
            badges.append(ShotTypeBadgeData(
                type: "Ditch",
                count: yardOnShots,
                accuracy: Int(accuracy),
                color: .orange
            ))
        }

        // Drive shots
        if let driveShots = session.driveShots, driveShots > 0 {
            let accuracy = session.driveAccuracy ?? 0.0
            badges.append(ShotTypeBadgeData(
                type: "Drive",
                count: driveShots,
                accuracy: Int(accuracy),
                color: .purple
            ))
        }

        // Ditch weight shots
        if let ditchWeightShots = session.ditchWeightShots, ditchWeightShots > 0 {
            let accuracy = session.ditchWeightAccuracy ?? 0.0
            badges.append(ShotTypeBadgeData(
                type: "Weight",
                count: ditchWeightShots,
                accuracy: Int(accuracy),
                color: .green
            ))
        }

        return badges
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top row: Date/Time and Duration
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.sessionDate, style: .date)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(session.sessionDate, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Duration badge
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(formattedDuration)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }

            // Club name (if available)
            if let clubName = session.clubName {
                HStack(spacing: 4) {
                    Image(systemName: "building.2")
                        .font(.caption)
                    Text(clubName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.tornyBlue)
            }

            // Location and conditions row
            HStack(spacing: 12) {
                // Location badge
                HStack(spacing: 4) {
                    Image(systemName: session.location == .outdoor ? "sun.max" : "house")
                        .font(.caption)
                    Text(session.location.rawValue.capitalized)
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                // Green type badge
                HStack(spacing: 4) {
                    Image(systemName: "leaf")
                        .font(.caption)
                    Text(session.greenType.rawValue.capitalized)
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                // Speed badge
                HStack(spacing: 4) {
                    Image(systemName: "speedometer")
                        .font(.caption)
                    Text("\(session.greenSpeed)s")
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                Spacer()
            }
            .foregroundColor(.secondary)

            // Equipment details (if available)
            if let equipment = session.equipment,
               let brand = equipment.bowlsBrand,
               let model = equipment.bowlsModel {
                HStack(spacing: 4) {
                    Image(systemName: "circle.circle")
                        .font(.caption)
                    Text("\(brand) \(model)")
                        .font(.caption)
                        .fontWeight(.medium)

                    if let size = equipment.size {
                        Text("• Size \(size)")
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
            }

            // Total shots
            Text("\(session.totalShots ?? 0) total shots")
                .font(.caption)
                .foregroundColor(.secondary)

            // Shot type badges
            HStack(alignment: .top, spacing: 6) {
                ForEach(shotTypeBadges, id: \.type) { badge in
                    ShotTypeBadge(
                        type: badge.type,
                        count: badge.count,
                        accuracy: badge.accuracy,
                        color: badge.color
                    )
                }

                Spacer()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    private func weatherIcon(for weather: Weather) -> String {
        switch weather {
        case .hot: return "thermometer.sun.fill"
        case .warm: return "thermometer.medium"
        case .cold: return "thermometer.snowflake"
        }
    }
}

struct ShotTypeBadgeData {
    let type: String
    let count: Int
    let accuracy: Int
    let color: Color
}

struct ShotTypeBadge: View {
    let type: String
    let count: Int
    let accuracy: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text(type)
                    .font(.caption)
                    .fontWeight(.medium)
                Text("(\(count))")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(color)

            Text("\(accuracy)%")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }
}