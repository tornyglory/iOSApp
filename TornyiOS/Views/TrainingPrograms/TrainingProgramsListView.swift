import SwiftUI

struct TrainingProgramsListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TrainingProgramsViewModel()
    @State private var selectedDifficulty: TrainingProgram.Difficulty? = nil
    @State private var searchText = ""
    @State private var showFeaturedOnly = false
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        ZStack {
            // Blue gradient background with clouds
            TornyGradients.skyGradient
                .ignoresSafeArea()

            TornyCloudView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button(action: {
                        if let onDismiss = onDismiss {
                            onDismiss()
                        } else {
                            dismiss()
                        }
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

                    Spacer()

                    Text("Training Programs")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    // Placeholder for symmetry
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                        Text("Back")
                            .font(.body)
                    }
                    .opacity(0)
                }
                .padding()
                .background(Color.white.opacity(0.95))

                if viewModel.isLoading {
                    Spacer()
                    VStack(spacing: 12) {
                        TornyLoadingView()
                        Text("Loading programs...")
                            .font(TornyFonts.body)
                            .foregroundColor(.tornyTextSecondary)
                    }
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Failed to load programs")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task {
                                await viewModel.loadPrograms()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Search and Filters
                            VStack(spacing: 12) {
                                // Search Bar
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.secondary)
                                    TextField("Search programs...", text: $searchText)
                                        .textFieldStyle(PlainTextFieldStyle())
                                }
                                .padding(12)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)

                                // Difficulty Filter
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        FilterChip(
                                            title: "All",
                                            isSelected: selectedDifficulty == nil,
                                            action: { selectedDifficulty = nil }
                                        )

                                        FilterChip(
                                            title: "Beginner",
                                            isSelected: selectedDifficulty == .beginner,
                                            color: .green,
                                            action: { selectedDifficulty = .beginner }
                                        )

                                        FilterChip(
                                            title: "Intermediate",
                                            isSelected: selectedDifficulty == .intermediate,
                                            color: .orange,
                                            action: { selectedDifficulty = .intermediate }
                                        )

                                        FilterChip(
                                            title: "Advanced",
                                            isSelected: selectedDifficulty == .advanced,
                                            color: .red,
                                            action: { selectedDifficulty = .advanced }
                                        )

                                        Divider()
                                            .frame(height: 20)

                                        FilterChip(
                                            title: "⭐ Featured",
                                            isSelected: showFeaturedOnly,
                                            action: { showFeaturedOnly.toggle() }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)

                            // Programs List
                            if filteredPrograms.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "list.bullet.clipboard")
                                        .font(.system(size: 50))
                                        .foregroundColor(.secondary)
                                    Text("No programs found")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                .frame(height: 200)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredPrograms) { program in
                                        NavigationLink(destination: ProgramDetailView(program: program, onDismissToRoot: onDismiss)) {
                                            ProgramCard(
                                                program: program,
                                                onFavoriteTap: {
                                                    Task {
                                                        await viewModel.toggleFavorite(program: program)
                                                    }
                                                }
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }

                            Spacer(minLength: 100)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadPrograms()
        }
    }

    private var filteredPrograms: [TrainingProgram] {
        var programs = viewModel.programs

        // Filter by difficulty
        if let difficulty = selectedDifficulty {
            programs = programs.filter { $0.difficulty == difficulty }
        }

        // Filter by featured
        if showFeaturedOnly {
            programs = programs.filter { $0.isFeatured }
        }

        // Filter by search text
        if !searchText.isEmpty {
            programs = programs.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort: favorited first, then featured, then by title
        return programs.sorted { program1, program2 in
            if program1.isFavorited != program2.isFavorited {
                return program1.isFavorited
            }
            if program1.isFeatured != program2.isFeatured {
                return program1.isFeatured
            }
            return program1.title < program2.title
        }
    }
}

// MARK: - Filter Chip Component

struct FilterChip: View {
    let title: String
    var isSelected: Bool
    var color: Color = .tornyBlue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color(.systemBackground))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

// MARK: - Program Card Component

struct ProgramCard: View {
    let program: TrainingProgram
    let onFavoriteTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(program.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.tornyTextPrimary)

                        if program.isFeatured {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }

                    Text(program.shortDescription ?? program.description)
                        .font(.subheadline)
                        .foregroundColor(.tornyTextSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Button(action: {}) {
                    Image(systemName: program.isFavorited ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(program.isFavorited ? .red : .secondary)
                        .padding(8)
                }
                .buttonStyle(PlainButtonStyle())
                .highPriorityGesture(
                    TapGesture().onEnded { _ in
                        onFavoriteTap()
                    }
                )
            }

            Divider()

            // Program Info
            HStack(spacing: 16) {
                // Difficulty
                HStack(spacing: 4) {
                    Circle()
                        .fill(difficultyColor)
                        .frame(width: 8, height: 8)
                    Text(program.difficulty.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Total Shots
                HStack(spacing: 4) {
                    Image(systemName: "target")
                        .font(.caption)
                    Text("\(program.totalShots) shots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Duration
                if let duration = program.estimatedDurationMinutes {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("\(duration) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    private var difficultyColor: Color {
        switch program.difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

// MARK: - View Model

@MainActor
class TrainingProgramsViewModel: ObservableObject {
    @Published var programs: [TrainingProgram] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var apiService: APIService { APIService.shared }

    func loadPrograms() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.getTrainingPrograms()
            await MainActor.run {
                self.programs = response.programs
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func toggleFavorite(program: TrainingProgram) async {
        // Optimistic update
        if let index = programs.firstIndex(where: { $0.id == program.id }) {
            await MainActor.run {
                programs[index].isFavorited.toggle()
            }
        }

        do {
            _ = try await apiService.toggleProgramFavorite(
                programId: program.id,
                isFavorited: program.isFavorited
            )
        } catch {
            // Revert on error
            if let index = programs.firstIndex(where: { $0.id == program.id }) {
                await MainActor.run {
                    programs[index].isFavorited.toggle()
                }
            }
        }
    }
}

struct TrainingProgramsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TrainingProgramsListView()
        }
    }
}
