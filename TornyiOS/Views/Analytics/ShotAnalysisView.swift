import SwiftUI

struct ShotAnalysisView: View {
    @StateObject private var viewModel = ShotAnalysisViewModel()
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
                        if viewModel.isLoading {
                            VStack(spacing: 12) {
                                TornyLoadingView(color: .tornyBlue)
                                Text("Loading shot analysis...")
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextSecondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 300)
                            .padding()
                        } else if let analytics = viewModel.analytics {
                            // Header Section
                            LifetimeStatsHeader(
                                selectedPeriod: $viewModel.selectedPeriod,
                                analytics: analytics,
                                onPeriodChanged: viewModel.loadAnalytics
                            )

                            // Session Statistics
                            LifetimeSessionStats(analytics: analytics)
                                .padding(.horizontal, 16)

                            // Shot Type Breakdown Cards
                            LifetimeShotTypeBreakdown(analytics: analytics)
                                .padding(.horizontal, 16)

                            // Scoring System Info
                            ScoringSystemInfo()
                                .padding(.horizontal, 16)

                            // Detailed Shot Breakdown by Type
                            DetailedShotBreakdown(analytics: analytics)
                                .padding(.horizontal, 16)

                            // Length & Hand Analysis
                            LengthHandAnalysis(analytics: analytics)
                                .padding(.horizontal, 16)

                            // Green Type & Conditions Breakdown
                            ConditionsBreakdown(analytics: analytics)
                                .padding(.horizontal, 16)

                            // Green Types & Speeds Detailed Analysis
                            GreenTypesSpeedsAnalysis(analytics: analytics)
                                .padding(.horizontal, 16)

                        } else if let error = viewModel.error {
                            ErrorView(
                                title: "Failed to Load Shot Analysis",
                                message: error.localizedDescription,
                                onRetry: viewModel.loadAnalytics
                            )
                            .padding()
                        }
                }
                .padding(.vertical, 16)
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
        .onAppear {
            viewModel.loadAnalytics()
        }
    }
}

// MARK: - Lifetime Stats Header

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
            // Date Range & Period Selector
            VStack(spacing: 12) {
                Text("Lifetime Performance")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(periodDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Period Selector
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

            // Conditions Summary (similar to session header)
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

            HStack {
                HStack {
                    Image(systemName: "speedometer")
                    Text("Speed: \(averageGreenSpeed, specifier: "%.0f")s")
                }

                Spacer()

                HStack {
                    Image(systemName: "clock")
                    Text("Sessions: \(totalSessions)")
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
        return locationCounts.max { $0.value < $1.value }?.key?.capitalized ?? "Indoor"
    }

    private var mostCommonGreenType: String {
        let greenTypes = analytics.heatmapData.map { $0.conditions.greenType }
        let greenTypeCounts = Dictionary(grouping: greenTypes) { $0 }.mapValues { $0.count }
        return greenTypeCounts.max { $0.value < $1.value }?.key?.capitalized ?? "Carpet"
    }

    private var averageGreenSpeed: Double {
        let speeds = analytics.heatmapData.map { Double($0.conditions.greenSpeed) }
        return speeds.isEmpty ? 0 : speeds.reduce(0, +) / Double(speeds.count)
    }

    private var totalSessions: Int {
        analytics.heatmapData.reduce(0) { $0 + $1.sessions }
    }
}

// MARK: - Lifetime Session Stats

struct LifetimeSessionStats: View {
    let analytics: ComparativeAnalyticsResponse

    var body: some View {
        VStack(spacing: 16) {
            Text("Lifetime Statistics")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                StatColumn(
                    value: "\(totalShots)",
                    label: "Total Shots",
                    color: .primary
                )

                StatColumn(
                    value: "\(successfulShots)",
                    label: "Successful",
                    color: .green
                )

                StatColumn(
                    value: "\(overallAccuracy, specifier: "%.1f")%",
                    label: "Accuracy",
                    color: .green
                )
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

// MARK: - Lifetime Shot Type Breakdown

struct LifetimeShotTypeBreakdown: View {
    let analytics: ComparativeAnalyticsResponse

    var body: some View {
        VStack(spacing: 16) {
            Text("Shot Type Breakdown")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                let columns = Array(shotTypeStats.chunked(into: 2))
                ForEach(Array(columns.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.type) { stat in
                            ShotTypeBreakdownCard(
                                shotType: stat.type,
                                shots: stat.shots,
                                points: stat.points,
                                accuracy: stat.accuracy,
                                color: shotTypeColor(stat.type)
                            )
                            .frame(maxWidth: .infinity)
                        }

                        // Add spacer if odd number of items in last row
                        if row.count == 1 {
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
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
        aggregateFromLengthCategory(analytics.lengthMatrix.short, into: &stats)
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
        case "draw": return TornyColors.drawGreen
        case "yard_on": return TornyColors.yardOnBlue
        case "ditch_weight": return TornyColors.ditchWeightOrange
        case "drive": return TornyColors.drivePurple
        default: return .gray
        }
    }
}

// MARK: - Scoring System Info

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

// MARK: - Detailed Shot Breakdown

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
                    DetailedShotTypeSection(
                        shotType: stat.type,
                        shots: stat.shots,
                        points: stat.points,
                        lengthBreakdown: getLengthBreakdown(for: stat.type),
                        handBreakdown: getHandBreakdown(for: stat.type),
                        color: shotTypeColor(stat.type)
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private var shotTypeStats: [(type: String, shots: Int, points: Int)] {
        var stats: [String: (shots: Int, points: Int)] = [:]

        aggregateFromLengthCategory(analytics.lengthMatrix.short, into: &stats)
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

    private func getLengthBreakdown(for shotType: String) -> (foot: Int, yard: Int, miss: Int) {
        var foot = 0, yard = 0, miss = 0

        // Estimate foot/yard/miss from points and shots
        if let shortData = analytics.lengthMatrix.short[shotType] {
            foot += Int(Double(shortData.points) / 2.0) // 2 points = foot
            yard += Int(Double(shortData.shots - Int(Double(shortData.points) / 2.0)) * 0.6) // estimate yard from remaining
            miss += shortData.shots - foot - yard
        }

        if let mediumData = analytics.lengthMatrix.medium[shotType] {
            foot += Int(Double(mediumData.points) / 2.0)
            yard += Int(Double(mediumData.shots - Int(Double(mediumData.points) / 2.0)) * 0.6)
            miss += mediumData.shots - foot - yard
        }

        if let longData = analytics.lengthMatrix.long?[shotType] {
            foot += Int(Double(longData.points) / 2.0)
            yard += Int(Double(longData.shots - Int(Double(longData.points) / 2.0)) * 0.6)
            miss += longData.shots - foot - yard
        }

        return (foot: foot, yard: yard, miss: miss)
    }

    private func getHandBreakdown(for shotType: String) -> (forehand: Int, backhand: Int) {
        // Estimate 50/50 split for simplicity - in a real implementation this would come from the API
        let totalShots = shotTypeStats.first { $0.type == shotType }?.shots ?? 0
        return (forehand: totalShots / 2, backhand: totalShots / 2)
    }

    private func shotTypeColor(_ shotType: String) -> Color {
        switch shotType.lowercased() {
        case "draw": return TornyColors.drawGreen
        case "yard_on": return TornyColors.yardOnBlue
        case "ditch_weight": return TornyColors.ditchWeightOrange
        case "drive": return TornyColors.drivePurple
        default: return .gray
        }
    }
}

// MARK: - Length & Hand Analysis

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

                HStack(spacing: 8) {
                    LengthPerformanceCard(title: "Short", data: analytics.lengthMatrix.short, color: .green)
                        .frame(maxWidth: .infinity)
                    LengthPerformanceCard(title: "Medium", data: analytics.lengthMatrix.medium, color: .orange)
                        .frame(maxWidth: .infinity)
                    if let long = analytics.lengthMatrix.long {
                        LengthPerformanceCard(title: "Long", data: long, color: .red)
                            .frame(maxWidth: .infinity)
                    } else {
                        Spacer()
                            .frame(maxWidth: .infinity)
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
        analytics.radarChart.series.first { $0.name == "forehand" }?.data.reduce(0, +).map { $0 / Double(analytics.radarChart.categories.count) } ?? 0
    }

    private var backhandAccuracy: Double {
        analytics.radarChart.series.first { $0.name == "backhand" }?.data.reduce(0, +).map { $0 / Double(analytics.radarChart.categories.count) } ?? 0
    }

    private var forehandShots: Int {
        analytics.heatmapData.reduce(0) { $0 + $1.shots } / 2 // Rough estimate
    }

    private var backhandShots: Int {
        analytics.heatmapData.reduce(0) { $0 + $1.shots } / 2 // Rough estimate
    }
}

// MARK: - Conditions Breakdown

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

                VStack(spacing: 8) {
                    let columns = Array(greenTypePerformance.chunked(into: 2))
                    ForEach(Array(columns.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: 8) {
                            ForEach(row, id: \.type) { greenType in
                                GreenTypePerformanceCard(
                                    greenType: greenType.type,
                                    accuracy: greenType.accuracy,
                                    sessions: greenType.sessions
                                )
                                .frame(maxWidth: .infinity)
                            }

                            if row.count == 1 {
                                Spacer()
                                    .frame(maxWidth: .infinity)
                            }
                        }
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
            let description = "\(conditions.location) \(conditions.greenType) (Speed \(conditions.greenSpeed))"
            return (description: description, accuracy: worst.value, sessions: worst.sessions)
        }
        return nil
    }
}

// MARK: - Green Types & Speeds Analysis

struct GreenTypesSpeedsAnalysis: View {
    let analytics: ComparativeAnalyticsResponse

    var body: some View {
        VStack(spacing: 16) {
            Text("Green Types & Speeds Analysis")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Green Types Performance Grid
            VStack(alignment: .leading, spacing: 12) {
                Text("Performance by Green Type")
                    .font(.headline)

                VStack(spacing: 12) {
                    let columns = Array(greenTypeStats.chunked(into: 2))
                    ForEach(Array(columns.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: 12) {
                            ForEach(row, id: \.type) { greenType in
                                DetailedGreenTypeCard(
                                    greenType: greenType.type,
                                    accuracy: greenType.accuracy,
                                    sessions: greenType.sessions,
                                    shots: greenType.shots,
                                    averageSpeed: greenType.averageSpeed
                                )
                                .frame(maxWidth: .infinity)
                            }

                            if row.count == 1 {
                                Spacer()
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }

            Divider()

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
                        .frame(maxWidth: .infinity)
                    }

                    // Add spacers for remaining slots if less than 3 items
                    ForEach(0..<(3 - speedRangeStats.count), id: \.self) { _ in
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            Divider()

            // Location vs Green Type Matrix
            VStack(alignment: .leading, spacing: 12) {
                Text("Location & Green Type Combinations")
                    .font(.headline)

                ForEach(locationGreenCombos, id: \.combination) { combo in
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

    private var greenTypeStats: [(type: String, accuracy: Double, sessions: Int, shots: Int, averageSpeed: Double)] {
        var stats: [String: (totalAccuracy: Double, totalSessions: Int, totalShots: Int, totalSpeed: Double, count: Int)] = [:]

        for point in analytics.heatmapData {
            let greenType = point.conditions.greenType
            if stats[greenType] != nil {
                stats[greenType]!.totalAccuracy += point.value
                stats[greenType]!.totalSessions += point.sessions
                stats[greenType]!.totalShots += point.shots
                stats[greenType]!.totalSpeed += Double(point.conditions.greenSpeed)
                stats[greenType]!.count += 1
            } else {
                stats[greenType] = (
                    totalAccuracy: point.value,
                    totalSessions: point.sessions,
                    totalShots: point.shots,
                    totalSpeed: Double(point.conditions.greenSpeed),
                    count: 1
                )
            }
        }

        return stats.map {
            (
                type: $0.key.capitalized,
                accuracy: $0.value.totalAccuracy / Double($0.value.count),
                sessions: $0.value.totalSessions,
                shots: $0.value.totalShots,
                averageSpeed: $0.value.totalSpeed / Double($0.value.count)
            )
        }.sorted { $0.accuracy > $1.accuracy }
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

// MARK: - Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    ShotAnalysisView()
}