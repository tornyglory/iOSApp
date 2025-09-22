import SwiftUI
import Charts

extension SessionStatistics {
    func shotCountForType(_ type: String) -> String {
        switch type {
        case "draw":
            return drawShots ?? "0"
        case "yard_on":
            return yardOnShots ?? "0"
        case "ditch_weight":
            return ditchWeightShots ?? "0"
        case "drive":
            return driveShots ?? "0"
        default:
            return "0"
        }
    }

    func pointsForType(_ type: String) -> String {
        switch type {
        case "draw":
            return drawPoints ?? "0"
        case "yard_on":
            return yardOnPoints ?? "0"
        case "ditch_weight":
            return ditchWeightPoints ?? "0"
        case "drive":
            return drivePoints ?? "0"
        default:
            return "0"
        }
    }

    func displayAccuracyForType(_ type: String) -> String? {
        switch type {
        case "draw":
            return drawAccuracyPercentage
        case "yard_on":
            return yardOnAccuracyPercentage
        case "ditch_weight":
            return ditchWeightAccuracyPercentage
        case "drive":
            return driveAccuracyPercentage
        default:
            return nil
        }
    }
}

struct SessionHeaderCard: View {
    let session: TrainingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.sessionDate, style: .date)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(session.sessionDate, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Session #\(session.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let rink = session.rinkNumber {
                        Text("Rink \(rink)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(session.location.rawValue.capitalized, systemImage: session.location == .outdoor ? "sun.max" : "house")
                    Spacer()
                    Label(session.greenType.rawValue.capitalized, systemImage: "leaf")
                }

                HStack {
                    Label("Speed: \(session.greenSpeed)s", systemImage: "speedometer")
                    Spacer()
                    if let duration = session.durationSeconds, duration > 0 {
                        Label("Duration: \(formatDurationForDetails(duration))", systemImage: "clock")
                    }
                }

                if session.location == .outdoor {
                    HStack {
                        if let weather = session.weather {
                            Label(weather.rawValue.capitalized, systemImage: "thermometer")
                        }
                        Spacer()
                        if let wind = session.windConditions {
                            Label(wind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized, systemImage: "wind")
                        }
                    }
                }
            }
            .font(.subheadline)

            if let notes = session.notes, !notes.isEmpty {
                Divider()
                Text("Notes")
                    .font(.headline)
                Text(notes)
                    .font(.body)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func formatDurationForDetails(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
}

struct SessionStatsDetailCard: View {
    let stats: SessionStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Session Statistics")
                .font(.headline)

            HStack {
                VStack {
                    Text("\(stats.totalShots)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Total Shots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack {
                    if let accuracy = Double(stats.accuracyPercentage), accuracy > 0 {
                        let successfulShots = Int((accuracy / 100.0) * Double(stats.totalShots))
                        Text("\(successfulShots)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    } else {
                        Text("0")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    Text("Successful")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack {
                    if let accuracy = Double(stats.accuracyPercentage) {
                        Text(String(format: "%.1f%%", accuracy))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    } else {
                        Text("0.0%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            Text("Shot Type Breakdown")
                .font(.subheadline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                HStack {
                    ShotTypeDetailCard(
                        title: "Draw",
                        shots: stats.shotCountForType("draw"),
                        points: stats.pointsForType("draw"),
                        accuracy: stats.displayAccuracyForType("draw"),
                        color: .blue
                    )

                    ShotTypeDetailCard(
                        title: "Yard On",
                        shots: stats.shotCountForType("yard_on"),
                        points: stats.pointsForType("yard_on"),
                        accuracy: stats.displayAccuracyForType("yard_on"),
                        color: .green
                    )
                }

                HStack {
                    ShotTypeDetailCard(
                        title: "Ditch Weight",
                        shots: stats.shotCountForType("ditch_weight"),
                        points: stats.pointsForType("ditch_weight"),
                        accuracy: stats.displayAccuracyForType("ditch_weight"),
                        color: .orange
                    )

                    ShotTypeDetailCard(
                        title: "Drive",
                        shots: stats.shotCountForType("drive"),
                        points: stats.pointsForType("drive"),
                        accuracy: stats.displayAccuracyForType("drive"),
                        color: .purple
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ShotTypeDetailCard: View {
    let title: String
    let shots: String
    let points: String
    let accuracy: String?
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text(shots)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("shots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text(points)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    Text("points")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if let accuracy = accuracy, let accuracyValue = Double(accuracy) {
                Text(String(format: "%.1f%%", accuracyValue))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            } else {
                Text("0.0%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ScoringSystemCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Scoring System")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("2 points")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    Text("Within a foot of the jack")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                        Text("1 point")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    Text("Within a yard of the jack")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("0 points")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    Text("Miss (beyond a yard)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBlue).opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemBlue).opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct StatsGridCard: View {
    let session: TrainingSession
    let stats: SessionStatistics?

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                title: "Total Shots",
                value: "\(session.totalShots ?? 0)",
                icon: "target",
                color: .blue
            )

            StatCard(
                title: "Successful",
                value: "\(session.successfulShots ?? 0)",
                icon: "checkmark.circle.fill",
                color: .green
            )

            if let totalShots = session.totalShots,
               let successfulShots = session.successfulShots,
               totalShots > 0 {
                let accuracy = (Double(successfulShots) / Double(totalShots)) * 100
                StatCard(
                    title: "Accuracy",
                    value: String(format: "%.1f%%", accuracy),
                    icon: "percent",
                    color: accuracy >= 70 ? .green : accuracy >= 50 ? .orange : .red
                )
            }

            if let duration = session.durationSeconds, duration > 0 {
                StatCard(
                    title: "Duration",
                    value: formatDuration(duration),
                    icon: "clock",
                    color: .purple
                )
            }
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ShotTypeBreakdownCard: View {
    let session: TrainingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shot Type Breakdown")
                .font(.headline)
                .fontWeight(.semibold)

            // This would show shot type distribution
            // You'd need to add shot type counts to your session model
            Text("Shot type analysis will appear here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct NotesCard: View {
    let notes: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Notes", systemImage: "note.text")
                .font(.headline)
                .fontWeight(.semibold)

            Text(notes)
                .font(.body)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemYellow).opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemYellow).opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct ShotRowCard: View {
    let shotNumber: Int
    let shotType: String
    let distanceFromJack: String
    let score: Int

    private var shotColor: Color {
        switch distanceFromJack {
        case "within_1_foot":
            return .green
        case "within_1_yard":
            return .orange
        default:
            return .red
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Shot #\(shotNumber)")
                    .font(.headline)

                HStack(spacing: 12) {
                    Label(shotType.replacingOccurrences(of: "_", with: " ").capitalized,
                          systemImage: "target")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label(distanceFromJack.replacingOccurrences(of: "_", with: " ").capitalized,
                          systemImage: "ruler")
                        .font(.caption)
                        .foregroundColor(shotColor)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(shotColor)

                Text("points")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct PerformanceMetricsCard: View {
    let session: TrainingSession
    let stats: SessionStatistics?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Metrics")
                .font(.headline)
                .fontWeight(.semibold)

            if let stats = stats {
                VStack(spacing: 8) {
                    if let averageScore = stats.averageScore {
                        MetricRow(label: "Average Score", value: averageScore)
                    }
                    if let totalPoints = stats.totalPoints {
                        MetricRow(label: "Total Points", value: totalPoints)
                    }
                    MetricRow(label: "Points per Shot", value: calculatePointsPerShot())
                }
            } else {
                Text("Loading metrics...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func calculatePointsPerShot() -> String {
        guard let stats = stats,
              let totalPoints = stats.totalPoints,
              let pointsValue = Double(totalPoints),
              stats.totalShots > 0 else {
            return "0.0"
        }
        let pps = pointsValue / Double(stats.totalShots)
        return String(format: "%.2f", pps)
    }
}

struct MetricRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

struct AccuracyTrendCard: View {
    let session: TrainingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accuracy Trend")
                .font(.headline)
                .fontWeight(.semibold)

            // Simplified chart placeholder
            if let totalShots = session.totalShots, totalShots > 0 {
                Text("Chart showing accuracy over time")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            } else {
                Text("No shot data available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecommendationsCard: View {
    let session: TrainingSession
    let stats: SessionStatistics?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Recommendations")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 8) {
                if let recommendations = generateRecommendations() {
                    ForEach(recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top) {
                            Text("•")
                                .font(.body)
                            Text(recommendation)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemYellow).opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemYellow).opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
    }

    private func generateRecommendations() -> [String]? {
        var recommendations: [String] = []

        if let totalShots = session.totalShots,
           let successfulShots = session.successfulShots,
           totalShots > 0 {
            let accuracy = Double(successfulShots) / Double(totalShots)

            if accuracy < 0.5 {
                recommendations.append("Focus on shorter distance shots to improve accuracy")
            } else if accuracy < 0.7 {
                recommendations.append("Good progress! Try varying shot types for consistency")
            } else {
                recommendations.append("Excellent accuracy! Challenge yourself with longer distances")
            }
        }

        if session.greenSpeed < 12 {
            recommendations.append("Practice on faster greens to improve adaptability")
        }

        if let duration = session.durationSeconds, duration < 1800 {
            recommendations.append("Consider longer sessions for endurance training")
        }

        return recommendations.isEmpty ? nil : recommendations
    }
}