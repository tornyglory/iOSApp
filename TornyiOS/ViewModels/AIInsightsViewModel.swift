import Foundation
import Combine

@MainActor
class AIInsightsViewModel: ObservableObject {
    @Published var insights: AIInsightsResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private var apiService: APIService { APIService.shared }

    func fetchInsights(period: String = "all") {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await apiService.getOverallAIAnalysis(period: period)
                await MainActor.run {
                    self.insights = result
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    print("AI Insights fetch error: \(error)")
                }
            }
        }
    }

    var hasData: Bool {
        insights != nil
    }
}
