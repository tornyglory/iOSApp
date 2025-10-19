import SwiftUI
import ConfettiSwiftUI

struct ProgramCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    let stats: ProgramSessionStats
    let programTitle: String
    let sessionId: Int
    var onComplete: (() -> Void)? = nil

    @State private var confettiCounter = 0
    @State private var showShareSheet = false
    @State private var sessionNotes = ""
    @State private var isEndingSession = false

    var body: some View {
        NavigationView {
            ZStack {
                TornyGradients.skyGradient
                    .ignoresSafeArea()

                TornyCloudView()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Celebration Header
                        VStack(spacing: 16) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.yellow)
                                .padding(.top, 40)

                            Text("Program Complete!")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.tornyTextPrimary)
                                .multilineTextAlignment(.center)

                            Text(programTitle)
                                .font(.title3)
                                .foregroundColor(.tornyTextSecondary)
                                .multilineTextAlignment(.center)
                        }

                        // Final Score Card
                        VStack(spacing: 20) {
                            Text("Final Score")
                                .font(.headline)
                                .foregroundColor(.tornyTextSecondary)

                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(stats.totalPoints)")
                                    .font(.system(size: 64, weight: .bold))
                                    .foregroundColor(scoreColor)
                                Text("/ \(stats.maxPossiblePoints)")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.tornyTextSecondary)
                            }

                            Text(scoreMessage)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(scoreColor)
                        }
                        .padding(.vertical, 32)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(radius: 4)
                        .padding(.horizontal)

                        // Stats Breakdown
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Performance Breakdown")
                                .font(.headline)
                                .foregroundColor(.tornyTextPrimary)

                            // Overall stats
                            HStack(spacing: 16) {
                                CompletionStatItem(
                                    title: "Accuracy",
                                    value: String(format: "%.0f%%", stats.accuracyPercentage),
                                    icon: "target",
                                    color: .blue
                                )

                                CompletionStatItem(
                                    title: "Average",
                                    value: String(format: "%.1f", stats.averageScore),
                                    icon: "chart.bar.fill",
                                    color: .green
                                )

                                CompletionStatItem(
                                    title: "Total Shots",
                                    value: "\(stats.totalShots)",
                                    icon: "circle.grid.3x3.fill",
                                    color: .orange
                                )
                            }

                            // Shot Type Breakdown
                            Divider()
                                .padding(.vertical, 8)

                            Text("By Shot Type")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.tornyTextSecondary)

                            VStack(spacing: 12) {
                                if stats.drawShots > 0 {
                                    CompletionShotTypeRow(
                                        shotType: "Draw",
                                        shots: stats.drawShots,
                                        points: stats.drawPoints,
                                        maxPoints: stats.drawShots * 2,
                                        accuracy: stats.drawAccuracyPercentage ?? 0,
                                        color: .blue
                                    )
                                }

                                if stats.yardOnShots > 0 {
                                    CompletionShotTypeRow(
                                        shotType: "Yard On",
                                        shots: stats.yardOnShots,
                                        points: stats.yardOnPoints,
                                        maxPoints: stats.yardOnShots * 2,
                                        accuracy: stats.yardOnAccuracyPercentage ?? 0,
                                        color: .green
                                    )
                                }

                                if stats.ditchWeightShots > 0 {
                                    CompletionShotTypeRow(
                                        shotType: "Ditch Weight",
                                        shots: stats.ditchWeightShots,
                                        points: stats.ditchWeightPoints,
                                        maxPoints: stats.ditchWeightShots * 2,
                                        accuracy: stats.ditchWeightAccuracyPercentage ?? 0,
                                        color: .orange
                                    )
                                }

                                if stats.driveShots > 0 {
                                    CompletionShotTypeRow(
                                        shotType: "Drive",
                                        shots: stats.driveShots,
                                        points: stats.drivePoints,
                                        maxPoints: stats.driveShots * 2,
                                        accuracy: stats.driveAccuracyPercentage ?? 0,
                                        color: .red
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        .padding(.horizontal)

                        // Session Notes
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Session Notes (Optional)")
                                .font(.headline)
                                .foregroundColor(.tornyTextPrimary)

                            TextField("Add notes about your session...", text: $sessionNotes, axis: .vertical)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .lineLimit(4...8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)

                        // Action Buttons
                        VStack(spacing: 12) {
                            // Share Button
                            Button(action: {
                                showShareSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Results")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }

                            // End Session Button
                            Button(action: endSession) {
                                HStack {
                                    if isEndingSession {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text("Ending Session...")
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("End Session")
                                    }
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.orange, .red]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            .disabled(isEndingSession)
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 100)
                    }
                    .padding(.bottom, 20)
                }
                .confettiCannon(counter: $confettiCounter, num: 50, radius: 400)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                        // Call completion handler to dismiss parent views
                        onComplete?()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            // Trigger confetti after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                confettiCounter += 1
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText])
        }
    }

    // MARK: - Computed Properties

    private var scoreColor: Color {
        let percentage = Double(stats.totalPoints) / Double(stats.maxPossiblePoints)
        if percentage >= 0.8 {
            return .green
        } else if percentage >= 0.6 {
            return .blue
        } else if percentage >= 0.4 {
            return .orange
        } else {
            return .red
        }
    }

    private var scoreMessage: String {
        let percentage = Double(stats.totalPoints) / Double(stats.maxPossiblePoints)
        if percentage >= 0.9 {
            return "Outstanding! 🏆"
        } else if percentage >= 0.8 {
            return "Excellent Work! 🌟"
        } else if percentage >= 0.7 {
            return "Great Job! 👏"
        } else if percentage >= 0.6 {
            return "Good Effort! 💪"
        } else if percentage >= 0.5 {
            return "Nice Try! 👍"
        } else {
            return "Keep Practising! 🎯"
        }
    }

    private var shareText: String {
        """
        I just completed \(programTitle) on Torny! 🎯

        Score: \(stats.totalPoints)/\(stats.maxPossiblePoints)
        Accuracy: \(String(format: "%.0f%%", stats.accuracyPercentage))
        Average: \(String(format: "%.1f", stats.averageScore)) points per shot

        #Torny #LawnBowls #Training
        """
    }

    // MARK: - Actions

    private func endSession() {
        // For training programs, the session is already complete when all shots are finished
        // We just need to save any notes and dismiss the view
        isEndingSession = true

        // If there are notes, we could save them here via an API call
        // For now, just dismiss with animation

        // Trigger confetti celebration
        confettiCounter += 1

        // Dismiss after a short delay to show confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isEndingSession = false
            dismiss()
            // Call completion handler to dismiss parent views
            onComplete?()
        }
    }
}

// MARK: - Supporting Views

struct CompletionStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.tornyTextPrimary)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CompletionShotTypeRow: View {
    let shotType: String
    let shots: Int
    let points: Int
    let maxPoints: Int
    let accuracy: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)

                Text(shotType)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.tornyTextPrimary)

                Spacer()

                Text("\(points)/\(maxPoints)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * (Double(points) / Double(maxPoints)), height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(shots) shots")
                    .font(.caption)
                    .foregroundColor(.tornyTextSecondary)

                Spacer()

                Text(String(format: "%.0f%% accuracy", accuracy))
                    .font(.caption)
                    .foregroundColor(.tornyTextSecondary)
            }
        }
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
