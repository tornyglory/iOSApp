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

    private var accuracyColor: Color {
        guard let totalShots = session.totalShots,
              let successfulShots = session.successfulShots,
              totalShots > 0 else {
            return .gray
        }
        let accuracy = Double(successfulShots) / Double(totalShots)
        if accuracy >= 0.8 { return .green }
        if accuracy >= 0.6 { return .orange }
        return .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row: Date/Time and Stats
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack(spacing: 12) {
                        Label(session.location.rawValue.capitalized,
                              systemImage: session.location == .outdoor ? "sun.max.fill" : "house.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Label("\(session.greenSpeed)s", systemImage: "speedometer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Stats on the right
                HStack(spacing: 16) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(session.totalShots ?? 0)")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Shots")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .trailing, spacing: 2) {
                        if let totalShots = session.totalShots,
                           let successfulShots = session.successfulShots,
                           totalShots > 0 {
                            let accuracy = Int((Double(successfulShots) / Double(totalShots)) * 100)
                            Text("\(accuracy)%")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(accuracyColor)
                        } else {
                            Text("--")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        }
                        Text("Accuracy")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Bottom row: Additional info
            HStack {
                if let weather = session.weather, session.location == .outdoor {
                    Label(weather.rawValue.capitalized, systemImage: weatherIcon(for: weather))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Label(formattedDuration, systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if session.notes?.isEmpty == false {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(.tornyBlue)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }

    private func weatherIcon(for weather: Weather) -> String {
        switch weather {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .windy: return "wind"
        }
    }
}