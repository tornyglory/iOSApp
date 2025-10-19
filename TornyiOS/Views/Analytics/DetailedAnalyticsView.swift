import SwiftUI
import Foundation

// This is a wrapper that uses the existing ShotAnalysisView components
struct DetailedAnalyticsView: View {
    var body: some View {
        ShotAnalysisContentView()
    }
}

// Use the same implementation as ShotAnalysisView but with a different struct name
struct ShotAnalysisContentView: View {
    @StateObject private var viewModel = DetailedAnalyticsViewModelLocal()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // Blue gradient background with clouds
                TornyGradients.skyGradient
                    .ignoresSafeArea()

                // Animated clouds
                TornyCloudView()

            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.isLoading {
                        VStack(spacing: 12) {
                            TornyLoadingView()
                            Text("Loading shot analysis...")
                                .font(TornyFonts.body)
                                .foregroundColor(.tornyTextSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else if let analytics = viewModel.analytics {
                        // Header Section
                        LifetimeStatsHeader(
                            selectedPeriod: $viewModel.selectedPeriod,
                            analytics: analytics,
                            onPeriodChanged: viewModel.loadAnalytics
                        )
                        .padding(.bottom, 16)

                        // Session Statistics
                        LifetimeSessionStats(analytics: analytics)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)

                        // Shot Type Breakdown Cards
                        LifetimeShotTypeBreakdown(analytics: analytics)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)

                        // Scoring System Info
                        ScoringSystemInfo()
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)

                        // Detailed Shot Breakdown by Type
                        DetailedShotBreakdown(analytics: analytics)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)

                        // Length & Hand Analysis
                        LengthHandAnalysis(analytics: analytics)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)

                        // Green Type & Conditions Breakdown
                        ConditionsBreakdown(analytics: analytics)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)

                        // Green Types & Speeds Detailed Analysis
                        GreenTypesSpeedsAnalysis(analytics: analytics)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)

                    } else if let error = viewModel.error {
                        ErrorView(
                            title: "Failed to Load Shot Analysis",
                            message: error.localizedDescription,
                            onRetry: viewModel.loadAnalytics
                        )
                        .padding()
                    }
                }
            }
            }
            .navigationTitle("Shot Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                            Text("Back")
                        }
                        .foregroundColor(.tornyBlue)
                    }
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onAppear {
            viewModel.loadAnalytics()
        }
    }
}

// MARK: - All Required Components

// Lifetime Stats Header
struct LifetimeStatsHeader: View {
    @Binding var selectedPeriod: String
    let analytics: ComparativeAnalyticsResponse
    let onPeriodChanged: () -> Void

    let periods = [
        ("week", "Week"),
        ("month", "Month"),
        ("year", "Year"),
        ("all", "All Time")
    ]

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Text("Lifetime Performance")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(periodDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Picker("Period", selection: $selectedPeriod) {
                    ForEach(periods, id: \.0) { period in
                        Text(period.1).tag(period.0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedPeriod) { _ in
                    onPeriodChanged()
                }
            }

            HStack {
                HStack {
                    Image(systemName: "location")
                    Text(mostCommonLocation)
                }
                Spacer()
                HStack {
                    Image(systemName: "square.grid.3x3")
                    Text(mostCommonGreenType)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var periodDescription: String {
        switch selectedPeriod {
        case "week": return "Last 7 Days"
        case "month": return "Last 30 Days"
        case "year": return "Last 12 Months"
        default: return "All Time Statistics"
        }
    }

    private var mostCommonLocation: String {
        let locations = analytics.heatmapData.map { $0.conditions.location }
        let locationCounts = Dictionary(grouping: locations) { $0 }.mapValues { $0.count }
        return locationCounts.max { $0.value < $1.value }?.key.capitalized ?? "Indoor"
    }

    private var mostCommonGreenType: String {
        let greenTypes = analytics.heatmapData.map { $0.conditions.greenType }
        let greenTypeCounts = Dictionary(grouping: greenTypes) { $0 }.mapValues { $0.count }
        return greenTypeCounts.max { $0.value < $1.value }?.key.capitalized ?? "Carpet"
    }
}

// Lifetime Session Stats
struct LifetimeSessionStats: View {
    let analytics: ComparativeAnalyticsResponse

    var body: some View {
        VStack(spacing: 16) {
            Text("Lifetime Statistics")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                StatColumn(value: "\(totalShots)", label: "Total Shots", color: .primary)
                StatColumn(value: "\(successfulShots)", label: "Successful", color: .green)
                StatColumn(value: String(format: "%.1f%%", overallAccuracy), label: "Accuracy", color: .green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var totalShots: Int {
        analytics.heatmapData.reduce(0) { $0 + $1.shots }
    }

    private var successfulShots: Int {
        let totalShots = analytics.heatmapData.reduce(0) { $0 + $1.shots }
        let weightedAccuracy = analytics.heatmapData.reduce(0.0) { $0 + ($1.value * Double($1.shots)) }
        let overallAccuracy = totalShots > 0 ? weightedAccuracy / Double(totalShots) : 0
        return Int(round(Double(totalShots) * overallAccuracy / 100.0))
    }

    private var overallAccuracy: Double {
        let totalShots = analytics.heatmapData.reduce(0) { $0 + $1.shots }
        let weightedAccuracy = analytics.heatmapData.reduce(0.0) { $0 + ($1.value * Double($1.shots)) }
        return totalShots > 0 ? weightedAccuracy / Double(totalShots) : 0
    }
}

// Basic components
struct StatColumn: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Shot Type Breakdown with real data
struct LifetimeShotTypeBreakdown: View {
    let analytics: ComparativeAnalyticsResponse

    var body: some View {
        VStack(spacing: 16) {
            Text("Shot Type Breakdown")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            if shotTypeStats.isEmpty {
                Text("No shot type data available")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(shotTypeStats, id: \.type) { stat in
                        ShotTypeBreakdownCard(
                            shotType: stat.type,
                            shots: stat.shots,
                            points: stat.points,
                            accuracy: stat.accuracy,
                            color: shotTypeColor(stat.type)
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var shotTypeStats: [(type: String, shots: Int, points: Int, accuracy: Double)] {
        var stats: [String: (shots: Int, points: Int, totalAccuracy: Double)] = [:]

        // Aggregate from length matrix
        if let short = analytics.lengthMatrix.short {
            aggregateFromLengthCategory(short, into: &stats)
        }
        aggregateFromLengthCategory(analytics.lengthMatrix.medium, into: &stats)
        if let long = analytics.lengthMatrix.long {
            aggregateFromLengthCategory(long, into: &stats)
        }

        return stats.map {
            (
                type: $0.key,
                shots: $0.value.shots,
                points: $0.value.points,
                accuracy: $0.value.shots > 0 ? $0.value.totalAccuracy / Double($0.value.shots) : 0
            )
        }.sorted { $0.shots > $1.shots }
    }

    private func aggregateFromLengthCategory(_ category: [String: LengthMatrix.LengthMatrixData], into stats: inout [String: (shots: Int, points: Int, totalAccuracy: Double)]) {
        for (shotType, data) in category {
            if stats[shotType] != nil {
                stats[shotType]!.shots += data.shots
                stats[shotType]!.points += data.points
                stats[shotType]!.totalAccuracy += data.accuracy * Double(data.shots)
            } else {
                stats[shotType] = (shots: data.shots, points: data.points, totalAccuracy: data.accuracy * Double(data.shots))
            }
        }
    }

    private func shotTypeColor(_ shotType: String) -> Color {
        switch shotType.lowercased() {
        case "draw": return .green
        case "yard_on": return .blue
        case "ditch_weight": return .orange
        case "drive": return .purple
        default: return .gray
        }
    }
}

// Shot Type Breakdown Card
struct ShotTypeBreakdownCard: View {
    let shotType: String
    let shots: Int
    let points: Int
    let accuracy: Double
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(shotType.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.headline)
                .foregroundColor(color)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(shots)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("shots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f%%", accuracy))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    Text("accuracy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ScoringSystemInfo: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Scoring System")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }

            VStack(spacing: 8) {
                ScoringRow(color: .green, points: "2 points", description: "Within a foot of the jack")
                ScoringRow(color: .orange, points: "1 point", description: "Within a yard of the jack")
                ScoringRow(color: .red, points: "0 points", description: "Miss (beyond a yard)")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ScoringRow: View {
    let color: Color
    let points: String
    let description: String

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(points)
                .fontWeight(.medium)
            Spacer()
            Text(description)
                .foregroundColor(.secondary)
        }
        .font(.subheadline)
    }
}

struct DetailedShotBreakdown: View {
    let analytics: ComparativeAnalyticsResponse

    var body: some View {
        VStack(spacing: 16) {
            Text("Detailed Shot Breakdown")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(shotTypeStats, id: \.type) { stat in
                if stat.shots > 0 {
                    VStack(spacing: 12) {
                        HStack {
                            Text(stat.type.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.headline)
                                .foregroundColor(shotTypeColor(stat.type))
                            Spacer()
                            Text("\(stat.shots) shots · \(stat.points) points")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        // Simple breakdown for now
                        HStack(spacing: 16) {
                            VStack {
                                Text("Foot")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(Int(Double(stat.points) / 2.0))")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }

                            VStack {
                                Text("Yard")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(max(0, stat.shots - Int(Double(stat.points) / 2.0) - (stat.shots - stat.points)))")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                            }

                            VStack {
                                Text("Miss")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(stat.shots - stat.points)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }

                            Spacer()
                        }

                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var shotTypeStats: [(type: String, shots: Int, points: Int)] {
        var stats: [String: (shots: Int, points: Int)] = [:]

        // Aggregate from length matrix
        if let short = analytics.lengthMatrix.short {
            aggregateFromLengthCategory(short, into: &stats)
        }
        aggregateFromLengthCategory(analytics.lengthMatrix.medium, into: &stats)
        if let long = analytics.lengthMatrix.long {
            aggregateFromLengthCategory(long, into: &stats)
        }

        return stats.map { (type: $0.key, shots: $0.value.shots, points: $0.value.points) }
            .sorted { $0.shots > $1.shots }
    }

    private func aggregateFromLengthCategory(_ category: [String: LengthMatrix.LengthMatrixData], into stats: inout [String: (shots: Int, points: Int)]) {
        for (shotType, data) in category {
            if stats[shotType] != nil {
                stats[shotType]!.shots += data.shots
                stats[shotType]!.points += data.points
            } else {
                stats[shotType] = (shots: data.shots, points: data.points)
            }
        }
    }

    private func shotTypeColor(_ shotType: String) -> Color {
        switch shotType.lowercased() {
        case "draw": return .green
        case "yard_on": return .blue
        case "ditch_weight": return .orange
        case "drive": return .purple
        default: return .gray
        }
    }
}

struct LengthHandAnalysis: View {
    let analytics: ComparativeAnalyticsResponse

    var body: some View {
        VStack(spacing: 16) {
            Text("Length & Hand Analysis")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Length Performance
            VStack(alignment: .leading, spacing: 12) {
                Text("Performance by Length")
                    .font(.headline)

                HStack(spacing: 12) {
                    if let short = analytics.lengthMatrix.short {
                        LengthPerformanceCard(title: "Short", data: short, color: .green)
                    }
                    LengthPerformanceCard(title: "Medium", data: analytics.lengthMatrix.medium, color: .orange)
                    if let long = analytics.lengthMatrix.long {
                        LengthPerformanceCard(title: "Long", data: long, color: .red)
                    }
                }
            }

            Divider()

            // Hand Performance
            VStack(alignment: .leading, spacing: 12) {
                Text("Performance by Hand")
                    .font(.headline)

                HStack(spacing: 16) {
                    HandPerformanceCard(
                        hand: "Forehand",
                        accuracy: forehandAccuracy,
                        shots: forehandShots
                    )

                    HandPerformanceCard(
                        hand: "Backhand",
                        accuracy: backhandAccuracy,
                        shots: backhandShots
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var forehandAccuracy: Double {
        guard let forehandData = analytics.radarChart.series.first(where: { $0.name == "forehand" })?.data else { return 70.0 }
        let values = forehandData.compactMap { Double($0) }
        return values.isEmpty ? 70.0 : values.reduce(0, +) / Double(values.count)
    }

    private var backhandAccuracy: Double {
        guard let backhandData = analytics.radarChart.series.first(where: { $0.name == "backhand" })?.data else { return 65.0 }
        let values = backhandData.compactMap { Double($0) }
        return values.isEmpty ? 65.0 : values.reduce(0, +) / Double(values.count)
    }

    private var forehandShots: Int {
        analytics.heatmapData.reduce(0) { $0 + $1.shots } / 2
    }

    private var backhandShots: Int {
        analytics.heatmapData.reduce(0) { $0 + $1.shots } / 2
    }
}

// Length Performance Card
struct LengthPerformanceCard: View {
    let title: String
    let data: [String: LengthMatrix.LengthMatrixData]
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)

            VStack(spacing: 4) {
                Text("\(totalShots)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("shots")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(String(format: "%.1f%%", averageAccuracy))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    private var totalShots: Int {
        data.values.reduce(0) { $0 + $1.shots }
    }

    private var averageAccuracy: Double {
        let totalShots = data.values.reduce(0) { $0 + $1.shots }
        let weightedAccuracy = data.values.reduce(0.0) { $0 + ($1.accuracy * Double($1.shots)) }
        return totalShots > 0 ? weightedAccuracy / Double(totalShots) : 0
    }
}

// Hand Performance Card
struct HandPerformanceCard: View {
    let hand: String
    let accuracy: Double
    let shots: Int

    var body: some View {
        VStack(spacing: 8) {
            Text(hand)
                .font(.headline)

            VStack(spacing: 4) {
                Text("\(shots)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("shots")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(String(format: "%.1f%%", accuracy))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ConditionsBreakdown: View {
    let analytics: ComparativeAnalyticsResponse

    var body: some View {
        VStack(spacing: 16) {
            Text("Playing Conditions Breakdown")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Green Types
            VStack(alignment: .leading, spacing: 12) {
                Text("Green Type Performance")
                    .font(.headline)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(greenTypePerformance, id: \.type) { greenType in
                        GreenTypePerformanceCard(
                            greenType: greenType.type,
                            accuracy: greenType.accuracy,
                            sessions: greenType.sessions
                        )
                    }
                }
            }

            Divider()

            // Best/Worst Conditions
            VStack(alignment: .leading, spacing: 12) {
                Text("Conditions Analysis")
                    .font(.headline)

                VStack(spacing: 8) {
                    ConditionsCard(
                        title: "Best Conditions",
                        description: analytics.insights.optimalConditions.description,
                        accuracy: analytics.insights.optimalConditions.accuracy,
                        sessions: analytics.insights.optimalConditions.sessions,
                        color: .green
                    )

                    if let worst = worstConditions {
                        ConditionsCard(
                            title: "Most Challenging",
                            description: worst.description,
                            accuracy: worst.accuracy,
                            sessions: worst.sessions,
                            color: .red
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var greenTypePerformance: [(type: String, accuracy: Double, sessions: Int)] {
        var stats: [String: (totalAccuracy: Double, totalSessions: Int, count: Int)] = [:]

        for point in analytics.heatmapData {
            let greenType = point.conditions.greenType
            if stats[greenType] != nil {
                stats[greenType]!.totalAccuracy += point.value
                stats[greenType]!.totalSessions += point.sessions
                stats[greenType]!.count += 1
            } else {
                stats[greenType] = (totalAccuracy: point.value, totalSessions: point.sessions, count: 1)
            }
        }

        return stats.map {
            (type: $0.key.capitalized, accuracy: $0.value.totalAccuracy / Double($0.value.count), sessions: $0.value.totalSessions)
        }.sorted { $0.accuracy > $1.accuracy }
    }

    private var worstConditions: (description: String, accuracy: Double, sessions: Int)? {
        let worstCondition = analytics.heatmapData.min { $0.value < $1.value }

        if let worst = worstCondition {
            let conditions = worst.conditions
            let description = "\(conditions.location.capitalized) \(conditions.greenType.capitalized) (Speed \(conditions.greenSpeed))"
            return (description: description, accuracy: worst.value, sessions: worst.sessions)
        }
        return nil
    }
}

// Green Type Performance Card
struct GreenTypePerformanceCard: View {
    let greenType: String
    let accuracy: Double
    let sessions: Int

    var body: some View {
        VStack(spacing: 8) {
            Text(greenType)
                .font(.headline)
                .foregroundColor(.primary)

            VStack(spacing: 4) {
                Text(String(format: "%.1f%%", accuracy))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                Text("\(sessions) sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// Conditions Card
struct ConditionsCard: View {
    let title: String
    let description: String
    let accuracy: Double
    let sessions: Int
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.1f%%", accuracy))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Text("\(sessions) sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct GreenTypesSpeedsAnalysis: View {
    let analytics: ComparativeAnalyticsResponse

    var body: some View {
        VStack(spacing: 16) {
            Text("Green Types & Speeds Analysis")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Speed Range Performance
            VStack(alignment: .leading, spacing: 12) {
                Text("Performance by Green Speed")
                    .font(.headline)

                HStack(spacing: 8) {
                    ForEach(speedRangeStats, id: \.range) { speedRange in
                        GreenSpeedCard(
                            speedRange: speedRange.range,
                            accuracy: speedRange.accuracy,
                            sessions: speedRange.sessions,
                            description: speedRange.description
                        )
                    }
                }
            }

            Divider()

            // Location vs Green Type Matrix
            VStack(alignment: .leading, spacing: 12) {
                Text("Location & Green Type Combinations")
                    .font(.headline)

                ForEach(locationGreenCombos.prefix(3), id: \.combination) { combo in
                    LocationGreenComboCard(
                        combination: combo.combination,
                        accuracy: combo.accuracy,
                        sessions: combo.sessions,
                        shots: combo.shots,
                        averageSpeed: combo.averageSpeed
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var speedRangeStats: [(range: String, accuracy: Double, sessions: Int, description: String)] {
        var slowStats = (totalAccuracy: 0.0, totalSessions: 0, count: 0)  // 10-13
        var mediumStats = (totalAccuracy: 0.0, totalSessions: 0, count: 0)  // 14-16
        var fastStats = (totalAccuracy: 0.0, totalSessions: 0, count: 0)  // 17+

        for point in analytics.heatmapData {
            let speed = point.conditions.greenSpeed
            if speed <= 13 {
                slowStats.totalAccuracy += point.value
                slowStats.totalSessions += point.sessions
                slowStats.count += 1
            } else if speed <= 16 {
                mediumStats.totalAccuracy += point.value
                mediumStats.totalSessions += point.sessions
                mediumStats.count += 1
            } else {
                fastStats.totalAccuracy += point.value
                fastStats.totalSessions += point.sessions
                fastStats.count += 1
            }
        }

        var results: [(range: String, accuracy: Double, sessions: Int, description: String)] = []

        if slowStats.count > 0 {
            results.append((
                range: "Slow (≤13)",
                accuracy: slowStats.totalAccuracy / Double(slowStats.count),
                sessions: slowStats.totalSessions,
                description: "Easy"
            ))
        }

        if mediumStats.count > 0 {
            results.append((
                range: "Medium (14-16)",
                accuracy: mediumStats.totalAccuracy / Double(mediumStats.count),
                sessions: mediumStats.totalSessions,
                description: "Moderate"
            ))
        }

        if fastStats.count > 0 {
            results.append((
                range: "Fast (17+)",
                accuracy: fastStats.totalAccuracy / Double(fastStats.count),
                sessions: fastStats.totalSessions,
                description: "Challenging"
            ))
        }

        return results.sorted { $0.accuracy > $1.accuracy }
    }

    private var locationGreenCombos: [(combination: String, accuracy: Double, sessions: Int, shots: Int, averageSpeed: Double)] {
        var combos: [String: (totalAccuracy: Double, totalSessions: Int, totalShots: Int, totalSpeed: Double, count: Int)] = [:]

        for point in analytics.heatmapData {
            let combo = "\(point.conditions.location.capitalized) \(point.conditions.greenType.capitalized)"
            if combos[combo] != nil {
                combos[combo]!.totalAccuracy += point.value
                combos[combo]!.totalSessions += point.sessions
                combos[combo]!.totalShots += point.shots
                combos[combo]!.totalSpeed += Double(point.conditions.greenSpeed)
                combos[combo]!.count += 1
            } else {
                combos[combo] = (
                    totalAccuracy: point.value,
                    totalSessions: point.sessions,
                    totalShots: point.shots,
                    totalSpeed: Double(point.conditions.greenSpeed),
                    count: 1
                )
            }
        }

        return combos.map {
            (
                combination: $0.key,
                accuracy: $0.value.totalAccuracy / Double($0.value.count),
                sessions: $0.value.totalSessions,
                shots: $0.value.totalShots,
                averageSpeed: $0.value.totalSpeed / Double($0.value.count)
            )
        }.sorted { $0.accuracy > $1.accuracy }
    }
}

// Green Speed Card
struct GreenSpeedCard: View {
    let speedRange: String
    let accuracy: Double
    let sessions: Int
    let description: String

    var body: some View {
        VStack(spacing: 8) {
            Text(speedRange)
                .font(.headline)
                .foregroundColor(.blue)

            VStack(spacing: 4) {
                Text(String(format: "%.1f%%", accuracy))
                    .font(.title3)
                    .fontWeight(.bold)
                Text("\(sessions) sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(description)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// Location Green Combo Card
struct LocationGreenComboCard: View {
    let combination: String
    let accuracy: Double
    let sessions: Int
    let shots: Int
    let averageSpeed: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(combination)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Speed: \(String(format: "%.0f", averageSpeed))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 16) {
                VStack(spacing: 2) {
                    Text(String(format: "%.1f%%", accuracy))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("accuracy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 2) {
                    Text("\(shots)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("shots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ErrorView: View {
    let title: String
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .foregroundColor(.secondary)
            Button(action: onRetry) {
                Text("Retry")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
    }
}

// Local ViewModel for DetailedAnalyticsView
@MainActor
class DetailedAnalyticsViewModelLocal: ObservableObject {
    @Published var analytics: ComparativeAnalyticsResponse?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedPeriod = "all"

    private let apiService = APIService.shared

    func loadAnalytics() {
        isLoading = true
        error = nil

        Task {
            do {
                let query = ComparativeAnalyticsQuery(
                    period: selectedPeriod,
                    sport: "lawn_bowls"
                )

                let response = try await apiService.getComparativeAnalytics(query: query)

                await MainActor.run {
                    self.analytics = response
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("❌ Failed to load shot analysis: \(error)")
            }
        }
    }
}

struct DetailedAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedAnalyticsView()
    }
}