import SwiftUI

struct AIInsightsView: View {
    @StateObject private var viewModel = AIInsightsViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()

                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        TornyLoadingView(color: .tornyBlue)
                        Text("Analysing your performance...")
                            .font(TornyFonts.body)
                            .foregroundColor(.tornyTextSecondary)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Failed to load insights")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            viewModel.fetchInsights()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if let insights = viewModel.insights {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header section with Torny AI branding
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
                                        .frame(width: 80, height: 80)

                                    Image(systemName: "sparkles")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                }

                                HStack(spacing: 4) {
                                    Text("Torny")
                                        .font(TornyFonts.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.tornyTextPrimary)
                                    Text("AI")
                                        .font(TornyFonts.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.purple, .blue]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }

                                Text("Personalised performance insights")
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextSecondary)
                            }
                            .padding(.top, 20)

                            // Overall Assessment
                            TornyCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "chart.bar.doc.horizontal")
                                            .foregroundColor(.tornyBlue)
                                        Text("Overall Assessment")
                                            .font(TornyFonts.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.tornyTextPrimary)
                                    }

                                    Text(insights.overallAssessment)
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }

                            // Key Insights
                            if !insights.keyInsights.isEmpty {
                                TornyCard {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Image(systemName: "key.fill")
                                                .foregroundColor(.tornyGreen)
                                            Text("Key Insights")
                                                .font(TornyFonts.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.tornyTextPrimary)
                                        }

                                        ForEach(Array(insights.keyInsights.enumerated()), id: \.offset) { _, insight in
                                            HStack(alignment: .top, spacing: 8) {
                                                Image(systemName: "circle.fill")
                                                    .font(.system(size: 6))
                                                    .foregroundColor(.tornyGreen)
                                                    .padding(.top, 6)

                                                Text(insight)
                                                    .font(TornyFonts.body)
                                                    .foregroundColor(.tornyTextSecondary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                }
                            }

                            // Equipment Performance
                            if let equipmentPerformance = insights.equipmentPerformance, !equipmentPerformance.isEmpty {
                                TornyCard {
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Image(systemName: "circle.circle")
                                                .foregroundColor(.tornyPurple)
                                            Text("Equipment Performance")
                                                .font(TornyFonts.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.tornyTextPrimary)
                                        }

                                        ForEach(equipmentPerformance) { equipment in
                                            EquipmentPerformanceCard(equipment: equipment)
                                        }
                                    }
                                }
                            }

                            // Club Performance
                            if let clubPerformance = insights.clubPerformance, !clubPerformance.isEmpty {
                                TornyCard {
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Image(systemName: "building.2")
                                                .foregroundColor(.tornyBlue)
                                            Text("Club Performance")
                                                .font(TornyFonts.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.tornyTextPrimary)
                                        }

                                        ForEach(clubPerformance) { club in
                                            ClubPerformanceCard(club: club)
                                        }
                                    }
                                }
                            }

                            // Strengths and Weaknesses
                            VStack(spacing: 16) {
                                // Strengths
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

                                        ForEach(Array(insights.strengths.enumerated()), id: \.offset) { _, strength in
                                            HStack(alignment: .top, spacing: 8) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.tornyGreen)
                                                    .padding(.top, 4)

                                                Text(strength)
                                                    .font(TornyFonts.bodySecondary)
                                                    .foregroundColor(.tornyTextSecondary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                }

                            }

                            // Areas for Improvement
                            if !insights.areasForImprovement.isEmpty {
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

                                        ForEach(insights.areasForImprovement) { area in
                                            ImprovementAreaCard(area: area)
                                        }
                                    }
                                }
                            }


                            // Recommended Drills
                            if !insights.recommendedDrills.isEmpty {
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

                                        ForEach(insights.recommendedDrills) { drill in
                                            DrillCard(drill: drill)
                                        }
                                    }
                                }
                            }

                            // Next Session Focus
                            TornyCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "target")
                                            .foregroundColor(.orange)
                                        Text("Next Session Focus")
                                            .font(TornyFonts.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.tornyTextPrimary)
                                    }

                                    Text(insights.nextSessionFocus)
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }

                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                } else {
                    TornyLoadingView(color: .tornyBlue)
                        .onAppear {
                            viewModel.fetchInsights()
                        }
                }
            }
            .navigationTitle("Torny AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.tornyTextPrimary)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Components

struct ImprovementAreaCard: View {
    let area: AreaForImprovement

    var priorityColor: Color {
        switch area.priority.lowercased() {
        case "high": return .red
        case "medium": return .orange
        case "low": return .tornyGreen
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(area.area)
                    .font(TornyFonts.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.tornyTextPrimary)

                Spacer()

                Text(area.priority.uppercased())
                    .font(TornyFonts.bodySecondary)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor)
                    .cornerRadius(6)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Current:")
                        .font(TornyFonts.bodySecondary)
                        .foregroundColor(.tornyTextSecondary)
                    Text(area.currentPerformance)
                        .font(TornyFonts.bodySecondary)
                        .foregroundColor(.tornyTextPrimary)
                }

                HStack {
                    Text("Target:")
                        .font(TornyFonts.bodySecondary)
                        .foregroundColor(.tornyTextSecondary)
                    Text(area.target)
                        .font(TornyFonts.bodySecondary)
                        .foregroundColor(.tornyGreen)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct PatternRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TornyFonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(.tornyTextPrimary)

                Text(value)
                    .font(TornyFonts.bodySecondary)
                    .foregroundColor(.tornyTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct DrillCard: View {
    let drill: RecommendedDrill

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(drill.drillName)
                    .font(TornyFonts.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.tornyTextPrimary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(drill.duration)
                        .font(TornyFonts.bodySecondary)
                }
                .foregroundColor(.tornyTextSecondary)
            }

            Text(drill.description)
                .font(TornyFonts.bodySecondary)
                .foregroundColor(.tornyTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("Target:")
                    .font(TornyFonts.bodySecondary)
                    .foregroundColor(.tornyTextSecondary)
                Text(drill.targetMetrics)
                    .font(TornyFonts.bodySecondary)
                    .foregroundColor(.tornyGreen)
                    .fontWeight(.medium)
            }
        }
        .padding(12)
        .background(Color.tornyBlue.opacity(0.05))
        .cornerRadius(8)
    }
}

struct EquipmentPerformanceCard: View {
    let equipment: EquipmentPerformance

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "circle.circle")
                    .foregroundColor(.tornyPurple)

                VStack(alignment: .leading, spacing: 2) {
                    if let brand = equipment.equipment.bowlsBrand,
                       let model = equipment.equipment.bowlsModel {
                        Text("\(brand) \(model)")
                            .font(TornyFonts.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.tornyTextPrimary)
                    }

                    HStack(spacing: 8) {
                        if let size = equipment.equipment.size {
                            Text("Size \(size)")
                                .font(TornyFonts.bodySecondary)
                                .foregroundColor(.tornyTextSecondary)
                        }

                        if let biasType = equipment.equipment.biasType {
                            Text("• \(biasType.capitalized) bias")
                                .font(TornyFonts.bodySecondary)
                                .foregroundColor(.tornyTextSecondary)
                        }
                    }
                }

                Spacer()

                Text(String(format: "%.1f%%", equipment.accuracy))
                    .font(TornyFonts.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.tornyPurple)
            }

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.tornyTextSecondary)
                    Text("\(equipment.sessions) sessions")
                        .font(TornyFonts.bodySecondary)
                        .foregroundColor(.tornyTextSecondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "circle.grid.cross")
                        .font(.system(size: 12))
                        .foregroundColor(.tornyTextSecondary)
                    Text("\(equipment.shots) shots")
                        .font(TornyFonts.bodySecondary)
                        .foregroundColor(.tornyTextSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.tornyPurple.opacity(0.05))
        .cornerRadius(8)
    }
}

struct ClubPerformanceCard: View {
    let club: ClubPerformance

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "building.2")
                    .foregroundColor(.tornyBlue)

                VStack(alignment: .leading, spacing: 2) {
                    Text(club.clubName)
                        .font(TornyFonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.tornyTextPrimary)

                    if let description = club.clubDescription, !description.isEmpty {
                        Text(description)
                            .font(TornyFonts.bodySecondary)
                            .foregroundColor(.tornyTextSecondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Text(String(format: "%.1f%%", club.accuracy))
                    .font(TornyFonts.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.tornyBlue)
            }

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.tornyTextSecondary)
                    Text("\(club.sessions) sessions")
                        .font(TornyFonts.bodySecondary)
                        .foregroundColor(.tornyTextSecondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "circle.grid.cross")
                        .font(.system(size: 12))
                        .foregroundColor(.tornyTextSecondary)
                    Text("\(club.shots) shots")
                        .font(TornyFonts.bodySecondary)
                        .foregroundColor(.tornyTextSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.tornyBlue.opacity(0.05))
        .cornerRadius(8)
    }
}

struct AIInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        AIInsightsView()
    }
}
