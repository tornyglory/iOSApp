import Foundation
import Combine

class AIInsightsViewModel: ObservableObject {
    @Published var insights: AIInsightsResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared

    func fetchInsights() {
        guard let token = apiService.authToken else {
            self.errorMessage = "Authentication required"
            return
        }

        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "https://ieg3lhlyy0.execute-api.ap-southeast-2.amazonaws.com/Prod/api/training/analyze/overall") else {
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
            .decode(type: AIInsightsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        print("AI Insights fetch error: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.insights = response
                }
            )
            .store(in: &cancellables)
    }

    var hasData: Bool {
        insights != nil
    }
}
