import Foundation
import SwiftUI

@MainActor
class ComparativeAnalyticsViewModel: ObservableObject {
    @Published var comparativeData: ComparativeAnalyticsViewData?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    func fetchComparativeData(query: ComparativeAnalyticsQuery = ComparativeAnalyticsQuery()) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.getComparativeAnalytics(query: query)

            let viewData = ComparativeAnalyticsViewData(
                radarChart: response.radarChart,
                heatmapData: response.heatmapData,
                lengthMatrix: response.lengthMatrix,
                timePerformance: response.timePerformance,
                sequenceAnalysis: response.sequenceAnalysis,
                insights: response.insights
            )

            comparativeData = viewData
            isLoading = false

        } catch {
            errorMessage = "Failed to load comparative data: \(error.localizedDescription)"
            isLoading = false
            print("❌ Comparative analytics error: \(error)")
        }
    }

    func refreshData() async {
        await fetchComparativeData()
    }
}