import SwiftUI
import Charts

struct ComparativeAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ComparativeAnalysisViewModel()
    @State private var selectedPeriod: String = "all"
    @State private var selectedChartType: ChartType = .radar

    private let periodOptions = ["week", "month", "year", "all"]

    enum ChartType: String, CaseIterable {
        case radar = "Radar Chart"
        case heatmap = "Conditions Heatmap"
        case performance = "Performance Matrix"
        case timeAnalysis = "Time Analysis"
    }

    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()

                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        TornyLoadingView()
                        Text("Loading comparative analysis...")
                            .font(TornyFonts.body)
                            .foregroundColor(.tornyTextSecondary)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    ComparativeErrorView(
                        message: errorMessage,
                        onRetry: { viewModel.fetchComparativeData(period: selectedPeriod) }
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Period Filter
                            ComparativePeriodFilterView(
                                selectedPeriod: $selectedPeriod,
                                periods: periodOptions,
                                onPeriodChanged: { viewModel.fetchComparativeData(period: selectedPeriod) }
                            )

                            // Chart Type Selector
                            Picker("Chart Type", selection: $selectedChartType) {
                                ForEach(ChartType.allCases, id: \.self) { type in
                                    Label(type.rawValue, systemImage: iconForChartType(type))
                                        .tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)

                            // Charts section
                            if let comparativeData = viewModel.comparativeData {
                                VStack(spacing: 16) {
                                    switch selectedChartType {
                                    case .radar:
                                        RadarChartView(data: comparativeData.radarChart)
                                    case .heatmap:
                                        HeatmapView(data: comparativeData.heatmapData)
                                    case .performance:
                                        PerformanceMatrixView(data: comparativeData.lengthMatrix)
                                    case .timeAnalysis:
                                        TimeAnalysisView(data: comparativeData.timePerformance)
                                    }

                                    // Insights section
                                    InsightsCard(insights: comparativeData.insights)
                                }
                                .padding(.horizontal)
                            } else {
                                EmptyComparativeView()
                            }

                            Spacer(minLength: 100)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Comparative Analysis")
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
            .onChange(of: selectedPeriod) { _ in
                viewModel.fetchComparativeData(period: selectedPeriod)
            }
            .onAppear {
                viewModel.fetchComparativeData(period: selectedPeriod)
            }
        }
    }

    private func iconForChartType(_ type: ChartType) -> String {
        switch type {
        case .radar: return "chart.pie.fill"
        case .heatmap: return "grid"
        case .performance: return "chart.bar.xaxis"
        case .timeAnalysis: return "clock.fill"
        }
    }
}

// MARK: - Component Views

struct ComparativePeriodFilterView: View {
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

struct ComparativeErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Failed to load analysis data")
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

struct EmptyComparativeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("No Analysis Data Available")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Complete more training sessions to unlock comparative insights")
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
        .padding(.horizontal)
    }
}

// MARK: - Chart Components

struct RadarChartView: View {
    let data: RadarChartData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Radar")
                .font(.headline)
                .foregroundColor(.tornyTextPrimary)

            Text("Hand performance across shot types")
                .font(.subheadline)
                .foregroundColor(.tornyTextSecondary)

            if !data.series.isEmpty {
                // Simplified radar chart representation using bar charts
                VStack(spacing: 16) {
                    ForEach(data.categories.indices, id: \.self) { index in
                        let category = data.categories[index]

                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            HStack(spacing: 8) {
                                ForEach(data.series, id: \.name) { series in
                                    if index < series.data.count {
                                        VStack {
                                            ZStack(alignment: .bottom) {
                                                Rectangle()
                                                    .fill(.gray.opacity(0.2))
                                                    .frame(width: 40, height: 60)

                                                Rectangle()
                                                    .fill(series.name == "forehand" ? Color.blue : Color.green)
                                                    .frame(width: 40, height: CGFloat(Double(series.data[index]) ?? 0) * 0.6)
                                            }
                                            .cornerRadius(4)

                                            Text(series.name.capitalized)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)

                                            Text("\(series.data[index])%")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                Text("No radar data available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(height: 100)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct HeatmapView: View {
    let data: [HeatmapDataPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Playing Conditions Heatmap")
                .font(.headline)
                .foregroundColor(.tornyTextPrimary)

            Text("Accuracy by playing conditions")
                .font(.subheadline)
                .foregroundColor(.tornyTextSecondary)

            if !data.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                    ForEach(data.prefix(12), id: \.x) { point in
                        VStack(spacing: 4) {
                            Rectangle()
                                .fill(colorForValue(Double(point.value) ?? 0))
                                .frame(height: 40)
                                .cornerRadius(4)
                                .overlay(
                                    Text("\(point.value)%")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                )

                            Text(point.x)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                }
            } else {
                Text("No conditions data available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(height: 100)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func colorForValue(_ value: Double) -> Color {
        let normalized = value / 100.0
        if normalized > 0.8 {
            return .green
        } else if normalized > 0.6 {
            return .yellow
        } else if normalized > 0.4 {
            return .orange
        } else {
            return .red
        }
    }
}

struct PerformanceMatrixView: View {
    let data: LengthMatrix

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Matrix")
                .font(.headline)
                .foregroundColor(.tornyTextPrimary)

            Text("Accuracy by shot length and type")
                .font(.subheadline)
                .foregroundColor(.tornyTextSecondary)

            VStack(spacing: 12) {
                // Short shots
                if let shortData = data.short, !shortData.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Short Shots")
                            .font(.body)
                            .fontWeight(.medium)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            if let drawData = shortData["draw"] {
                                MetricView(
                                    title: "Draw",
                                    accuracy: drawData.accuracy,
                                    shots: drawData.shots,
                                    color: .blue
                                )
                            }
                            if let yardOnData = shortData["yard_on"] {
                                MetricView(
                                    title: "Yard On",
                                    accuracy: yardOnData.accuracy,
                                    shots: yardOnData.shots,
                                    color: .green
                                )
                            }
                        }
                    }
                }

                // Medium shots
                if !data.medium.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Medium Shots")
                            .font(.body)
                            .fontWeight(.medium)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            if let drawData = data.medium["draw"] {
                                MetricView(
                                    title: "Draw",
                                    accuracy: drawData.accuracy,
                                    shots: drawData.shots,
                                    color: .blue
                                )
                            }
                            if let yardOnData = data.medium["yard_on"] {
                                MetricView(
                                    title: "Yard On",
                                    accuracy: yardOnData.accuracy,
                                    shots: yardOnData.shots,
                                    color: .green
                                )
                            }
                        }
                    }
                }

                // Long shots
                if let longData = data.long, !longData.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Long Shots")
                            .font(.body)
                            .fontWeight(.medium)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            if let drawData = longData["draw"] {
                                MetricView(
                                    title: "Draw",
                                    accuracy: drawData.accuracy,
                                    shots: drawData.shots,
                                    color: .blue
                                )
                            }
                            if let driveData = longData["drive"] {
                                MetricView(
                                    title: "Drive",
                                    accuracy: driveData.accuracy,
                                    shots: driveData.shots,
                                    color: .purple
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct MetricView: View {
    let title: String
    let accuracy: Double
    let shots: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(String(format: "%.1f%%", accuracy))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text("\(shots) shots")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct TimeAnalysisView: View {
    let data: [TimePerformancePoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time Performance Analysis")
                .font(.headline)
                .foregroundColor(.tornyTextPrimary)

            Text("Performance by time of day")
                .font(.subheadline)
                .foregroundColor(.tornyTextSecondary)

            if !data.isEmpty {
                Chart(data) { timeData in
                    BarMark(
                        x: .value("Hour", timeData.hour),
                        y: .value("Accuracy", Double(timeData.accuracy) ?? 0)
                    )
                    .foregroundStyle(Color.purple)
                }
                .frame(height: 180)
                .chartYScale(domain: 0...100)
                .chartXScale(domain: 0...24)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(Int(doubleValue))%")
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)h")
                            }
                        }
                    }
                }
            } else {
                Text("No time analysis data available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(height: 100)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct InsightsCard: View {
    let insights: AnalyticsInsights

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Insights")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.tornyTextPrimary)

            VStack(spacing: 12) {
                InsightRow(
                    icon: "target",
                    title: "Best Performance",
                    description: "\(insights.bestHandShotCombo.hand.capitalized) \(insights.bestHandShotCombo.shotType.replacingOccurrences(of: "_", with: " "))",
                    value: String(format: "%.1f%%", Double(insights.bestHandShotCombo.accuracy) ?? 0),
                    color: .green
                )

                InsightRow(
                    icon: "location",
                    title: "Optimal Conditions",
                    description: insights.optimalConditions.description,
                    value: String(format: "%.1f%%", Double(insights.optimalConditions.accuracy) ?? 0),
                    color: .blue
                )

                if let bestWeather = insights.bestWeather {
                    InsightRow(
                        icon: "sun.max.fill",
                        title: "Best Weather",
                        description: bestWeather.weather.capitalized,
                        value: String(format: "%.1f%%", bestWeather.accuracy.doubleValue),
                        color: .orange
                    )
                }

                if let bestWind = insights.bestWindConditions {
                    InsightRow(
                        icon: "wind",
                        title: "Best Wind",
                        description: bestWind.windConditions.replacingOccurrences(of: "_", with: " ").capitalized,
                        value: String(format: "%.1f%%", bestWind.accuracy.doubleValue),
                        color: .cyan
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let description: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.tornyTextPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.tornyTextSecondary)
            }

            Spacer()

            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - ViewModel

class ComparativeAnalysisViewModel: ObservableObject {
    @Published var comparativeData: ComparativeAnalyticsResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    func fetchComparativeData(period: String = "all") {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let query = ComparativeAnalyticsQuery(
                    period: period,
                    sport: "lawn_bowls"
                )

                let data = try await apiService.getComparativeAnalytics(query: query)

                await MainActor.run {
                    self.comparativeData = data
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

struct ComparativeAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        ComparativeAnalysisView()
    }
}