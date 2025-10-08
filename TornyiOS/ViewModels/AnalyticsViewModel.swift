import Foundation
import Combine

class AnalyticsViewModel: ObservableObject {
    @Published var analytics: AnalyticsResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared

    func fetchAnalytics() {
        guard let token = apiService.authToken else {
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
            .tryMap { data, response -> Data in
                // Log the raw response
                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 Analytics Response Status: \(httpResponse.statusCode)")
                }
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 Analytics Response Body: \(jsonString)")
                }
                return data
            }
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
                        print("❌ Analytics fetch error: \(error)")
                        if let decodingError = error as? DecodingError {
                            print("❌ Decoding error details: \(decodingError)")
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    self?.analytics = response
                    print("✅ Analytics loaded successfully")
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
        return pointsBasedAccuracy(analytics: analytics)
    }

    var drawAccuracyDouble: Double {
        guard let analytics = analytics else { return 0 }
        return Double(analytics.drawAccuracy) ?? 0
    }

    var weightedAccuracyDouble: Double {
        guard let analytics = analytics else { return 0 }
        return Double(analytics.weightedAccuracy) ?? 0
    }

    // MARK: - Points-Based Calculations

    private func pointsBasedAccuracy(analytics: AnalyticsResponse) -> Double {
        guard analytics.maxPossiblePoints > 0 else { return 0.0 }

        // Parse totalPoints from String to Int
        let totalPointsEarned = Int(analytics.totalPoints) ?? 0

        // Calculate accuracy as: (Points Earned / Maximum Possible Points) × 100
        let accuracy = (Double(totalPointsEarned) / Double(analytics.maxPossiblePoints)) * 100.0

        return accuracy
    }
}