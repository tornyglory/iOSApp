import Foundation
import Combine

@MainActor
class ShotAnalysisViewModel: ObservableObject {
    @Published var analytics: ComparativeAnalyticsResponse?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedPeriod = "all"

    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()

    func loadAnalytics() {
        isLoading = true
        error = nil

        Task {
            do {
                let query = ComparativeAnalyticsQuery(
                    period: selectedPeriod,
                    sport: "lawn_bowls"
                )

                let response = try await apiService.getComparativeAnalytics(query: query)

                await MainActor.run {
                    self.analytics = response
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
                print("❌ Failed to load shot analysis: \(error)")
            }
        }
    }
}