import SwiftUI

struct AnalyticsView: View {
    @ObservedObject private var apiService = APIService.shared
    @State private var trainingStats: TrainingStatsResponse?
    @State private var progressData: TrainingProgressResponse?
    @State private var selectedPeriod: String = "month"
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let periods = ["week", "month", "year", "all"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView("Loading analytics...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        PeriodSelector(selectedPeriod: $selectedPeriod, periods: periods, onChange: loadAnalytics)
                        
                        if let stats = trainingStats {
                            OverallStatsCard(stats: stats)
                            AccuracyBreakdownCard(stats: stats)
                            HandAndLengthStatsCard(stats: stats)
                            ShotTypeStatsCard(stats: stats)
                        }
                        
                        if let progress = progressData {
                            ProgressChartCard(progress: progress)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .refreshable {
                await loadAnalyticsAsync()
            }
            .task {
                await loadAnalyticsAsync()
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func loadAnalytics() {
        Task {
            await loadAnalyticsAsync()
        }
    }
    
    private func loadAnalyticsAsync() async {
        isLoading = true
        
        do {
            async let statsTask = apiService.getTrainingStats(period: selectedPeriod)
            async let progressTask = apiService.getTrainingProgress(groupBy: "week", limit: 12)
            
            trainingStats = try await statsTask
            progressData = try await progressTask
            
            isLoading = false
        } catch {
            await MainActor.run {
                alertMessage = error.localizedDescription
                showingAlert = true
                isLoading = false
            }
        }
    }
}

struct PeriodSelector: View {
    @Binding var selectedPeriod: String
    let periods: [String]
    let onChange: () -> Void
    
    var body: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(periods, id: \.self) { period in
                Text(period.capitalized).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedPeriod) { _ in
            onChange()
            
        }
    }
}

struct OverallStatsCard: View {
    let stats: TrainingStatsResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overall Performance")
                .font(.headline)
            
            HStack {
                StatColumn(
                    title: "Sessions",
                    value: "\(stats.totalSessions)",
                    trend: nil
                )
                
                Spacer()
                
                StatColumn(
                    title: "Total Shots",
                    value: "\(stats.totalShots)",
                    trend: nil
                )
                
                Spacer()
                
                StatColumn(
                    title: "Overall Accuracy",
                    value: "\(stats.overallAccuracy)%",
                    trend: stats.improvementTrend.draw
                )
            }
            
            HStack {
                Text("Best Hand: \(stats.bestHand.rawValue.capitalized)")
                Spacer()
                Text("Best Length: \(stats.bestLength.rawValue.capitalized)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AccuracyBreakdownCard: View {
    let stats: TrainingStatsResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accuracy Breakdown")
                .font(.headline)
            
            HStack {
                AccuracyColumn(
                    title: "Draw Shots",
                    accuracy: stats.drawAccuracy,
                    count: stats.shotBreakdown.draw,
                    trend: stats.improvementTrend.draw,
                    color: .blue
                )
                
                Spacer()
                
                AccuracyColumn(
                    title: "Weighted Shots",
                    accuracy: stats.weightedAccuracy,
                    count: stats.shotBreakdown.weighted,
                    trend: stats.improvementTrend.weighted,
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct HandAndLengthStatsCard: View {
    let stats: TrainingStatsResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance by Hand & Length")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("By Hand")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(stats.detailedStats.byHand, id: \.hand) { handStat in
                    HStack {
                        Text(handStat.hand.rawValue.capitalized)
                        Spacer()
                        Text("\(handStat.shots) shots")
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f%%", handStat.accuracy))
                            .fontWeight(.semibold)
                            .foregroundColor(handStat.accuracy >= 70 ? .green : .orange)
                    }
                    .font(.subheadline)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("By Length")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(stats.detailedStats.byLength, id: \.length) { lengthStat in
                    HStack {
                        Text(lengthStat.length.rawValue.capitalized)
                        Spacer()
                        Text("\(lengthStat.shots) shots")
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f%%", lengthStat.accuracy))
                            .fontWeight(.semibold)
                            .foregroundColor(lengthStat.accuracy >= 70 ? .green : .orange)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ShotTypeStatsCard: View {
    let stats: TrainingStatsResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shot Type Performance")
                .font(.headline)
            
            ForEach(stats.detailedStats.byShotType, id: \.shotType) { shotStat in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(shotTypeDisplayName(shotStat.shotType))
                            .fontWeight(.semibold)
                        Spacer()
                        Text(String(format: "%.1f%%", shotStat.accuracy))
                            .fontWeight(.bold)
                            .foregroundColor(shotStat.accuracy >= 70 ? .green : .orange)
                    }
                    
                    HStack {
                        Text("\(shotStat.successful)/\(shotStat.count) successful")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        ProgressView(value: shotStat.accuracy, total: 100)
                            .frame(width: 100)
                            .tint(shotStat.accuracy >= 70 ? .green : .orange)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func shotTypeDisplayName(_ type: ShotType) -> String {
        switch type {
        case .draw: return "Draw"
        case .yardOn: return "Yard On"
        case .ditchWeight: return "Ditch Weight"
        case .drive: return "Drive"
        }
    }
}

struct ProgressChartCard: View {
    let progress: TrainingProgressResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress Over Time")
                .font(.headline)
            
            if progress.progressData.count >= 2 {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Progress Data")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(progress.progressData.prefix(5), id: \.period) { data in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(data.periodLabel)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text("\(data.sessions) sessions • \(data.totalShots) shots")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(String(format: "%.1f%%", data.overallAccuracy))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                HStack(spacing: 8) {
                                    Text(String(format: "D: %.1f%%", data.drawAccuracy))
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                    Text(String(format: "W: %.1f%%", data.weightedAccuracy))
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .frame(height: 200)
            } else {
                Text("Not enough data for chart")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Trends")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack {
                    TrendItem(title: "Overall", trend: progress.trends.overallAccuracy)
                    Spacer()
                    TrendItem(title: "Sessions/Week", trend: progress.trends.sessionFrequency)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatColumn: View {
    let title: String
    let value: String
    let trend: String?
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            if let trend = trend {
                Text(trend)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(trend.hasPrefix("+") ? .green : .red)
            }
        }
    }
}

struct AccuracyColumn: View {
    let title: String
    let accuracy: Double
    let count: Int
    let trend: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(String(format: "%.1f%%", accuracy))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(count) shots")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(trend)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(trend.hasPrefix("+") ? .green : .red)
        }
    }
}

struct TrendItem: View {
    let title: String
    let trend: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(trend)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(trend.hasPrefix("+") ? .green : .red)
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}
