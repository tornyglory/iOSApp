import SwiftUI
import Foundation

@MainActor
class TrainingSessionViewModel: ObservableObject {
    @Published var currentSession: TrainingSession?
    @Published var sessionShots: [TrainingShot] = []
    @Published var currentShot = ShotData()
    @Published var isLoading = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var sessionStats: SessionStatistics?

    private let apiService = APIService.shared

    struct ShotData {
        var shotType: ShotType = .draw
        var hand: Hand = .forehand
        var length: Length = .short
        var distanceFromJack: DistanceFromJack = .miss
        var notes: String = ""

        mutating func reset() {
            shotType = .draw
            hand = .forehand
            length = .short
            distanceFromJack = .miss
            notes = ""
        }
    }

    var totalShots: Int {
        sessionShots.count
    }

    var successfulShots: Int {
        sessionShots.filter { $0.success ?? false }.count
    }

    var accuracy: Double {
        guard totalShots > 0 else { return 0 }
        return (Double(successfulShots) / Double(totalShots)) * 100
    }

    var shotsByType: [ShotType: Int] {
        Dictionary(grouping: sessionShots, by: { $0.shotType })
            .mapValues { $0.count }
    }

    func startSession(location: String, greenType: String, greenSpeed: Int, rinkNumber: Int?, weather: String?, windConditions: String?) async -> Bool {
        isLoading = true

        let request = CreateSessionRequest(
            location: Location(rawValue: location) ?? .indoor,
            greenType: GreenType(rawValue: greenType) ?? .synthetic,
            greenSpeed: greenSpeed,
            rinkNumber: rinkNumber,
            weather: weather != nil ? Weather(rawValue: weather!) : nil,
            windConditions: windConditions != nil ? WindConditions(rawValue: windConditions!) : nil,
            notes: nil,
            equipment: nil,
            clubId: nil
        )

        do {
            let response = try await apiService.createSession(request)
            currentSession = response.session
            sessionShots.removeAll()
            isLoading = false
            return true
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
            isLoading = false
            return false
        }
    }

    func recordShot() async -> Bool {
        guard let session = currentSession else {
            alertMessage = "No active session"
            showingAlert = true
            return false
        }

        isLoading = true

        let score = calculateScore(for: currentShot.distanceFromJack)

        let request = RecordShotRequest(
            sessionId: session.id,
            shotType: currentShot.shotType,
            hand: currentShot.hand,
            length: currentShot.length,
            distanceFromJack: currentShot.distanceFromJack,
            notes: currentShot.notes.isEmpty ? nil : currentShot.notes
        )

        do {
            let response = try await apiService.recordShot(request)
            sessionShots.append(response.shot)
            currentShot.reset()
            isLoading = false
            return true
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
            isLoading = false
            return false
        }
    }

    func endSession(notes: String? = nil) async -> Bool {
        guard let session = currentSession else {
            alertMessage = "No active session"
            showingAlert = true
            return false
        }

        let sessionStart = session.sessionDate

        isLoading = true

        do {
            let now = Date()
            let duration = Int(now.timeIntervalSince(sessionStart))

            let request = EndSessionRequest(
                endedAt: ISO8601DateFormatter().string(from: now),
                durationSeconds: duration,
                notes: notes
            )
            let response = try await apiService.endSession(session.id, request: request)

            currentSession = response.session

            isLoading = false
            return true
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
            isLoading = false
            return false
        }
    }


    private func calculateScore(for distance: DistanceFromJack) -> Int {
        switch distance {
        case .foot:
            return 2
        case .yard:
            return 1
        case .miss:
            return 0
        }
    }

    func resetSession() {
        currentSession = nil
        sessionShots.removeAll()
        currentShot.reset()
        sessionStats = nil
    }
}