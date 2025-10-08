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
            print("📊 Fetching progress chart data with query: \(query)")
            let response = try await apiService.getProgressChartData(query: query)
            print("✅ Progress chart data received successfully")
            print("📈 Chart data: \(response.chartData)")
            print("📊 Trends: \(response.trends)")
            print("🎯 Milestones: \(response.recentMilestones)")

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

        } catch let decodingError as DecodingError {
            let errorDetails: String
            switch decodingError {
            case .typeMismatch(let type, let context):
                errorDetails = "Type mismatch: Expected \(type), Context: \(context.debugDescription), Path: \(context.codingPath)"
            case .valueNotFound(let type, let context):
                errorDetails = "Value not found: \(type), Context: \(context.debugDescription), Path: \(context.codingPath)"
            case .keyNotFound(let key, let context):
                errorDetails = "Key not found: \(key), Context: \(context.debugDescription), Path: \(context.codingPath)"
            case .dataCorrupted(let context):
                errorDetails = "Data corrupted: \(context.debugDescription), Path: \(context.codingPath)"
            @unknown default:
                errorDetails = "Unknown decoding error"
            }
            errorMessage = "Decoding error: \(errorDetails)"
            isLoading = false
            print("❌ Progress analytics decoding error: \(errorDetails)")
        } catch {
            errorMessage = "Failed to load progress data: \(error.localizedDescription)"
            isLoading = false
            print("❌ Progress analytics error: \(error)")
            if let urlError = error as? URLError {
                print("🌐 URL Error code: \(urlError.code)")
            }
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