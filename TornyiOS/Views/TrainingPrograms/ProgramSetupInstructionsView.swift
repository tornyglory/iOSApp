import SwiftUI

struct ProgramSetupInstructionsView: View {
    let instructions: ProgramInstructions
    let program: TrainingProgram
    let onBeginSetup: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()

                ScrollView {
                    VStack(spacing: 24) {
                        // Program Header
                        programHeader

                        // Stats Row
                        statsRow

                        // What You'll Need
                        whatYouNeedSection

                        // Setup Instructions
                        setupInstructionsSection

                        // Tips for Success
                        tipsSection

                        // Program Structure
                        programStructureSection

                        // Optional sections - Group 1
                        Group {
                            // Learning Focus (if applicable)
                            if let learningFocus = instructions.learningFocus, !learningFocus.isEmpty {
                                learningFocusSection(learningFocus)
                            }

                            // Safety Requirements (if applicable)
                            if let safetyReqs = instructions.safetyRequirements, !safetyReqs.isEmpty {
                                safetyRequirementsSection(safetyReqs)
                            }

                            // Prerequisites (if applicable)
                            if let prerequisites = instructions.prerequisites, !prerequisites.isEmpty {
                                prerequisitesSection(prerequisites)
                            }

                            // Not Recommended If (if applicable)
                            if let notRecommended = instructions.notRecommendedIf, !notRecommended.isEmpty {
                                notRecommendedSection(notRecommended)
                            }
                        }

                        // Optional sections - Group 2
                        Group {
                            // Performance Goals (if applicable)
                            if let goals = instructions.performanceGoals {
                                performanceGoalsSection(goals)
                            }

                            // Advanced Tips (if applicable)
                            if let advancedTips = instructions.advancedTips, !advancedTips.isEmpty {
                                advancedTipsSection(advancedTips)
                            }

                            // Warnings
                            if let warnings = instructions.warnings, !warnings.isEmpty {
                                warningsSection(warnings)
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Setup Instructions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(.tornyBlue)
                }
            }
            .safeAreaInset(edge: .bottom) {
                beginSetupButton
            }
            .onAppear {
                print("✅ ProgramSetupInstructionsView appeared for program: \(program.title) (ID: \(program.id))")
            }
        }
    }

    // MARK: - Header

    private var programHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: difficultyIcon)
                .font(.system(size: 50))
                .foregroundColor(difficultyColor)

            Text(instructions.title)
                .font(TornyFonts.title2)
                .fontWeight(.bold)
                .foregroundColor(.tornyTextPrimary)

            difficultyBadge
        }
    }

    private var difficultyIcon: String {
        switch instructions.difficulty {
        case .beginner: return "star.fill"
        case .intermediate: return "bolt.fill"
        case .advanced: return "flame.fill"
        }
    }

    private var difficultyColor: Color {
        switch instructions.difficulty {
        case .beginner: return .tornyGreen
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }

    private var difficultyBadge: some View {
        Text(instructions.difficulty.rawValue.capitalized)
            .font(TornyFonts.bodySecondary)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(difficultyColor)
            .cornerRadius(20)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        TornyCard {
            HStack(spacing: 20) {
                statItem(icon: "clock.fill", value: "\(instructions.duration) min", label: "Duration")
                Divider().frame(height: 40)
                statItem(icon: "target", value: "\(instructions.totalShots)", label: "Total Shots")
                Divider().frame(height: 40)
                statItem(icon: "chart.bar.fill", value: instructions.difficulty.rawValue.capitalized, label: "Level")
            }
            .padding()
        }
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.tornyBlue)
            Text(value)
                .font(TornyFonts.title3)
                .fontWeight(.bold)
                .foregroundColor(.tornyTextPrimary)
            Text(label)
                .font(TornyFonts.caption)
                .foregroundColor(.tornyTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Sections

    private var whatYouNeedSection: some View {
        instructionSection(icon: "📋", title: "What You'll Need") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(instructions.whatYouNeed, id: \.self) { item in
                    bulletPoint(text: item, isWarning: item.contains("⚠️"))
                }
            }
        }
    }

    private var setupInstructionsSection: some View {
        instructionSection(icon: "🎯", title: "How to Set Up") {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(instructions.setupSteps.enumerated()), id: \.offset) { index, step in
                    setupStep(number: index + 1, step: step)
                }
            }
        }
    }

    private func setupStep(number: Int, step: InstructionStep) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("\(number)")
                    .font(TornyFonts.body)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(step.important ? Color.red : Color.tornyBlue)
                    .clipShape(Circle())

                Text(step.title)
                    .font(TornyFonts.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.tornyTextPrimary)

                if let duration = step.duration {
                    Spacer()
                    Text(duration)
                        .font(TornyFonts.caption)
                        .foregroundColor(.tornyTextSecondary)
                }
            }

            Text(step.description)
                .font(TornyFonts.bodySecondary)
                .foregroundColor(.tornyTextSecondary)
                .padding(.leading, 36)
        }
    }

    private var tipsSection: some View {
        instructionSection(icon: "💡", title: "Tips for Success") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(instructions.tips, id: \.self) { tip in
                    bulletPoint(text: tip)
                }
            }
        }
    }

    private var programStructureSection: some View {
        instructionSection(icon: "📊", title: "Program Structure") {
            VStack(alignment: .leading, spacing: 16) {
                Text(instructions.structure.overview)
                    .font(TornyFonts.body)
                    .foregroundColor(.tornyTextSecondary)

                // Phases
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(instructions.structure.phases, id: \.name) { phase in
                        phaseItem(phase: phase)
                    }
                }

                // Shot Distribution
                shotDistributionView
            }
        }
    }

    private func phaseItem(phase: ProgramPhase) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(phase.shots)
                    .font(TornyFonts.bodySecondary)
                    .fontWeight(.bold)
                    .foregroundColor(.tornyBlue)
                Spacer()
            }
            Text(phase.name)
                .font(TornyFonts.body)
                .fontWeight(.semibold)
                .foregroundColor(.tornyTextPrimary)
            Text(phase.description)
                .font(TornyFonts.bodySecondary)
                .foregroundColor(.tornyTextSecondary)
        }
        .padding(12)
        .background(Color.tornyLightBlue.opacity(0.3))
        .cornerRadius(8)
    }

    private var shotDistributionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shot Distribution")
                .font(TornyFonts.body)
                .fontWeight(.semibold)
                .foregroundColor(.tornyTextPrimary)

            HStack(spacing: 12) {
                if instructions.structure.shotDistribution.draws > 0 {
                    shotTypeChip(type: "Draw", count: instructions.structure.shotDistribution.draws, color: .tornyBlue)
                }
                if instructions.structure.shotDistribution.yardOn > 0 {
                    shotTypeChip(type: "Yard On", count: instructions.structure.shotDistribution.yardOn, color: .tornyPurple)
                }
                if instructions.structure.shotDistribution.ditchWeight > 0 {
                    shotTypeChip(type: "Ditch", count: instructions.structure.shotDistribution.ditchWeight, color: .orange)
                }
                if instructions.structure.shotDistribution.drives > 0 {
                    shotTypeChip(type: "Drive", count: instructions.structure.shotDistribution.drives, color: .red)
                }
            }
        }
    }

    private func shotTypeChip(type: String, count: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(TornyFonts.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(type)
                .font(TornyFonts.caption)
                .foregroundColor(.tornyTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }

    private func learningFocusSection(_ items: [String]) -> some View {
        instructionSection(icon: "🎓", title: "Learning Focus") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    bulletPoint(text: item)
                }
            }
        }
    }

    private func safetyRequirementsSection(_ items: [String]) -> some View {
        warningSection(icon: "⚠️", title: "Safety Requirements", items: items, color: .red)
    }

    private func prerequisitesSection(_ items: [String]) -> some View {
        instructionSection(icon: "✅", title: "Prerequisites") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    bulletPoint(text: item)
                }
            }
        }
    }

    private func notRecommendedSection(_ items: [String]) -> some View {
        warningSection(icon: "⛔", title: "Not Recommended If", items: items, color: .orange)
    }

    private func performanceGoalsSection(_ goals: PerformanceGoals) -> some View {
        instructionSection(icon: "🎯", title: "Performance Goals") {
            VStack(alignment: .leading, spacing: 8) {
                if let yardOn = goals.yardOn {
                    bulletPoint(text: "Yard On: \(yardOn)")
                }
                if let ditchWeight = goals.ditchWeight {
                    bulletPoint(text: "Ditch Weight: \(ditchWeight)")
                }
                if let drives = goals.drives {
                    bulletPoint(text: "Drives: \(drives)")
                }
            }
        }
    }

    private func advancedTipsSection(_ tips: [String]) -> some View {
        instructionSection(icon: "🏆", title: "Advanced Tips") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(tips, id: \.self) { tip in
                    bulletPoint(text: tip)
                }
            }
        }
    }

    private func warningsSection(_ items: [String]) -> some View {
        warningSection(icon: "⚠️", title: "Before You Begin", items: items, color: .orange)
    }

    // MARK: - Helper Components

    private func instructionSection<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(TornyFonts.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.tornyTextPrimary)
            }

            content()
        }
    }

    private func warningSection(icon: String, title: String, items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(TornyFonts.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    bulletPoint(text: item, isWarning: true)
                }
            }
            .padding(16)
            .background(color.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 2)
            )
            .cornerRadius(12)
        }
    }

    private func bulletPoint(text: String, isWarning: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(TornyFonts.body)
                .foregroundColor(isWarning ? .red : .tornyBlue)
                .fontWeight(.bold)

            Text(text)
                .font(TornyFonts.bodySecondary)
                .foregroundColor(.tornyTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Begin Setup Button

    private var beginSetupButton: some View {
        Button(action: onBeginSetup) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Begin Setup")
            }
        }
        .buttonStyle(TornyPrimaryButton(isLarge: true))
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
        )
    }
}
