import Foundation
import Combine

class AnalyticsViewModel: ObservableObject {
    @Published var analytics: AnalyticsResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared

    func fetchAnalytics() {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            self.errorMessage = "Authentication required"
            return
        }

        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "https://ieg3lhlyy0.execute-api.ap-southeast-2.amazonaws.com/Prod/api/training/stats") else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: AnalyticsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        print("Analytics fetch error: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.analytics = response
                }
            )
            .store(in: &cancellables)
    }

    // Helper computed properties
    var hasData: Bool {
        analytics != nil
    }

    var totalSessionsText: String {
        guard let analytics = analytics else { return "0" }
        return "\(analytics.totalSessions)"
    }

    var totalShotsText: String {
        guard let analytics = analytics else { return "0" }
        return "\(analytics.totalShots)"
    }

    var overallAccuracyDouble: Double {
        guard let analytics = analytics else { return 0 }
        return Double(analytics.overallAccuracy) ?? 0
    }

    var drawAccuracyDouble: Double {
        guard let analytics = analytics else { return 0 }
        return Double(analytics.drawAccuracy) ?? 0
    }

    var weightedAccuracyDouble: Double {
        guard let analytics = analytics else { return 0 }
        return Double(analytics.weightedAccuracy) ?? 0
    }
}