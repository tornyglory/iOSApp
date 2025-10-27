import SwiftUI
import Charts

struct ProgressChartsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProgressChartsViewModel()
    @State private var selectedPeriod: String = "month"
    @State private var selectedChart: ChartType = .accuracy

    private let periodOptions = ["week", "month", "year", "all"]

    enum ChartType: String, CaseIterable {
        case accuracy = "Accuracy"
        case volume = "Volume"
        case score = "Score Progression"

        var icon: String {
            switch self {
            case .accuracy: return "chart.line.uptrend.xyaxis"
            case .volume: return "chart.bar.fill"
            case .score: return "chart.xyaxis.line"
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                TornyGradients.skyGradient
                    .ignoresSafeArea()

                TornyCloudView()
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        TornyLoadingView()
                        Text("Loading progress data...")
                            .font(TornyFonts.body)
                            .foregroundColor(.tornyTextSecondary)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    ProgressErrorView(
                        message: errorMessage,
                        onRetry: { viewModel.fetchProgressData(period: selectedPeriod) }
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Period Filter
                            PeriodFilterView(
                                selectedPeriod: $selectedPeriod,
                                periods: periodOptions,
                                onPeriodChanged: { viewModel.fetchProgressData(period: selectedPeriod) }
                            )

                            // Live Performance Metrics (similar to session recording)
                            if let progressData = viewModel.progressData {
                                LivePerformanceMetricsCard(progressData: progressData)
                            }

                            // Chart Type Selector
                            Picker("Chart Type", selection: $selectedChart) {
                                ForEach(ChartType.allCases, id: \.self) { type in
                                    Label(type.rawValue, systemImage: type.icon)
                                        .tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)

                            // Chart Content
                            if let progressData = viewModel.progressData {
                                Group {
                                    switch selectedChart {
                                    case .accuracy:
                                        ProgressAccuracyChart(data: progressData.chartData.accuracyTrend)
                                    case .volume:
                                        ProgressVolumeChart(data: progressData.chartData.volumeData)
                                    case .score:
                                        ProgressScoreChart(data: progressData.chartData.scoreProgression)
                                    }
                                }
                                .padding(.horizontal)
                            } else {
                                EmptyProgressView()
                            }

                            Spacer(minLength: 100)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Progress Charts")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.tornyBlue)
                            Text("Back")
                                .font(.body)
                                .foregroundColor(.tornyBlue)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchProgressData(period: selectedPeriod)
            }
        }
    }
}

// MARK: - Component Views

struct PeriodFilterView: View {
    @Binding var selectedPeriod: String
    let periods: [String]
    let onPeriodChanged: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Time Period")
                    .font(.headline)
                    .foregroundColor(.tornyTextPrimary)
                Spacer()
            }

            Picker("Period", selection: $selectedPeriod) {
                ForEach(periods, id: \.self) { period in
                    Text(period.capitalized).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedPeriod) { _ in onPeriodChanged() }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct LivePerformanceMetricsCard: View {
    let progressData: ProgressChartResponse

    var body: some View {
        VStack(spacing: 16) {
            Text("Live Performance Metrics")
                .font(.headline)
                .foregroundColor(.tornyTextPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ProgressMetricItem(
                    title: "Total Sessions",
                    value: "\(progressData.summary?.totalSessions ?? 0)",
                    icon: "calendar",
                    color: .blue
                )

                ProgressMetricItem(
                    title: "Total Shots",
                    value: "\(progressData.summary?.totalShots ?? 0)",
                    icon: "target",
                    color: .green
                )

                ProgressMetricItem(
                    title: "Accuracy",
                    value: currentAccuracyDisplay,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )

                ProgressMetricItem(
                    title: "Best Period",
                    value: bestPeriodDisplay,
                    icon: "star.fill",
                    color: .yellow
                )

                ProgressMetricItem(
                    title: "Volume Trend",
                    value: volumeTrend,
                    icon: "chart.bar.fill",
                    color: .purple
                )

                ProgressMetricItem(
                    title: "Consistency",
                    value: progressData.trends.consistency?.capitalized ?? "N/A",
                    icon: trendIcon,
                    color: trendColor
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }

    private var currentAccuracyDisplay: String {
        if let lastAccuracy = progressData.chartData.accuracyTrend.last?.overallAccuracy {
            return "\(lastAccuracy)%"
        }
        return "N/A"
    }

    private var bestPeriodDisplay: String {
        if let bestPeriod = progressData.summary?.bestPeriod {
            return "\(bestPeriod.overallAccuracy)%"
        }
        return "N/A"
    }

    private var volumeTrend: String {
        return progressData.trends.volume ?? "N/A"
    }

    private var trendIcon: String {
        guard let consistency = progressData.trends.consistency else {
            return "minus.circle.fill"
        }
        switch consistency.lowercased() {
        case "improving": return "arrow.up.circle.fill"
        case "declining": return "arrow.down.circle.fill"
        default: return "minus.circle.fill"
        }
    }

    private var trendColor: Color {
        guard let consistency = progressData.trends.consistency else {
            return .gray
        }
        switch consistency.lowercased() {
        case "improving": return .green
        case "declining": return .red
        default: return .gray
        }
    }
}

struct ProgressMetricItem: View {
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

// MARK: - Chart Components

struct ProgressAccuracyChart: View {
    let data: [AccuracyTrendPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accuracy Over Time")
                .font(.headline)
                .foregroundColor(.tornyTextPrimary)

            if !data.isEmpty {
                Chart(data) { point in
                    LineMark(
                        x: .value("Date", point.x),
                        y: .value("Overall", point.overallAccuracy)
                    )
                    .foregroundStyle(Color.blue)
                    .lineStyle(StrokeStyle(lineWidth: 3))

                    PointMark(
                        x: .value("Date", point.x),
                        y: .value("Overall", point.overallAccuracy)
                    )
                    .foregroundStyle(Color.blue)
                    .symbolSize(40)
                }
                .frame(height: 200)
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
            } else {
                EmptyProgressView()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ProgressScoreChart: View {
    let data: [ScoreProgressionPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score Progression")
                .font(.headline)
                .foregroundColor(.tornyTextPrimary)

            if !data.isEmpty {
                Chart(data) { point in
                    AreaMark(
                        x: .value("Date", point.x),
                        y: .value("Percentage", point.percentage)
                    )
                    .foregroundStyle(Color.green.opacity(0.3))

                    LineMark(
                        x: .value("Date", point.x),
                        y: .value("Percentage", point.percentage)
                    )
                    .foregroundStyle(Color.green)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }
                .frame(height: 180)
                .chartYScale(domain: 0...100)
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
            } else {
                EmptyProgressView()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ProgressVolumeChart: View {
    let data: [VolumeDataPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Training Volume")
                .font(.headline)
                .foregroundColor(.tornyTextPrimary)

            if !data.isEmpty {
                Chart(data) { point in
                    BarMark(
                        x: .value("Date", point.x),
                        y: .value("Sessions", point.sessions)
                    )
                    .foregroundStyle(Color.blue)
                    .opacity(0.7)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
            } else {
                EmptyProgressView()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ProgressErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Failed to load progress data")
                .font(.title2)
                .fontWeight(.bold)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct EmptyProgressView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("No data available for this period")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - ViewModel

@MainActor
class ProgressChartsViewModel: ObservableObject {
    @Published var progressData: ProgressChartResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var apiService: APIService { APIService.shared }

    func fetchProgressData(period: String = "month") {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let query = ProgressChartQuery(
                    groupBy: "week",
                    period: period,
                    limit: 24,
                    shotType: nil,
                    sport: "lawn_bowls"
                )

                let data = try await apiService.getProgressChartData(query: query)

                await MainActor.run {
                    self.progressData = data
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct ProgressChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressChartsView()
    }
}