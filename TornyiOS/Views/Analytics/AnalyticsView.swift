import SwiftUI
import Foundation

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var showDetailedAnalytics = false
    @State private var showProgressCharts = false
    @State private var showComparativeAnalysis = false
    @State private var showAIInsights = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()

            if viewModel.isLoading {
                VStack(spacing: 12) {
                    TornyLoadingView(color: .tornyBlue)
                    Text("Loading analytics...")
                        .font(TornyFonts.body)
                        .foregroundColor(.tornyTextSecondary)
                }
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("Failed to load analytics")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        viewModel.fetchAnalytics()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if let analytics = viewModel.analytics {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header section
                        VStack(spacing: 16) {
                            Text("Analytics Dashboard")
                                .font(TornyFonts.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.tornyTextPrimary)

                            Text("Track your performance and progress")
                                .font(TornyFonts.body)
                                .foregroundColor(.tornyTextSecondary)
                        }
                        .padding(.top, 20)

                        // Quick stats overview
                        TornyCard {
                            VStack(spacing: 16) {
                                Text("Performance Overview")
                                    .font(TornyFonts.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.tornyTextPrimary)

                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    QuickStatItem(
                                        title: "Overall Accuracy",
                                        value: String(format: "%.1f%%", pointsBasedAccuracy(analytics: analytics)),
                                        icon: "target",
                                        color: .tornyBlue
                                    )

                                    QuickStatItem(
                                        title: "Total Sessions",
                                        value: "\(analytics.totalSessions)",
                                        icon: "calendar",
                                        color: .tornyGreen
                                    )

                                    QuickStatItem(
                                        title: "Total Shots",
                                        value: "\(analytics.totalShots)",
                                        icon: "circle.grid.cross",
                                        color: .tornyPurple
                                    )
                                }
                            }
                        }

                        // Analytics action cards
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {

                            // Torny AI - Overall Analysis
                            TornyAIActionCard(
                                title: "Overall Analysis",
                                subtitle: "AI-powered insights"
                            ) {
                                showAIInsights = true
                            }

                            // Progress Charts Button
                            DashboardActionCard(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Progress Charts",
                                subtitle: "Track accuracy trends over time",
                                color: .tornyBlue
                            ) {
                                showProgressCharts = true
                            }

                            // Comparative Analysis Button
                            DashboardActionCard(
                                icon: "chart.bar.doc.horizontal",
                                title: "Comparative Analysis",
                                subtitle: "Multi-dimensional performance",
                                color: .tornyGreen
                            ) {
                                showComparativeAnalysis = true
                            }

                            // Shot Analysis Button
                            DashboardActionCard(
                                icon: "target",
                                title: "Shot Analysis",
                                subtitle: "Detailed lifetime shot breakdown",
                                color: .tornyPurple
                            ) {
                                showDetailedAnalytics = true
                            }
                        }

                        // Recent summary cards
                        VStack(spacing: 16) {
                            OverviewCard(analytics: analytics)
                            AccuracyCard(analytics: analytics)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            } else {
                // Initial loading state
                TornyLoadingView(color: .tornyBlue)
                    .onAppear {
                        viewModel.fetchAnalytics()
                    }
            }
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.tornyBlue)
                        Text("Back")
                            .font(.body)
                            .foregroundColor(.tornyBlue)
                    }
                }
            }
        }
        .onAppear {
            if viewModel.analytics == nil && !viewModel.isLoading {
                viewModel.fetchAnalytics()
            }
        }
        .sheet(isPresented: $showDetailedAnalytics) {
            DetailedAnalyticsView()
        }
        .sheet(isPresented: $showProgressCharts) {
            ProgressChartsView()
        }
        .sheet(isPresented: $showComparativeAnalysis) {
            ComparativeAnalysisView()
        }
        .sheet(isPresented: $showAIInsights) {
            AIInsightsView()
        }
        }
    }

    // MARK: - Helper Functions

    private func pointsBasedAccuracy(analytics: AnalyticsResponse) -> Double {
        guard analytics.maxPossiblePoints > 0 else { return 0.0 }

        // Parse totalPoints from String to Int
        let totalPointsEarned = Int(analytics.totalPoints) ?? 0

        // Calculate accuracy as: (Points Earned / Maximum Possible Points) × 100
        let accuracy = (Double(totalPointsEarned) / Double(analytics.maxPossiblePoints)) * 100.0

        return accuracy
    }
}

// MARK: - Quick Stat Item Component
struct QuickStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(TornyFonts.title3)
                .fontWeight(.bold)
                .foregroundColor(.tornyTextPrimary)

            Text(title)
                .font(TornyFonts.bodySecondary)
                .foregroundColor(.tornyTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Torny AI Action Card

struct TornyAIActionCard: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple.opacity(0.8),
                                    Color.blue.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    Image(systemName: "sparkles")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 4) {
                    Text(title)
                        .font(TornyFonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.tornyTextPrimary)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(TornyFonts.bodySecondary)
                        .foregroundColor(.tornyTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.purple.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}
