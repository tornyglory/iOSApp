import SwiftUI

struct AnalyticsDetailView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)

                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        TornyLoadingView(color: .tornyBlue)
                        Text("Loading analytics...")
                            .font(TornyFonts.body)
                            .foregroundColor(.tornyTextSecondary)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Failed to load analytics")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            viewModel.fetchAnalytics()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if let analytics = viewModel.analytics {
                    ScrollView {
                        VStack(spacing: 16) {
                            OverviewCard(analytics: analytics)
                            AccuracyCard(analytics: analytics)
                            // ShotTypeBreakdownCard removed - use DetailedAnalyticsView for comprehensive analysis
                            DrawDistanceCard(analytics: analytics)
                            PerformanceByHandCard(analytics: analytics)
                            PerformanceByLengthCard(analytics: analytics)
                            ImprovementTrendCard(analytics: analytics)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Performance Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchAnalytics()
        }
    }
}

// MARK: - Overview Card
struct OverviewCard: View {
    let analytics: AnalyticsResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overall Performance")
                .font(.headline)

            HStack {
                StatBox(
                    value: "\(analytics.totalSessions)",
                    label: "Sessions",
                    color: .blue
                )

                StatBox(
                    value: "\(analytics.totalShots)",
                    label: "Total Shots",
                    color: .purple
                )

                StatBox(
                    value: analytics.averageScore,
                    label: "Avg Score",
                    color: .orange
                )
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Best Hand", systemImage: "hand.raised")
                        .font(.subheadline)
                    Spacer()
                    Text(analytics.bestHand.capitalized)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }

                HStack {
                    Label("Best Length", systemImage: "ruler")
                        .font(.subheadline)
                    Spacer()
                    Text(analytics.bestLength.capitalized)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }

                HStack {
                    Label("Total Points", systemImage: "star.fill")
                        .font(.subheadline)
                    Spacer()
                    Text("\(analytics.totalPoints) / \(analytics.maxPossiblePoints)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Accuracy Card
struct AccuracyCard: View {
    let analytics: AnalyticsResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accuracy Metrics")
                .font(.headline)

            VStack(spacing: 12) {
                AccuracyRow(
                    title: "Overall Accuracy",
                    value: analytics.overallAccuracy,
                    color: .green
                )

                AccuracyRow(
                    title: "Draw Accuracy",
                    value: analytics.drawAccuracy,
                    color: .blue
                )

                AccuracyRow(
                    title: "Weighted Accuracy",
                    value: analytics.weightedAccuracy,
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Shot Type Breakdown removed to avoid duplicate with DetailedAnalyticsView

// MARK: - Draw Distance Card
struct DrawDistanceCard: View {
    let analytics: AnalyticsResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Draw Shot Distribution")
                .font(.headline)

            HStack(spacing: 12) {
                DrawDistanceBox(
                    label: "Foot",
                    count: analytics.drawBreakdown.foot,
                    color: .green,
                    points: 2
                )

                DrawDistanceBox(
                    label: "Yard",
                    count: analytics.drawBreakdown.yard,
                    color: .orange,
                    points: 1
                )

                DrawDistanceBox(
                    label: "Miss",
                    count: analytics.drawBreakdown.miss,
                    color: .red,
                    points: 0
                )
            }

            Divider()

            Text("Shot Counts")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    Text("Draw: \(analytics.shotBreakdown.draw)")
                        .font(.subheadline)
                }

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 8, height: 8)
                    Text("Weighted: \(analytics.shotBreakdown.weighted)")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Performance by Hand Card
struct PerformanceByHandCard: View {
    let analytics: AnalyticsResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance by Hand")
                .font(.headline)

            ForEach(analytics.detailedStats.byHand) { hand in
                HandStatRow(hand: hand)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Performance by Length Card
struct PerformanceByLengthCard: View {
    let analytics: AnalyticsResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance by Length")
                .font(.headline)

            ForEach(analytics.detailedStats.byLength) { length in
                LengthStatRow(length: length)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Improvement Trend Card
struct ImprovementTrendCard: View {
    let analytics: AnalyticsResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Improvement Trends")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            VStack(spacing: 8) {
                AnalyticsTrendRow(
                    title: "Draw Shots",
                    trend: analytics.improvementTrend.draw
                )

                AnalyticsTrendRow(
                    title: "Weighted Shots",
                    trend: analytics.improvementTrend.weighted
                )
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

// MARK: - Helper Components
struct StatBox: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AccuracyRow: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text("\(value)%")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}

struct ShotTypeRow: View {
    let shotType: AnalyticsShotTypeStat

    var shotColor: Color {
        switch shotType.shotType {
        case "draw":
            return .blue
        case "drive":
            return .purple
        case "yard_on":
            return .green
        case "ditch_weight":
            return .orange
        default:
            return .gray
        }
    }

    var formattedName: String {
        shotType.shotType.replacingOccurrences(of: "_", with: " ").capitalized
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(formattedName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(shotColor)
                Spacer()
                Text("\(shotType.accuracy)%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(shotColor)
            }

            HStack {
                HStack(spacing: 4) {
                    Text("\(shotType.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("shots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("\(shotType.totalPoints)")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("/ \(shotType.maxPoints) pts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(shotColor.opacity(0.05))
        .cornerRadius(8)
    }
}

struct DrawDistanceBox: View {
    let label: String
    let count: Int
    let color: Color
    let points: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
            Text("\(points) pts")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct HandStatRow: View {
    let hand: AnalyticsHandStat

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(hand.hand.capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                HStack(spacing: 8) {
                    Text("\(hand.shots) shots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("• \(hand.totalPoints) pts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text("\(hand.accuracy)%")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(hand.hand == "forehand" ? .green : .blue)
        }
        .padding(.vertical, 4)
    }
}

struct LengthStatRow: View {
    let length: AnalyticsLengthStat

    var lengthColor: Color {
        switch length.length {
        case "short":
            return .blue
        case "medium":
            return .purple
        case "long":
            return .orange
        default:
            return .gray
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(length.length.capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                HStack(spacing: 8) {
                    Text("\(length.shots) shots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("• \(length.totalPoints) pts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text("\(length.accuracy)%")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(lengthColor)
        }
        .padding(.vertical, 4)
    }
}

struct AnalyticsTrendRow: View {
    let title: String
    let trend: String?

    var trendIcon: String {
        guard let trend = trend else { return "minus" }
        if trend.contains("up") || trend.contains("+") {
            return "arrow.up.right"
        } else if trend.contains("down") || trend.contains("-") {
            return "arrow.down.right"
        }
        return "minus"
    }

    var trendColor: Color {
        guard let trend = trend else { return .gray }
        if trend.contains("up") || trend.contains("+") {
            return .green
        } else if trend.contains("down") || trend.contains("-") {
            return .red
        }
        return .gray
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: trendIcon)
                    .font(.caption)
                    .foregroundColor(trendColor)
                Text(trend ?? "No data")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(trend != nil ? .primary : .secondary)
            }
        }
    }
}