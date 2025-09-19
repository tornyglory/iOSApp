import SwiftUI
import Charts
import Foundation

struct LiveChartsComponent: View {
    let chartData: ChartViewData
    @State private var selectedChart: ChartType = .accuracy

    enum ChartType: String, CaseIterable {
        case accuracy = "Accuracy"
        case shotTypes = "Shot Types"
        case recentShots = "Recent Shots"

        var icon: String {
            switch self {
            case .accuracy: return "chart.line.uptrend.xyaxis"
            case .shotTypes: return "chart.pie.fill"
            case .recentShots: return "target"
            }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Chart selector
            Picker("Chart Type", selection: $selectedChart) {
                ForEach(ChartType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            // Chart content
            switch selectedChart {
            case .accuracy:
                AccuracyChartView(accuracyPoints: chartData.accuracyPoints)
            case .shotTypes:
                ShotTypeChartView(shotTypes: chartData.shotTypeData)
            case .recentShots:
                RecentShotsChartView(recentShots: chartData.recentShots)
            }

            // Performance metrics summary
            PerformanceMetricsCard(metrics: chartData.metrics)

            // Last updated info
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text("Updated: \(chartData.lastUpdatedFormatted)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Session: \(chartData.sessionDuration)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Accuracy Chart View
struct AccuracyChartView: View {
    let accuracyPoints: [AccuracyPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accuracy Over Time")
                .font(.headline)
                .padding(.horizontal)

            if accuracyPoints.isEmpty {
                EmptyChartView(message: "No accuracy data available")
            } else {
                Chart(accuracyPoints) { point in
                    LineMark(
                        x: .value("Shot Number", point.shotNumber),
                        y: .value("Accuracy", point.cumulativeAccuracy)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 3))

                    PointMark(
                        x: .value("Shot Number", point.shotNumber),
                        y: .value("Accuracy", point.cumulativeAccuracy)
                    )
                    .foregroundStyle(.blue)
                    .symbolSize(40)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(Int(doubleValue))%")
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)")
                            }
                        }
                    }
                }
                .frame(height: 200)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Shot Type Chart View
struct ShotTypeChartView: View {
    let shotTypes: [ShotTypeData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shot Type Distribution")
                .font(.headline)
                .padding(.horizontal)

            if shotTypes.isEmpty {
                EmptyChartView(message: "No shot type data available")
            } else {
                Chart(shotTypes) { shotType in
                    BarMark(
                        x: .value("Count", shotType.count),
                        y: .value("Type", shotType.type.capitalized)
                    )
                    .foregroundStyle(colorForShotType(shotType.type))
                    .opacity(0.8)
                }
                .frame(height: 200)
                .padding(.horizontal)

                // Legend
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(shotTypes) { shotType in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(colorForShotType(shotType.type))
                                .frame(width: 12, height: 12)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(shotType.type.capitalized)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text("\(shotType.count) (\(String(format: "%.1f", shotType.percentage))%)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func colorForShotType(_ type: String) -> Color {
        switch type.lowercased() {
        case "draw": return .blue
        case "yard_on": return .green
        case "ditch_weight": return .orange
        case "drive": return .red
        default: return .gray
        }
    }
}

// MARK: - Recent Shots Chart View
struct RecentShotsChartView: View {
    let recentShots: [RecentShotData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Shot Performance")
                .font(.headline)
                .padding(.horizontal)

            if recentShots.isEmpty {
                EmptyChartView(message: "No recent shots available")
            } else {
                Chart(recentShots) { shot in
                    BarMark(
                        x: .value("Shot", shot.shotNumber),
                        y: .value("Points", shot.wasSuccessful ? Double(shot.points) : 0.1) // Give missed shots a small visible height
                    )
                    .foregroundStyle(shot.wasSuccessful ? Color.green : Color.red)
                    .opacity(shot.wasSuccessful ? 0.8 : 0.9)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)")
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)")
                            }
                        }
                    }
                }
                .frame(height: 200)
                .padding(.horizontal)

                // Legend
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(.green)
                            .frame(width: 12, height: 12)
                        Text("Successful")
                            .font(.caption)
                    }

                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(.red)
                            .frame(width: 12, height: 12)
                        Text("Missed")
                            .font(.caption)
                    }

                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Performance Metrics Card
struct PerformanceMetricsCard: View {
    let metrics: PerformanceMetrics

    var body: some View {
        VStack(spacing: 16) {
            Text("Live Performance Metrics")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricItem(
                    title: "Total Shots",
                    value: "\(metrics.totalShots)",
                    icon: "target",
                    color: .blue
                )

                MetricItem(
                    title: "Successful",
                    value: "\(metrics.successfulShots)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                MetricItem(
                    title: "Accuracy",
                    value: String(format: "%.1f%%", metrics.overallAccuracy),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )

                MetricItem(
                    title: "Current Streak",
                    value: "\(metrics.currentStreak)",
                    icon: "flame.fill",
                    color: .red
                )

                MetricItem(
                    title: "Best Streak",
                    value: "\(metrics.bestStreak)",
                    icon: "star.fill",
                    color: .yellow
                )

                MetricItem(
                    title: "Trend",
                    value: metrics.improvementTrend.capitalized,
                    icon: trendIcon(for: metrics.improvementTrend),
                    color: trendColor(for: metrics.improvementTrend)
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func trendIcon(for trend: String) -> String {
        switch trend.lowercased() {
        case "improving": return "arrow.up.circle.fill"
        case "declining": return "arrow.down.circle.fill"
        default: return "minus.circle.fill"
        }
    }

    private func trendColor(for trend: String) -> Color {
        switch trend.lowercased() {
        case "improving": return .green
        case "declining": return .red
        default: return .gray
        }
    }
}

// MARK: - Metric Item
struct MetricItem: View {
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
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Empty Chart View
struct EmptyChartView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}

struct LiveChartsComponent_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LiveChartsComponent(
                chartData: ChartViewData(
                    accuracyPoints: [
                        AccuracyPoint(shotNumber: 1, cumulativeAccuracy: 50.0, timestamp: Date()),
                        AccuracyPoint(shotNumber: 2, cumulativeAccuracy: 75.0, timestamp: Date()),
                        AccuracyPoint(shotNumber: 3, cumulativeAccuracy: 66.7, timestamp: Date())
                    ],
                    shotTypeData: [
                        ShotTypeData(type: "draw", count: 5, percentage: 50.0, averageAccuracy: 80.0),
                        ShotTypeData(type: "drive", count: 3, percentage: 30.0, averageAccuracy: 60.0),
                        ShotTypeData(type: "yard_on", count: 2, percentage: 20.0, averageAccuracy: 100.0)
                    ],
                    metrics: PerformanceMetrics(
                        totalShots: 10,
                        successfulShots: 7,
                        overallAccuracy: 70.0,
                        currentStreak: 3,
                        bestStreak: 5,
                        averageDistanceFromTarget: 1.2,
                        improvementTrend: "improving"
                    ),
                    recentShots: [
                        RecentShotData(shotNumber: 8, type: "draw", points: 2, distanceFromTarget: 0.5, notes: nil, timestamp: Date(), wasSuccessful: true),
                        RecentShotData(shotNumber: 9, type: "drive", points: 0, distanceFromTarget: 2.1, notes: nil, timestamp: Date(), wasSuccessful: false),
                        RecentShotData(shotNumber: 10, type: "draw", points: 1, distanceFromTarget: 1.2, notes: nil, timestamp: Date(), wasSuccessful: true)
                    ],
                    metadata: ChartMetadata(
                        lastUpdated: Date(),
                        sessionStartTime: Date().addingTimeInterval(-1800),
                        refreshIntervalSeconds: 5,
                        dataPoints: 10
                    )
                )
            )
        }
        .padding()
    }
}