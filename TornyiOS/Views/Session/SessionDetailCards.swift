import SwiftUI

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
                    Text("\(stats.successfulShots)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Successful")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack {
                    Text(String(format: "%.1f%%", stats.overallAccuracy))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
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