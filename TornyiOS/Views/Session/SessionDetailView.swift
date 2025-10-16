import SwiftUI

struct SessionDetailView: View {
    let session: TrainingSession
    @ObservedObject private var apiService = APIService.shared
    @State private var sessionStats: SessionStatistics?
    @State private var shots: [TrainingShot] = []
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Blue gradient background with clouds
            TornyGradients.skyGradient
                .ignoresSafeArea()

            // Animated clouds
            TornyCloudView()

            ScrollView {
                VStack(spacing: 16) {
                    // Header Section
                    SessionDetailHeaderCard(session: session)
                        .padding(.horizontal)

                    // Session Statistics
                    SessionStatisticsCard(session: session, sessionStats: sessionStats)
                        .padding(.horizontal)

                    // Torny AI Analysis Button
                    NavigationLink(destination: SessionAIAnalysisView(sessionId: session.id)) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 20))
                            Text("Analyse with Torny AI")
                                .font(TornyFonts.body)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.tornyBlue, Color.tornyPurple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Shot Type Breakdown
                    ShotTypeBreakdownSection(session: session, sessionStats: sessionStats)
                        .padding(.horizontal)

                    // Scoring System
                    SessionScoringSystemCard()
                        .padding(.horizontal)

                    // Detailed Shot Breakdown
                    DetailedShotBreakdownSection(session: session)
                        .padding(.horizontal)

                    // Shot History
                    ShotHistorySection(session: session, shots: shots)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadSessionDetails()
        }
    }

    private func loadSessionDetails() async {
        isLoading = true

        do {
            // Fetch session details with shots from API
            let sessionDetailResponse = try await apiService.getSessionDetails(session.id)

            await MainActor.run {
                self.sessionStats = sessionDetailResponse.statistics
                self.shots = sessionDetailResponse.shots
            }
        } catch {
            print("❌ Failed to load session details: \(error.localizedDescription)")
        }

        isLoading = false
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
}

// MARK: - Session Detail Components

struct SessionDetailHeaderCard: View {
    let session: TrainingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Date and Session Info
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
                Text("Session #\(session.id)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Club information (if available)
            if let clubName = session.clubName {
                HStack(spacing: 8) {
                    Image(systemName: "building.2")
                        .font(.subheadline)
                        .foregroundColor(.tornyBlue)
                    Text(clubName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.tornyBlue)
                }
            }

            // Equipment information (if available)
            if let equipment = session.equipment,
               let brand = equipment.bowlsBrand,
               let model = equipment.bowlsModel {
                HStack(spacing: 8) {
                    Image(systemName: "circle.circle")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(brand) \(model)")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if let size = equipment.size {
                        Text("• Size \(size)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if let biasType = equipment.biasType {
                        Text("• \(biasType.capitalized) bias")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Divider()

            // Conditions
            VStack(spacing: 12) {
                HStack {
                    // Outdoor/Indoor
                    HStack(spacing: 4) {
                        Image(systemName: session.location == .outdoor ? "sun.max" : "house")
                        Text(session.location.rawValue.capitalized)
                    }
                    .font(.subheadline)

                    Spacer()

                    // Green type
                    HStack(spacing: 4) {
                        Image(systemName: "leaf")
                        Text(session.greenType.rawValue.capitalized)
                    }
                    .font(.subheadline)
                }

                HStack {
                    // Speed
                    HStack(spacing: 4) {
                        Image(systemName: "speedometer")
                        Text("Speed: \(session.greenSpeed)s")
                    }
                    .font(.subheadline)

                    Spacer()

                    // Duration
                    if let duration = session.durationSeconds, duration > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text("Duration: \(formatDuration(duration))")
                        }
                        .font(.subheadline)
                    }
                }

                if session.location == .outdoor {
                    HStack {
                        // Weather
                        if let weather = session.weather {
                            HStack(spacing: 4) {
                                Image(systemName: "thermometer.medium")
                                Text(weather.rawValue.capitalized)
                            }
                            .font(.subheadline)
                        }

                        Spacer()

                        // Wind conditions
                        if let wind = session.windConditions {
                            HStack(spacing: 4) {
                                Image(systemName: "wind")
                                Text(wind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                            }
                            .font(.subheadline)
                        }
                    }
                }
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        if minutes > 0 {
            return "\(minutes)m"
        }
        return "\(seconds)s"
    }
}

struct SessionStatisticsCard: View {
    let session: TrainingSession
    let sessionStats: SessionStatistics?

    private var totalPointsEarned: Int {
        // Use actual total points from API if available
        if let stats = sessionStats,
           let totalPointsString = stats.totalPoints,
           let totalPoints = Int(totalPointsString) {
            return totalPoints
        }

        // Otherwise estimate
        // Estimate total points based on accuracy and shot counts
        // Since we don't have individual shot data, we'll estimate based on accuracy percentages
        var totalPoints = 0

        // Draw shots
        if let drawShots = session.drawShots, let drawAccuracy = session.drawAccuracy, drawShots > 0 {
            // Estimate points: assume accuracy represents mix of 2-point and 1-point shots
            // Higher accuracy = more 2-point shots, lower accuracy = more 1-point shots
            let estimatedPoints = estimatePointsFromAccuracy(shots: drawShots, accuracy: drawAccuracy)
            totalPoints += estimatedPoints
        }

        // Yard on shots
        if let yardOnShots = session.yardOnShots, let yardOnAccuracy = session.yardOnAccuracy, yardOnShots > 0 {
            let estimatedPoints = estimatePointsFromAccuracy(shots: yardOnShots, accuracy: yardOnAccuracy)
            totalPoints += estimatedPoints
        }

        // Ditch Weight shots
        if let ditchWeightShots = session.ditchWeightShots, let ditchWeightAccuracy = session.ditchWeightAccuracy, ditchWeightShots > 0 {
            let estimatedPoints = estimatePointsFromAccuracy(shots: ditchWeightShots, accuracy: ditchWeightAccuracy)
            totalPoints += estimatedPoints
        }

        // Drive shots
        if let driveShots = session.driveShots, let driveAccuracy = session.driveAccuracy, driveShots > 0 {
            let estimatedPoints = estimatePointsFromAccuracy(shots: driveShots, accuracy: driveAccuracy)
            totalPoints += estimatedPoints
        }

        return totalPoints
    }

    private func estimatePointsFromAccuracy(shots: Int, accuracy: Double) -> Int {
        // Estimate points based on accuracy percentage
        // Accuracy represents the percentage of shots that scored any points
        let shotsWithPoints = Int(round(Double(shots) * accuracy / 100.0))

        // Estimate distribution of 1-point vs 2-point shots based on accuracy level
        // Higher accuracy suggests more 2-point shots (within a foot)
        // Lower accuracy suggests more 1-point shots (within a yard)

        if accuracy >= 90 {
            // Very high accuracy: mostly 2-point shots
            return shotsWithPoints * 2
        } else if accuracy >= 70 {
            // Good accuracy: mix of 2-point and 1-point, leaning toward 2-point
            let twoPointShots = Int(Double(shotsWithPoints) * 0.7)
            let onePointShots = shotsWithPoints - twoPointShots
            return (twoPointShots * 2) + (onePointShots * 1)
        } else if accuracy >= 50 {
            // Moderate accuracy: even mix of 2-point and 1-point
            let twoPointShots = Int(Double(shotsWithPoints) * 0.5)
            let onePointShots = shotsWithPoints - twoPointShots
            return (twoPointShots * 2) + (onePointShots * 1)
        } else {
            // Lower accuracy: mostly 1-point shots
            let twoPointShots = Int(Double(shotsWithPoints) * 0.3)
            let onePointShots = shotsWithPoints - twoPointShots
            return (twoPointShots * 2) + (onePointShots * 1)
        }
    }

    private var successfulShots: Int {
        // Successful shots = any shot that scores points (1 or 2 points)
        var totalSuccessful = 0

        // Draw shots
        if let drawShots = session.drawShots, let drawAccuracy = session.drawAccuracy, drawShots > 0 {
            totalSuccessful += Int(round(Double(drawShots) * drawAccuracy / 100.0))
        }

        // Yard on shots
        if let yardOnShots = session.yardOnShots, let yardOnAccuracy = session.yardOnAccuracy, yardOnShots > 0 {
            totalSuccessful += Int(round(Double(yardOnShots) * yardOnAccuracy / 100.0))
        }

        // Ditch Weight shots
        if let ditchWeightShots = session.ditchWeightShots, let ditchWeightAccuracy = session.ditchWeightAccuracy, ditchWeightShots > 0 {
            totalSuccessful += Int(round(Double(ditchWeightShots) * ditchWeightAccuracy / 100.0))
        }

        // Drive shots
        if let driveShots = session.driveShots, let driveAccuracy = session.driveAccuracy, driveShots > 0 {
            totalSuccessful += Int(round(Double(driveShots) * driveAccuracy / 100.0))
        }

        return totalSuccessful
    }

    private var maxPossiblePoints: Int {
        if let stats = sessionStats,
           let maxPoints = stats.maxPossiblePoints {
            return maxPoints
        }
        // Fallback: totalShots × 2
        return (session.totalShots ?? 0) * 2
    }

    private var accuracy: String {
        if let stats = sessionStats,
           let accuracyDouble = Double(stats.accuracyPercentage) {
            return String(format: "%.1f%%", accuracyDouble)
        }

        guard let totalShots = session.totalShots, totalShots > 0 else {
            return "0.0%"
        }

        // Calculate accuracy as: (Points Earned / Maximum Possible Points) × 100
        let pointsBasedAccuracy = (Double(totalPointsEarned) / Double(maxPossiblePoints)) * 100.0
        return String(format: "%.1f%%", pointsBasedAccuracy)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Session Performance")
                .font(.headline)
                .fontWeight(.semibold)

            // Points Display - Most Prominent
            VStack(spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(totalPointsEarned)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.tornyBlue)
                    Text("/ \(maxPossiblePoints)")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                Text("Points Earned")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)

            Divider()

            // Secondary Stats
            HStack(spacing: 0) {
                // Accuracy
                VStack(spacing: 8) {
                    Text(accuracy)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.tornyGreen)
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                // Total Shots
                VStack(spacing: 8) {
                    Text("\(session.totalShots ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Total Shots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                // Successful Shots (1-2 points)
                VStack(spacing: 8) {
                    Text("\(successfulShots)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.tornyPurple)
                    Text("Successful")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ShotTypeBreakdownSection: View {
    let session: TrainingSession
    let sessionStats: SessionStatistics?

    private func getPointsAndMax(shotType: String, sessionShots: Int, sessionAccuracy: Double) -> (points: Int, maxPoints: Int) {
        let apiShots: String?
        let apiPoints: String?

        switch shotType {
        case "draw":
            apiShots = sessionStats?.drawShots
            apiPoints = sessionStats?.drawPoints
        case "yard_on":
            apiShots = sessionStats?.yardOnShots
            apiPoints = sessionStats?.yardOnPoints
        case "ditch_weight":
            apiShots = sessionStats?.ditchWeightShots
            apiPoints = sessionStats?.ditchWeightPoints
        case "drive":
            apiShots = sessionStats?.driveShots
            apiPoints = sessionStats?.drivePoints
        default:
            apiShots = nil
            apiPoints = nil
        }

        // Try to use API data
        if let shotsString = apiShots,
           let shotsInt = Int(shotsString),
           shotsInt > 0,
           let pointsString = apiPoints,
           let pointsInt = Int(pointsString) {
            return (points: pointsInt, maxPoints: shotsInt * 2)
        }

        // Fall back to estimation
        let estimatedPoints = calculatePointsForShotType(shots: sessionShots, accuracy: sessionAccuracy)
        return (points: estimatedPoints, maxPoints: sessionShots * 2)
    }

    private func calculatePointsForShotType(shots: Int, accuracy: Double) -> Int {
        guard shots > 0 else { return 0 }

        // Calculate points based on accuracy percentage and scoring system:
        // - 2 points for within a foot (high accuracy)
        // - 1 point for within a yard (medium accuracy)
        // - 0 points for miss (low accuracy)

        // Estimate point distribution based on accuracy percentage
        if accuracy >= 90 {
            // Very high accuracy: mostly 2-point shots
            let twoPointShots = Int(Double(shots) * 0.9)
            let onePointShots = shots - twoPointShots
            return (twoPointShots * 2) + (onePointShots * 1)
        } else if accuracy >= 70 {
            // Good accuracy: mix favoring 2-point
            let twoPointShots = Int(Double(shots) * 0.6)
            let onePointShots = Int(Double(shots) * 0.3)
            return (twoPointShots * 2) + (onePointShots * 1)
        } else if accuracy >= 50 {
            // Moderate accuracy: balanced mix
            let twoPointShots = Int(Double(shots) * 0.3)
            let onePointShots = Int(Double(shots) * 0.4)
            return (twoPointShots * 2) + (onePointShots * 1)
        } else if accuracy >= 25 {
            // Lower accuracy: mostly 1-point shots
            let onePointShots = Int(Double(shots) * accuracy / 100.0)
            return onePointShots * 1
        } else {
            // Very low accuracy: mostly misses with few 1-point
            let onePointShots = Int(Double(shots) * accuracy / 100.0)
            return onePointShots * 1
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shot Type Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // Draw
                if let drawShots = session.drawShots, drawShots > 0 {
                    let drawAccuracy = session.drawAccuracy ?? 0.0
                    let result = getPointsAndMax(shotType: "draw", sessionShots: drawShots, sessionAccuracy: drawAccuracy)

                    SessionShotTypeCard(
                        title: "Draw",
                        shots: drawShots,
                        points: result.points,
                        maxPoints: result.maxPoints,
                        color: .blue
                    )
                }

                // Yard On
                if let yardOnShots = session.yardOnShots, yardOnShots > 0 {
                    let yardOnAccuracy = session.yardOnAccuracy ?? 0.0
                    let result = getPointsAndMax(shotType: "yard_on", sessionShots: yardOnShots, sessionAccuracy: yardOnAccuracy)

                    SessionShotTypeCard(
                        title: "Yard On",
                        shots: yardOnShots,
                        points: result.points,
                        maxPoints: result.maxPoints,
                        color: .green
                    )
                }

                // Ditch Weight
                if let ditchWeightShots = session.ditchWeightShots, ditchWeightShots > 0 {
                    let ditchWeightAccuracy = session.ditchWeightAccuracy ?? 0.0
                    let result = getPointsAndMax(shotType: "ditch_weight", sessionShots: ditchWeightShots, sessionAccuracy: ditchWeightAccuracy)

                    SessionShotTypeCard(
                        title: "Ditch Weight",
                        shots: ditchWeightShots,
                        points: result.points,
                        maxPoints: result.maxPoints,
                        color: .orange
                    )
                }

                // Drive
                if let driveShots = session.driveShots, driveShots > 0 {
                    let driveAccuracy = session.driveAccuracy ?? 0.0
                    let result = getPointsAndMax(shotType: "drive", sessionShots: driveShots, sessionAccuracy: driveAccuracy)

                    SessionShotTypeCard(
                        title: "Drive",
                        shots: driveShots,
                        points: result.points,
                        maxPoints: result.maxPoints,
                        color: .purple
                    )
                }
            }
        }
    }
}

struct SessionShotTypeCard: View {
    let title: String
    let shots: Int
    let points: Int
    let maxPoints: Int
    let color: Color

    private var pointsBasedPercentage: Double {
        guard maxPoints > 0 else { return 0.0 }
        return (Double(points) / Double(maxPoints)) * 100.0
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)

            // Points Display - Most Prominent
            VStack(spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(points)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(color)
                    Text("/ \(maxPoints)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                Text("Points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()
                .padding(.horizontal, 8)

            // Secondary Info
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("\(shots)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text("Shots")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text(String(format: "%.1f%%", pointsBasedPercentage))
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text("Accuracy")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SessionScoringSystemCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                Text("Scoring System")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 8) {
                ScoringSystemRow(points: 2, color: .green, description: "Within a foot of the jack")
                ScoringSystemRow(points: 1, color: .orange, description: "Within a yard of the jack")
                ScoringSystemRow(points: 0, color: .red, description: "Miss (beyond a yard)")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ScoringSystemRow: View {
    let points: Int
    let color: Color
    let description: String

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("\(points) point\(points == 1 ? "" : "s")")
                .fontWeight(.medium)
            Spacer()
            Text(description)
                .foregroundColor(.secondary)
        }
        .font(.subheadline)
    }
}

struct DetailedShotBreakdownSection: View {
    let session: TrainingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Shot Breakdown")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                // Sample shot breakdown based on session data
                if let ditchWeightShots = session.ditchWeightShots, ditchWeightShots > 0 {
                    DetailedShotTypeSection(
                        title: "Ditch Weight",
                        color: .orange,
                        totalShots: ditchWeightShots,
                        totalPoints: 2,
                        shots: [
                            ShotDetail(hand: "Forehand", length: "Medium", result: "Foot", points: 2)
                        ]
                    )
                }

                if let drawShots = session.drawShots, drawShots > 0 {
                    DetailedShotTypeSection(
                        title: "Draw",
                        color: .blue,
                        totalShots: drawShots,
                        totalPoints: 3,
                        shots: [
                            ShotDetail(hand: "Forehand", length: "Medium", result: "Foot", points: 2),
                            ShotDetail(hand: "Forehand", length: "Medium", result: "Yard", points: 1)
                        ]
                    )
                }

                if let driveShots = session.driveShots, driveShots > 0 {
                    DetailedShotTypeSection(
                        title: "Drive",
                        color: .purple,
                        totalShots: driveShots,
                        totalPoints: 2,
                        shots: [
                            ShotDetail(hand: "Forehand", length: "Medium", result: "Foot", points: 2)
                        ]
                    )
                }
            }
        }
    }
}

struct DetailedShotTypeSection: View {
    let title: String
    let color: Color
    let totalShots: Int
    let totalPoints: Int
    let shots: [ShotDetail]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                Spacer()
                Text("\(totalShots) shots • \(totalPoints) points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if shots.count > 1 {
                // Summary for multiple shots
                HStack(spacing: 20) {
                    let footShots = shots.filter { $0.result == "Foot" }.count
                    let yardShots = shots.filter { $0.result == "Yard" }.count
                    let missShots = shots.filter { $0.result == "Miss" }.count

                    if footShots > 0 {
                        ShotResultBadge(count: footShots, result: "Foot", color: .green)
                    }
                    if yardShots > 0 {
                        ShotResultBadge(count: yardShots, result: "Yard", color: .orange)
                    }
                    if missShots > 0 {
                        ShotResultBadge(count: missShots, result: "Miss", color: .red)
                    }
                }
            }

            // Individual shots
            ForEach(shots.indices, id: \.self) { index in
                ShotDetailCard(shot: shots[index])
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ShotDetail {
    let hand: String
    let length: String
    let result: String
    let points: Int
}

struct ShotDetailCard: View {
    let shot: ShotDetail

    private var resultColor: Color {
        switch shot.result {
        case "Foot": return .green
        case "Yard": return .orange
        case "Miss": return .red
        default: return .gray
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(shot.hand)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(shot.length)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 12) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(shot.points) pts")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(resultColor)
                    Text("● \(shot.result)")
                        .font(.caption)
                        .foregroundColor(resultColor)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ShotResultBadge: View {
    let count: Int
    let result: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(result)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ShotHistorySection: View {
    let session: TrainingSession
    let shots: [TrainingShot]

    private func displayName(for shotType: ShotType) -> String {
        switch shotType.rawValue {
        case "draw": return "Draw"
        case "yard_on": return "Yard On"
        case "ditch_weight": return "Ditch Weight"
        case "drive": return "Drive"
        default: return shotType.rawValue.capitalized
        }
    }

    private func resultColor(for distance: DistanceFromJack?) -> Color {
        guard let distance = distance else { return .gray }
        switch distance {
        case .foot: return .green
        case .yard: return .orange
        case .miss: return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shot History (\(shots.count) shots)")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                // Display actual shot history from API data
                ForEach(shots, id: \.id) { shot in
                    ShotHistoryRow(
                        shotType: displayName(for: shot.shotType),
                        hand: shot.hand.rawValue.capitalized,
                        length: shot.length.rawValue.capitalized,
                        result: shot.distanceFromJack?.rawValue.capitalized ?? "Unknown",
                        color: resultColor(for: shot.distanceFromJack),
                        time: shot.createdAt
                    )
                }

                if shots.isEmpty {
                    Text("No shots recorded")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 20)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ShotHistoryRow: View {
    let shotType: String
    let hand: String
    let length: String
    let result: String
    let color: Color
    let time: Date

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(shotType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 8) {
                    Text(hand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(length)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                    Text(result)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                }
                Text(time, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}