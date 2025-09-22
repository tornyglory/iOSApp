import Foundation
import SwiftUI

@MainActor
class ProgressAnalyticsViewModel: ObservableObject {
    @Published var progressData: ProgressChartViewData?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    func fetchProgressData(query: ProgressChartQuery = ProgressChartQuery()) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.getProgressChartData(query: query)

            let viewData = ProgressChartViewData(
                accuracyTrend: response.chartData.accuracyTrend,
                volumeData: response.chartData.volumeData,
                scoreProgression: response.chartData.scoreProgression,
                conditionsAnalysis: response.chartData.conditionsAnalysis,
                trends: response.trends,
                milestones: response.recentMilestones,
                dateRange: response.dateRange
            )

            progressData = viewData
            isLoading = false

        } catch {
            errorMessage = "Failed to load progress data: \(error.localizedDescription)"
            isLoading = false
            print("❌ Progress analytics error: \(error)")
        }
    }

    func refreshData() async {
        guard let currentData = progressData else {
            await fetchProgressData()
            return
        }

        // Use the same query parameters that loaded the current data
        await fetchProgressData()
    }
}