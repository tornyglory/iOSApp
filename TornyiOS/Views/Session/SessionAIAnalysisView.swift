import SwiftUI

struct SessionAIAnalysisView: View {
    let sessionId: Int
    @ObservedObject private var apiService = APIService.shared
    @State private var analysis: SessionAIAnalysis?
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            TornyBackgroundView()

            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Analyzing your session...")
                        .font(TornyFonts.body)
                        .foregroundColor(.tornyTextSecondary)
                }
            } else if let analysis = analysis {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 50))
                                .foregroundColor(.tornyBlue)

                            Text("AI Performance Analysis")
                                .font(TornyFonts.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.tornyTextPrimary)

                            Text("Session #\(sessionId)")
                                .font(TornyFonts.bodySecondary)
                                .foregroundColor(.tornyTextSecondary)
                        }
                        .padding(.top, 20)

                        // Overall Assessment
                        TornyCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .foregroundColor(.tornyBlue)
                                    Text("Overall Assessment")
                                        .font(TornyFonts.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.tornyTextPrimary)
                                }

                                Text(analysis.overallAssessment)
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.horizontal)

                        // Key Insights
                        if !analysis.keyInsights.isEmpty {
                            TornyCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(.yellow)
                                        Text("Key Insights")
                                            .font(TornyFonts.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.tornyTextPrimary)
                                    }

                                    ForEach(Array(analysis.keyInsights.enumerated()), id: \.offset) { _, insight in
                                        HStack(alignment: .top, spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.tornyBlue)
                                                .padding(.top, 4)

                                            Text(insight)
                                                .font(TornyFonts.bodySecondary)
                                                .foregroundColor(.tornyTextSecondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Strengths & Areas for Improvement in HStack
                        HStack(alignment: .top, spacing: 16) {
                            // Strengths
                            if !analysis.strengths.isEmpty {
                                TornyCard {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.tornyGreen)
                                            Text("Strengths")
                                                .font(TornyFonts.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.tornyTextPrimary)
                                        }

                                        ForEach(Array(analysis.strengths.enumerated()), id: \.offset) { _, strength in
                                            HStack(alignment: .top, spacing: 8) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.tornyGreen)
                                                    .padding(.top, 4)

                                                Text(strength)
                                                    .font(TornyFonts.caption)
                                                    .foregroundColor(.tornyTextSecondary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)

                        // Areas for Improvement
                        if !analysis.areasForImprovement.isEmpty {
                            TornyCard {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .foregroundColor(.tornyBlue)
                                        Text("Areas for Improvement")
                                            .font(TornyFonts.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.tornyTextPrimary)
                                    }

                                    ForEach(analysis.areasForImprovement) { area in
                                        ImprovementAreaCard(area: area)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Recommended Drills
                        if !analysis.recommendedDrills.isEmpty {
                            TornyCard {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Image(systemName: "figure.walk")
                                            .foregroundColor(.tornyBlue)
                                        Text("Recommended Drills")
                                            .font(TornyFonts.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.tornyTextPrimary)
                                    }

                                    ForEach(analysis.recommendedDrills) { drill in
                                        DrillCard(drill: drill)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Next Session Focus
                        TornyCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "target")
                                        .foregroundColor(.tornyPurple)
                                    Text("Next Session Focus")
                                        .font(TornyFonts.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.tornyTextPrimary)
                                }

                                Text(analysis.nextSessionFocus)
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("AI Analysis")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadAnalysis()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func loadAnalysis() async {
        isLoading = true

        do {
            let result = try await apiService.getSessionAIAnalysis(sessionId: sessionId)
            await MainActor.run {
                self.analysis = result
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to load AI analysis: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
}
