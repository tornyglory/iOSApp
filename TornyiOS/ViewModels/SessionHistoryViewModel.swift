import SwiftUI
import Foundation

@MainActor
class SessionHistoryViewModel: ObservableObject {
    @Published var sessions: [TrainingSession] = []
    @Published var isLoading = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var hasMoreSessions = true
    @Published var currentOffset = 0

    private let pageSize = 20
    private var apiService: APIService { APIService.shared }

    func loadSessions(refresh: Bool = false) async {
        if refresh {
            currentOffset = 0
            sessions.removeAll()
            hasMoreSessions = true
        }

        isLoading = true

        do {
            let response = try await apiService.getSessions(
                limit: pageSize,
                offset: currentOffset
            )

            if refresh {
                sessions = response.sessions
            } else {
                sessions.append(contentsOf: response.sessions)
            }

            currentOffset += response.sessions.count
            hasMoreSessions = response.pagination.hasMore
            isLoading = false
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
            isLoading = false
        }
    }

    func loadMoreSessions() {
        guard !isLoading && hasMoreSessions else { return }

        Task {
            await loadSessions()
        }
    }

    func deleteSession(_ sessionId: Int) async -> Bool {
        do {
            _ = try await apiService.deleteSession(sessionId)
            sessions.removeAll { $0.id == sessionId }
            return true
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
            return false
        }
    }
}

@MainActor
class SessionDetailViewModel: ObservableObject {
    @Published var sessionDetail: SessionDetailResponse?
    @Published var isLoading = true
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var showingDeleteAlert = false

    private var apiService: APIService { APIService.shared }
    let session: TrainingSession

    init(session: TrainingSession) {
        self.session = session
    }

    func loadSessionDetail() async {
        isLoading = true

        do {
            let detail = try await apiService.getSessionDetails(session.id)
            sessionDetail = detail
            isLoading = false
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
            isLoading = false
        }
    }

    func deleteSession() async -> Bool {
        do {
            _ = try await apiService.deleteSession(session.id)
            return true
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
            return false
        }
    }
}