import SwiftUI

struct SessionDetailView: View {
    let session: TrainingSession
    @ObservedObject private var apiService = APIService.shared
    @State private var sessionStats: SessionStatistics?
    @State private var isLoading = false
    @State private var selectedSegment = 0
    @Environment(\dismiss) private var dismiss

    private let segments = ["Overview", "Shots", "Analysis"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                SessionHeaderCard(session: session)
                    .padding(.horizontal)

                // Segment Control
                Picker("View", selection: $selectedSegment) {
                    ForEach(0..<segments.count, id: \.self) { index in
                        Text(segments[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Content based on selected segment
                switch selectedSegment {
                case 0:
                    overviewSection
                case 1:
                    shotsSection
                case 2:
                    analysisSection
                default:
                    EmptyView()
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadSessionDetails()
        }
    }

    private var overviewSection: some View {
        VStack(spacing: 20) {
            // Statistics Grid
            StatsGridCard(session: session, stats: sessionStats)
                .padding(.horizontal)

            // Shot Type Breakdown
            ShotTypeBreakdownCard(session: session)
                .padding(.horizontal)

            // Notes Section
            if let notes = session.notes, !notes.isEmpty {
                NotesCard(notes: notes)
                    .padding(.horizontal)
            }
        }
    }

    private var shotsSection: some View {
        VStack(spacing: 16) {
            if isLoading {
                TornyLoadingView(color: .tornyBlue)
                    .padding(.top, 40)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "target")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No shots recorded")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Individual shot tracking coming soon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
            }
        }
    }

    private var analysisSection: some View {
        VStack(spacing: 20) {
            // Performance Metrics
            PerformanceMetricsCard(session: session, stats: sessionStats)
                .padding(.horizontal)

            // Accuracy Trend
            AccuracyTrendCard(session: session)
                .padding(.horizontal)

            // Recommendations
            RecommendationsCard(session: session, stats: sessionStats)
                .padding(.horizontal)
        }
    }

    private func loadSessionDetails() async {
        isLoading = true
        do {
            // Load session statistics if we don't have them
            if sessionStats == nil {
                // You might need to add an API call to get detailed stats
                // For now, create basic stats from session data
                sessionStats = SessionStatistics(
                    totalShots: session.totalShots ?? 0,
                    totalPoints: session.totalPoints?.description,
                    maxPossiblePoints: nil,
                    averageScore: nil,
                    accuracyPercentage: calculateAccuracy(),
                    drawShots: nil,
                    drawPoints: nil,
                    drawAccuracyPercentage: nil,
                    yardOnShots: nil,
                    yardOnPoints: nil,
                    yardOnAccuracyPercentage: nil,
                    ditchWeightShots: nil,
                    ditchWeightPoints: nil,
                    ditchWeightAccuracyPercentage: nil,
                    driveShots: nil,
                    drivePoints: nil,
                    driveAccuracyPercentage: nil,
                    weightedShots: nil,
                    weightedPoints: nil,
                    weightedAccuracyPercentage: nil,
                    drawBreakdown: nil
                )
            }

            // Individual shot loading will be implemented later

            isLoading = false
        } catch {
            print("Error loading session details: \(error)")
            isLoading = false
        }
    }

    private func calculateAccuracy() -> String {
        guard let totalShots = session.totalShots,
              let successfulShots = session.successfulShots,
              totalShots > 0 else {
            return "0.0"
        }
        let accuracy = (Double(successfulShots) / Double(totalShots)) * 100
        return String(format: "%.1f", accuracy)
    }
}