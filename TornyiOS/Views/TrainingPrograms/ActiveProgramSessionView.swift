import SwiftUI

struct ActiveProgramSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ActiveProgramViewModel
    @State private var showToast = false
    @State private var toastMessage = ""

    init(sessionInfo: SessionInfo, currentShot: ProgramShot, programTitle: String, sessionMetadata: ProgramSessionMetadata) {
        _viewModel = StateObject(wrappedValue: ActiveProgramViewModel(
            sessionInfo: sessionInfo,
            currentShot: currentShot,
            programTitle: programTitle,
            sessionMetadata: sessionMetadata
        ))
    }

    var body: some View {
        ZStack {
            TornyGradients.skyGradient
                .ignoresSafeArea()

            TornyCloudView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress Bar
                ProgressBar(current: viewModel.sessionInfo.currentShotIndex, total: viewModel.sessionInfo.totalShots)
                    .padding(.horizontal)
                    .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 20) {
                        // Current Shot Card
                        VStack(spacing: 16) {
                            // Shot number indicator with gradient background
                            Text("Shot \(viewModel.sessionInfo.currentShotIndex)/\(viewModel.sessionInfo.totalShots)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.orange, .red]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)

                            // Shot type icon with gradient background
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [shotTypeColor.opacity(0.2), shotTypeColor.opacity(0.1)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 140, height: 140)

                                Image(systemName: viewModel.currentShot.shotType.icon)
                                    .font(.system(size: 70, weight: .semibold))
                                    .foregroundColor(shotTypeColor)
                            }
                            .padding(.vertical, 8)

                            // Shot details
                            VStack(spacing: 8) {
                                Text(viewModel.currentShot.shotType.displayName)
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.tornyTextPrimary)

                                HStack(spacing: 16) {
                                    // Hand
                                    HStack(spacing: 6) {
                                        Image(systemName: viewModel.currentShot.hand.icon)
                                            .font(.system(size: 18))
                                        Text(viewModel.currentShot.hand.displayName)
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                    .foregroundColor(.tornyTextSecondary)

                                    Text("•")
                                        .foregroundColor(.secondary)

                                    // Length
                                    Text(viewModel.currentShot.length.displayName)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.tornyTextSecondary)
                                }
                            }

                            // Notes (if any)
                            if let notes = viewModel.currentShot.notes {
                                Text(notes)
                                    .font(.body)
                                    .foregroundColor(.tornyTextSecondary)
                                    .multilineTextAlignment(.center)
                                    .italic()
                                    .padding(.horizontal, 24)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 32)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.orange.opacity(0.3), .red.opacity(0.3)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .padding(.horizontal)
                        .padding(.top, 20)

                        // Recording Buttons
                        VStack(spacing: 16) {
                            Text("Record your shot")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.tornyTextPrimary)

                            HStack(spacing: 12) {
                                // FOOT button (2 points)
                                Button(action: {
                                    viewModel.recordShot(distance: "foot")
                                    showToastMessage("Next Shot!")
                                }) {
                                    VStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.green.opacity(0.2), Color.green.opacity(0.05)]),
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                                .frame(width: 60, height: 60)

                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 42))
                                                .foregroundColor(.green)
                                        }

                                        Text("FOOT")
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(.tornyTextPrimary)

                                        Text("2 points")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.green)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.green.opacity(0.6), Color.green.opacity(0.3)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .disabled(viewModel.isRecording)
                                .opacity(viewModel.isRecording ? 0.5 : 1.0)

                                // YARD button (1 point)
                                Button(action: {
                                    viewModel.recordShot(distance: "yard")
                                    showToastMessage("Next Shot!")
                                }) {
                                    VStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.05)]),
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                                .frame(width: 60, height: 60)

                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 42))
                                                .foregroundColor(.orange)
                                        }

                                        Text("YARD")
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(.tornyTextPrimary)

                                        Text("1 point")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.orange)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.orange.opacity(0.6), Color.orange.opacity(0.3)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .disabled(viewModel.isRecording)
                                .opacity(viewModel.isRecording ? 0.5 : 1.0)

                                // MISS button (0 points)
                                Button(action: {
                                    viewModel.recordShot(distance: "miss")
                                    showToastMessage("Next Shot!")
                                }) {
                                    VStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.red.opacity(0.2), Color.red.opacity(0.05)]),
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                                .frame(width: 60, height: 60)

                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 42))
                                                .foregroundColor(.red)
                                        }

                                        Text("MISS")
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(.tornyTextPrimary)

                                        Text("0 points")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.red)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.red.opacity(0.6), Color.red.opacity(0.3)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .disabled(viewModel.isRecording)
                                .opacity(viewModel.isRecording ? 0.5 : 1.0)
                            }
                        }
                        .padding(.horizontal)

                        // Session Info
                        SessionInfoCard(metadata: viewModel.sessionMetadata)
                            .padding(.horizontal)

                        // Live Stats
                        if let stats = viewModel.sessionStats {
                            LiveStatsCard(stats: stats)
                                .padding(.horizontal)
                        }

                        Spacer(minLength: 100)
                    }
                }
            }

            // Toast Overlay
            if showToast {
                VStack {
                    Spacer()

                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))

                        Text(toastMessage)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.green)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showToast)
                .zIndex(999)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.showingExitAlert = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.tornyBlue)
                        Text("Exit")
                            .font(.body)
                            .foregroundColor(.tornyBlue)
                    }
                }
            }

            ToolbarItem(placement: .principal) {
                Text(viewModel.programTitle)
                    .font(.headline)
                    .foregroundColor(.tornyTextPrimary)
            }
        }
        .alert("Exit Session?", isPresented: $viewModel.showingExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure you want to exit? Your progress will be lost.")
        }
        .alert("Error", isPresented: $viewModel.showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .fullScreenCover(item: $viewModel.completionResponse) { response in
            ProgramCompletionView(
                stats: response.sessionStats,
                programTitle: viewModel.programTitle,
                sessionId: viewModel.sessionInfo.id,
                onComplete: {
                    // Dismiss the active session view to return to dashboard
                    dismiss()
                }
            )
        }
    }

    private var shotTypeColor: Color {
        switch viewModel.currentShot.shotType {
        case .draw: return .blue
        case .yardOn: return .green
        case .ditchWeight: return .orange
        case .drive: return .red
        }
    }

    private func showToastMessage(_ message: String) {
        toastMessage = message
        withAnimation {
            showToast = true
        }

        // Auto-hide after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showToast = false
            }
        }
    }
}

// MARK: - Progress Bar

struct ProgressBar: View {
    let current: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background with subtle gradient
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.1)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 16)

                    // Progress with orange-red gradient
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 16)
                        .shadow(color: Color.orange.opacity(0.4), radius: 4, x: 0, y: 2)
                }
            }
            .frame(height: 16)
        }
    }
}

// MARK: - Session Info Card

struct SessionInfoCard: View {
    let metadata: ProgramSessionMetadata

    private var elapsedTime: String {
        let elapsed = Date().timeIntervalSince(metadata.startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Info")
                .font(.headline)
                .foregroundColor(.tornyTextPrimary)

            VStack(spacing: 8) {
                // Time
                SessionInfoRow(icon: "clock.fill", label: "Duration", value: elapsedTime, color: .blue)

                // Club
                if let club = metadata.club {
                    SessionInfoRow(icon: "building.2.fill", label: "Club", value: club.name, color: .green)
                }

                // Equipment
                SessionInfoRow(icon: "circle.fill", label: "Bowls", value: "\(metadata.bowls) (Size \(metadata.bowlSize))", color: .purple)

                // Location
                SessionInfoRow(icon: metadata.location == "outdoor" ? "sun.max.fill" : "house.fill", label: "Location", value: metadata.location.capitalized, color: .orange)

                // Green
                SessionInfoRow(icon: "leaf.fill", label: "Green", value: "\(metadata.greenType.capitalized) - \(metadata.greenSpeed) sec", color: .green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct SessionInfoRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 20)

            Text(label)
                .font(.caption)
                .foregroundColor(.tornyTextSecondary)
                .frame(width: 70, alignment: .leading)

            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.tornyTextPrimary)

            Spacer()
        }
    }
}

// MARK: - Live Stats Card

struct LiveStatsCard: View {
    let stats: ProgramSessionStats

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Session Stats")
                .font(.headline)
                .foregroundColor(.tornyTextPrimary)

            // Overall stats
            HStack(spacing: 16) {
                LiveStatItem(
                    title: "Score",
                    value: "\(stats.totalPoints)/\(stats.maxPossiblePoints)",
                    icon: "star.fill",
                    color: .yellow
                )

                LiveStatItem(
                    title: "Accuracy",
                    value: String(format: "%.0f%%", stats.accuracyPercentage),
                    icon: "target",
                    color: .blue
                )

                LiveStatItem(
                    title: "Average",
                    value: String(format: "%.1f", stats.averageScore),
                    icon: "chart.bar.fill",
                    color: .green
                )
            }

            // Shot type breakdown
            if stats.totalShots > 0 {
                Divider()
                    .padding(.vertical, 4)

                VStack(spacing: 8) {
                    Text("Breakdown by Type")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.tornyTextSecondary)

                    if stats.drawShots > 0 {
                        LiveShotTypeStatRow(
                            shotType: "Draw",
                            shots: stats.drawShots,
                            points: stats.drawPoints,
                            accuracy: stats.drawAccuracyPercentage ?? 0,
                            color: .blue
                        )
                    }

                    if stats.yardOnShots > 0 {
                        LiveShotTypeStatRow(
                            shotType: "Yard On",
                            shots: stats.yardOnShots,
                            points: stats.yardOnPoints,
                            accuracy: stats.yardOnAccuracyPercentage ?? 0,
                            color: .green
                        )
                    }

                    if stats.ditchWeightShots > 0 {
                        LiveShotTypeStatRow(
                            shotType: "Ditch Weight",
                            shots: stats.ditchWeightShots,
                            points: stats.ditchWeightPoints,
                            accuracy: stats.ditchWeightAccuracyPercentage ?? 0,
                            color: .orange
                        )
                    }

                    if stats.driveShots > 0 {
                        LiveShotTypeStatRow(
                            shotType: "Drive",
                            shots: stats.driveShots,
                            points: stats.drivePoints,
                            accuracy: stats.driveAccuracyPercentage ?? 0,
                            color: .red
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct LiveStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.tornyTextPrimary)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LiveShotTypeStatRow: View {
    let shotType: String
    let shots: Int
    let points: Int
    let accuracy: Double
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(shotType)
                .font(.caption)
                .foregroundColor(.tornyTextSecondary)

            Spacer()

            Text("\(shots) shots")
                .font(.caption)
                .foregroundColor(.tornyTextSecondary)

            Text("•")
                .foregroundColor(.secondary)
                .font(.caption)

            Text("\(points) pts")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.tornyTextPrimary)

            Text("•")
                .foregroundColor(.secondary)
                .font(.caption)

            Text(String(format: "%.0f%%", accuracy))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - View Model

class ActiveProgramViewModel: ObservableObject {
    @Published var sessionInfo: SessionInfo
    @Published var currentShot: ProgramShot
    @Published var sessionStats: ProgramSessionStats?
    @Published var isRecording = false
    @Published var showingExitAlert = false
    @Published var showingErrorAlert = false
    @Published var errorMessage = ""
    @Published var completionResponse: RecordProgramShotResponse?

    let programTitle: String
    let sessionMetadata: ProgramSessionMetadata
    private let apiService = APIService.shared

    init(sessionInfo: SessionInfo, currentShot: ProgramShot, programTitle: String, sessionMetadata: ProgramSessionMetadata) {
        self.sessionInfo = sessionInfo
        self.currentShot = currentShot
        self.programTitle = programTitle
        self.sessionMetadata = sessionMetadata
    }

    func recordShot(distance: String) {
        isRecording = true

        let request = RecordProgramShotRequest(
            distanceFromJack: distance,
            notes: nil
        )

        Task {
            do {
                let response = try await apiService.recordProgramShot(
                    sessionId: sessionInfo.id,
                    request: request
                )

                await MainActor.run {
                    isRecording = false

                    // Update stats
                    sessionStats = response.sessionStats

                    // Check if completed
                    if response.progress.completed {
                        // Show completion screen
                        completionResponse = response
                    } else if let nextShot = response.nextShot {
                        // Update to next shot
                        currentShot = nextShot
                        // Use the next shot's sequence order for accurate progress display
                        sessionInfo = SessionInfo(
                            id: sessionInfo.id,
                            programId: sessionInfo.programId,
                            programTitle: sessionInfo.programTitle,
                            currentShotIndex: nextShot.sequenceOrder,
                            totalShots: response.progress.totalShots,
                            isActive: true
                        )
                    }
                }
            } catch {
                await MainActor.run {
                    isRecording = false
                    errorMessage = "Failed to record shot: \(error.localizedDescription)"
                    showingErrorAlert = true
                }
            }
        }
    }
}
