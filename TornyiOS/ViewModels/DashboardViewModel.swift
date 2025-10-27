import SwiftUI
import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var recentSessions: [TrainingSession] = []
    @Published var stats = UserStatistics()
    @Published var isLoading = false
    @Published var showingProfileSetup = false
    @Published var showingTrainingSession = false
    @Published var showingHistory = false
    @Published var showingAnalytics = false

    private var apiService: APIService { APIService.shared }

    struct UserStatistics {
        var totalSessions: Int = 0
        var totalShots: Int = 0
        var overallAccuracy: Double = 0
        var thisWeekSessions: Int = 0
        var thisMonthSessions: Int = 0
        var favoriteLocation: String = "Unknown"
        var averageSessionDuration: Int = 0
    }

    init() {
        currentUser = apiService.currentUser
    }

    func loadDashboard() async {
        isLoading = true

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadUserProfile() }
            group.addTask { await self.loadRecentSessions() }
            group.addTask { await self.loadUserStatistics() }
        }

        isLoading = false
    }

    private func loadUserProfile() async {
        guard let userId = apiService.currentUser?.id else { return }

        do {
            let user = try await apiService.getUserProfile(userId)
            currentUser = user
            apiService.currentUser = user

            if user.profileCompleted != 1 {
                showingProfileSetup = true
            }
        } catch {
            print("Failed to load user profile: \(error)")
        }
    }

    private func loadRecentSessions() async {
        do {
            let response = try await apiService.getSessions(limit: 5, offset: 0)
            recentSessions = response.sessions
        } catch {
            print("Failed to load recent sessions: \(error)")
        }
    }

    private func loadUserStatistics() async {
        do {
            let response = try await apiService.getSessions(limit: 100, offset: 0)
            calculateStatistics(from: response.sessions)
        } catch {
            print("Failed to load statistics: \(error)")
        }
    }

    private func calculateStatistics(from sessions: [TrainingSession]) {
        stats.totalSessions = sessions.count

        stats.totalShots = sessions.reduce(0) { sum, session in
            sum + (session.totalShots ?? 0)
        }

        let accuracies = sessions.compactMap { $0.overallAccuracy }
        if !accuracies.isEmpty {
            stats.overallAccuracy = accuracies.reduce(0, +) / Double(accuracies.count)
        }

        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!

        stats.thisWeekSessions = sessions.filter { $0.sessionDate > weekAgo }.count
        stats.thisMonthSessions = sessions.filter { $0.sessionDate > monthAgo }.count

        let locations = sessions.compactMap { $0.location }
        let locationCounts = Dictionary(grouping: locations, by: { $0 })
            .mapValues { $0.count }
        stats.favoriteLocation = locationCounts.max(by: { $0.value < $1.value })?.key.rawValue.capitalized ?? "Unknown"

        let durations = sessions.compactMap { $0.durationSeconds }
        if !durations.isEmpty {
            stats.averageSessionDuration = durations.reduce(0, +) / durations.count
        }
    }

    func logout() {
        apiService.logout()
        currentUser = nil
        recentSessions.removeAll()
        stats = UserStatistics()
    }
}