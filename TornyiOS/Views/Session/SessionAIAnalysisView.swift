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
            // Blue gradient background with clouds
            TornyGradients.skyGradient
                .ignoresSafeArea()

            // Animated clouds
            TornyCloudView()

            if isLoading {
                VStack(spacing: 20) {
                    Image(systemName: "brain")
                        .font(.system(size: 60))
                        .foregroundColor(.tornyBlue)

                    ProgressView()
                        .scaleEffect(1.5)

                    Text("TornyAI is analyzing your session...")
                        .font(TornyFonts.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.tornyTextPrimary)

                    Text("Identifying weaknesses and finding the perfect\nprogram to help you improve.")
                        .font(TornyFonts.body)
                        .foregroundColor(.tornyTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else if let analysis = analysis {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "target")
                                .font(.system(size: 50))
                                .foregroundColor(.tornyBlue)

                            Text("Your Improvement Plan")
                                .font(TornyFonts.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.tornyTextPrimary)

                            Text("Based on your performance, here's what you need\nto work on and the program that will help you\nimprove the most.")
                                .font(TornyFonts.bodySecondary)
                                .foregroundColor(.tornyTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Divider()
                                .padding(.horizontal, 40)
                                .padding(.top, 8)
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

                        // Recommended Training Programs
                        if let programs = analysis.recommendedPrograms, !programs.isEmpty {
                            VStack(spacing: 16) {
                                // Primary Program Recommendation
                                if let primaryRec = analysis.primaryProgramRecommendation {
                                    TornyCard {
                                        VStack(alignment: .leading, spacing: 12) {
                                            HStack {
                                                Image(systemName: "star.circle.fill")
                                                    .foregroundColor(.tornyBlue)
                                                Text("Your Coach Says")
                                                    .font(TornyFonts.title3)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.tornyTextPrimary)
                                            }

                                            Text(primaryRec)
                                                .font(TornyFonts.body)
                                                .foregroundColor(.tornyTextSecondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    .padding(.horizontal)
                                }

                                // Program Cards
                                ForEach(programs) { program in
                                    RecommendedProgramCard(program: program)
                                        .padding(.horizontal)
                                }
                            }
                        }

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

// MARK: - Recommended Program Card

struct RecommendedProgramCard: View {
    let program: RecommendedProgram
    @State private var navigateToProgram = false
    @State private var loadedProgram: TrainingProgram?
    @State private var isLoadingProgram = false
    @State private var showError = false
    @State private var errorMessage = ""
    @ObservedObject private var apiService = APIService.shared

    private var priorityColor: Color {
        switch program.priority.lowercased() {
        case "high": return .red
        case "medium": return .orange
        case "low": return .gray
        default: return .tornyBlue
        }
    }

    var body: some View {
        Button(action: {
            loadProgramDetails()
        }) {
            TornyCard {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(program.programTitle)
                                .font(TornyFonts.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.tornyTextPrimary)

                            HStack(spacing: 6) {
                                Circle()
                                    .fill(priorityColor)
                                    .frame(width: 8, height: 8)
                                Text("\(program.priority.uppercased()) PRIORITY")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(priorityColor)
                            }
                        }

                        Spacer()

                        if isLoadingProgram {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.tornyBlue)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }

                    Divider()

                    // Why This Program
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.tornyBlue)
                            Text("Why This Program")
                                .font(TornyFonts.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.tornyTextPrimary)
                        }

                        Text(program.relevance)
                            .font(TornyFonts.bodySecondary)
                            .foregroundColor(.tornyTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Expected Benefits
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 14))
                                .foregroundColor(.tornyGreen)
                            Text("Expected Benefits")
                                .font(TornyFonts.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.tornyTextPrimary)
                        }

                        Text(program.expectedBenefit)
                            .font(TornyFonts.bodySecondary)
                            .foregroundColor(.tornyTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Call to Action
                    HStack {
                        Spacer()
                        Text("View Program Details")
                            .font(TornyFonts.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.tornyBlue)
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.tornyBlue)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoadingProgram)
        .sheet(isPresented: $navigateToProgram) {
            if let loadedProgram = loadedProgram {
                NavigationView {
                    ProgramDetailView(program: loadedProgram)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func loadProgramDetails() {
        isLoadingProgram = true

        Task {
            do {
                let programDetails = try await apiService.getProgramDetails(programId: program.programId)
                await MainActor.run {
                    self.loadedProgram = programDetails
                    self.isLoadingProgram = false
                    self.navigateToProgram = true
                }
            } catch {
                await MainActor.run {
                    self.isLoadingProgram = false
                    self.errorMessage = "Failed to load program details: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
}
