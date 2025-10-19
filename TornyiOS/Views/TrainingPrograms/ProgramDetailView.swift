import SwiftUI

struct ProgramDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ProgramDetailViewModel
    @State private var showingStartSession = false
    var onDismissToRoot: (() -> Void)? = nil

    init(program: TrainingProgram, onDismissToRoot: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: ProgramDetailViewModel(program: program))
        self.onDismissToRoot = onDismissToRoot
    }

    var body: some View {
        ZStack {
            TornyGradients.skyGradient
                .ignoresSafeArea()

            TornyCloudView()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Hero Section
                    VStack(spacing: 12) {
                        HStack {
                            Text(viewModel.program.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.tornyTextPrimary)

                            Spacer()

                            Button(action: {
                                Task {
                                    await viewModel.toggleFavorite()
                                }
                            }) {
                                Image(systemName: viewModel.program.isFavorited ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(viewModel.program.isFavorited ? .red : .secondary)
                            }
                        }

                        Text(viewModel.program.description)
                            .font(.body)
                            .foregroundColor(.tornyTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        // Program Info Pills
                        HStack(spacing: 12) {
                            InfoPill(icon: difficultyIcon, text: viewModel.program.difficulty.displayName, color: difficultyColor)
                            InfoPill(icon: "target", text: "\(viewModel.program.totalShots) shots", color: .blue)
                            if let duration = viewModel.program.estimatedDurationMinutes {
                                InfoPill(icon: "clock", text: "\(duration) min", color: .purple)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    .padding(.horizontal)

                    // Completion Stats (if available)
                    if let stats = viewModel.program.completionStats {
                        CompletionStatsCard(stats: stats)
                            .padding(.horizontal)
                    }

                    // Shot Preview
                    if let preview = viewModel.program.shotsPreview, !preview.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Shot Preview")
                                .font(.headline)
                                .foregroundColor(.tornyTextPrimary)
                                .padding(.horizontal)

                            VStack(spacing: 8) {
                                ForEach(preview) { shot in
                                    ShotPreviewRow(shot: shot)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }

            // Start Button (Fixed at bottom)
            VStack {
                Spacer()

                Button(action: {
                    showingStartSession = true
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.title3)
                        Text("Start Program")
                            .font(.headline)
                    }
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
                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
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
        .sheet(isPresented: $showingStartSession) {
            ProgramStartSetupView(program: viewModel.program, onDismissToRoot: onDismissToRoot)
        }
    }

    private var difficultyColor: Color {
        switch viewModel.program.difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }

    private var difficultyIcon: String {
        switch viewModel.program.difficulty {
        case .beginner: return "leaf.fill"
        case .intermediate: return "flame.fill"
        case .advanced: return "bolt.fill"
        }
    }
}

// MARK: - Component Views

struct InfoPill: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CompletionStatsCard: View {
    let stats: CompletionStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Performance")
                .font(.headline)
                .foregroundColor(.tornyTextPrimary)

            HStack(spacing: 16) {
                ProgramStatItem(title: "Completed", value: "\(stats.timesCompleted)", icon: "checkmark.circle.fill", color: .green)

                if let bestScore = stats.bestScore {
                    ProgramStatItem(title: "Best Score", value: "\(bestScore)", icon: "star.fill", color: .yellow)
                }

                if let avgScore = stats.averageScore {
                    ProgramStatItem(title: "Average", value: String(format: "%.0f", avgScore), icon: "chart.bar.fill", color: .blue)
                }
            }

            if let lastCompleted = stats.lastCompleted {
                Text("Last completed: \(formatDate(lastCompleted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct ProgramStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ShotPreviewRow: View {
    let shot: ProgramShot

    var body: some View {
        HStack(spacing: 12) {
            // Shot number
            Text("#\(shot.sequenceOrder)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .frame(width: 30)

            // Shot type icon
            Image(systemName: shot.shotType.icon)
                .foregroundColor(shotTypeColor)
                .frame(width: 24)

            // Shot info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(shot.shotType.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("•")
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: shot.hand.icon)
                            .font(.caption)
                        Text(shot.hand.displayName)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(shot.length.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let notes = shot.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private var shotTypeColor: Color {
        switch shot.shotType {
        case .draw: return .blue
        case .yardOn: return .green
        case .ditchWeight: return .orange
        case .drive: return .red
        }
    }
}

// MARK: - View Model

class ProgramDetailViewModel: ObservableObject {
    @Published var program: TrainingProgram
    private let apiService = APIService.shared

    init(program: TrainingProgram) {
        self.program = program
    }

    func toggleFavorite() async {
        // Optimistic update
        await MainActor.run {
            program.isFavorited.toggle()
        }

        do {
            _ = try await apiService.toggleProgramFavorite(
                programId: program.id,
                isFavorited: program.isFavorited
            )
        } catch {
            // Revert on error
            await MainActor.run {
                program.isFavorited.toggle()
            }
        }
    }
}

// MARK: - Program Start Setup

struct ProgramStartSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var apiService = APIService.shared
    let program: TrainingProgram
    var onDismissToRoot: (() -> Void)? = nil

    @State private var location = "outdoor"
    @State private var greenType = "bent"
    @State private var greenSpeed = 14
    @State private var rinkNumber = ""
    @State private var weather = "warm"
    @State private var windConditions = "light"
    @State private var notes = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    // Equipment fields
    @State private var bowlsBrand = "Taylor"
    @State private var bowlsModel = "GTR"
    @State private var bowlSize = "3"

    // Club fields
    @State private var selectedClub: Club?
    @State private var showingClubSearch = false
    @State private var clubSearchText = ""
    @State private var clubSearchResults: [Club] = []
    @State private var isSearchingClubs = false

    // Navigation to active session
    @State private var navigateToActiveSession = false
    @State private var sessionResponse: TrainingSessionResponse?
    @State private var sessionMetadata: ProgramSessionMetadata?

    let locations = ["outdoor", "indoor"]
    let weatherOptions = ["cold", "warm", "hot"]
    let windOptions = ["no_wind", "light", "moderate", "strong"]
    let bowlsBrands = ["Taylor", "Henselite", "Drakes Pride", "Aero"]

    var greenTypes: [String] {
        if location == "indoor" {
            return ["synthetic", "carpet"]
        } else {
            return ["couch", "tift", "bent", "synthetic", "carpet"]
        }
    }

    var bowlsModels: [String] {
        switch bowlsBrand {
        case "Henselite":
            return ["Dreamline XG", "Cruse", "Dreamline", "Alpha", "Tiger II", "ABT 2000", "Classic II"]
        case "Aero":
            return ["Dynamic", "Optima", "Turbo Pro", "Evolve", "Defiance"]
        case "Drakes Pride":
            return ["Conquest", "Adrenaline", "LS-125", "International"]
        case "Taylor":
            return ["GTR", "SRV", "SR", "Ace", "Blaze", "Vector VS"]
        default:
            return []
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)

                            Text(program.title)
                                .font(TornyFonts.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.tornyTextPrimary)
                                .multilineTextAlignment(.center)

                            Text("Set up your green conditions to begin")
                                .font(TornyFonts.body)
                                .foregroundColor(.tornyTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)

                        // Green Conditions
                        TornyCard {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Green Conditions")
                                    .font(TornyFonts.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.tornyTextPrimary)

                                // Location
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Location")
                                            .font(TornyFonts.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.tornyTextPrimary)
                                        Text("*")
                                            .foregroundColor(.red)
                                    }

                                    HStack(spacing: 12) {
                                        ForEach(locations, id: \.self) { loc in
                                            Button(action: {
                                                location = loc
                                                if loc == "indoor" && !["synthetic", "carpet"].contains(greenType) {
                                                    greenType = "synthetic"
                                                }
                                            }) {
                                                HStack {
                                                    Image(systemName: location == loc ? "checkmark.circle.fill" : "circle")
                                                        .foregroundColor(.tornyBlue)
                                                    Text(loc.capitalized)
                                                        .font(TornyFonts.body)
                                                        .foregroundColor(.tornyTextPrimary)
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(location == loc ? Color.tornyBlue.opacity(0.1) : Color.white)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(location == loc ? Color.tornyBlue : Color.tornyLightBlue, lineWidth: 1)
                                                        )
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }

                                // Green Type
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Green Type")
                                            .font(TornyFonts.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.tornyTextPrimary)
                                        Text("*")
                                            .foregroundColor(.red)
                                    }

                                    Menu {
                                        ForEach(greenTypes, id: \.self) { type in
                                            Button(type.capitalized) {
                                                greenType = type
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(greenType.capitalized)
                                                .foregroundColor(.tornyTextPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.tornyLightBlue, lineWidth: 1)
                                                )
                                        )
                                    }
                                }

                                // Green Speed
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        HStack {
                                            Text("Green Speed")
                                                .font(TornyFonts.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.tornyTextPrimary)
                                            Text("*")
                                                .foregroundColor(.red)
                                        }
                                        Spacer()
                                        Text("\(greenSpeed) seconds")
                                            .font(TornyFonts.body)
                                            .foregroundColor(.tornyBlue)
                                            .fontWeight(.medium)
                                    }

                                    Slider(value: .init(
                                        get: { Double(greenSpeed) },
                                        set: { greenSpeed = Int($0) }
                                    ), in: 8...22, step: 1)
                                    .accentColor(.tornyBlue)

                                    HStack {
                                        Text("8 sec (Fast)")
                                            .font(TornyFonts.caption)
                                            .foregroundColor(.tornyTextSecondary)
                                        Spacer()
                                        Text("22 sec (Slow)")
                                            .font(TornyFonts.caption)
                                            .foregroundColor(.tornyTextSecondary)
                                    }
                                }

                                // Rink Number
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Rink Number (Optional)")
                                        .font(TornyFonts.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.tornyTextPrimary)

                                    TextField("Enter rink number", text: $rinkNumber)
                                        .textFieldStyle(TornyTextFieldStyle())
                                        .keyboardType(.numberPad)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Environmental Conditions (Outdoor Only)
                        if location == "outdoor" {
                            TornyCard {
                                VStack(alignment: .leading, spacing: 20) {
                                    Text("Environmental Conditions")
                                        .font(TornyFonts.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.tornyTextPrimary)

                                    // Weather
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Weather")
                                                .font(TornyFonts.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.tornyTextPrimary)
                                            Text("*")
                                                .foregroundColor(.red)
                                        }

                                        HStack(spacing: 12) {
                                            ForEach(weatherOptions, id: \.self) { w in
                                                Button(action: {
                                                    weather = w
                                                }) {
                                                    VStack(spacing: 4) {
                                                        Text(weatherIcon(for: w))
                                                            .font(.title2)
                                                        Text(w.capitalized)
                                                            .font(TornyFonts.bodySecondary)
                                                            .foregroundColor(.tornyTextPrimary)
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 12)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(weather == w ? Color.tornyBlue.opacity(0.1) : Color.white)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 12)
                                                                    .stroke(weather == w ? Color.tornyBlue : Color.tornyLightBlue, lineWidth: 1)
                                                            )
                                                    )
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }

                                    // Wind Conditions
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Wind Conditions")
                                                .font(TornyFonts.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.tornyTextPrimary)
                                            Text("*")
                                                .foregroundColor(.red)
                                        }

                                        Menu {
                                            ForEach(windOptions, id: \.self) { wind in
                                                Button(windDisplayName(for: wind)) {
                                                    windConditions = wind
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(windDisplayName(for: windConditions))
                                                    .foregroundColor(.tornyTextPrimary)
                                                Spacer()
                                                Image(systemName: "chevron.down")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.tornyLightBlue, lineWidth: 1)
                                                    )
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Equipment
                        TornyCard {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Equipment (Optional)")
                                    .font(TornyFonts.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.tornyTextPrimary)

                                // Bowls Brand
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Bowls Brand")
                                        .font(TornyFonts.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.tornyTextPrimary)

                                    Menu {
                                        ForEach(bowlsBrands, id: \.self) { brand in
                                            Button(brand) {
                                                bowlsBrand = brand
                                                // Reset model to first in list when brand changes
                                                bowlsModel = bowlsModels.first ?? ""
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(bowlsBrand)
                                                .foregroundColor(.tornyTextPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.tornyLightBlue, lineWidth: 1)
                                                )
                                        )
                                    }
                                }

                                // Bowls Model
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Bowls Model")
                                        .font(TornyFonts.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.tornyTextPrimary)

                                    Menu {
                                        ForEach(bowlsModels, id: \.self) { model in
                                            Button(model) {
                                                bowlsModel = model
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(bowlsModel)
                                                .foregroundColor(.tornyTextPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.tornyLightBlue, lineWidth: 1)
                                                )
                                        )
                                    }
                                }

                                // Bowl Size
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Bowl Size")
                                        .font(TornyFonts.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.tornyTextPrimary)

                                    Menu {
                                        ForEach(["00", "0", "1", "2", "3", "4", "5", "6", "7"], id: \.self) { size in
                                            Button(size) {
                                                bowlSize = size
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(bowlSize)
                                                .foregroundColor(.tornyTextPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.tornyLightBlue, lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Club Selection
                        TornyCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Club (Optional)")
                                    .font(TornyFonts.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.tornyTextPrimary)

                                if let club = selectedClub {
                                    // Selected Club Display
                                    HStack(spacing: 12) {
                                        AsyncImage(url: URL(string: club.avatar ?? "")) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.gray.opacity(0.2))
                                                .overlay(
                                                    Image(systemName: "building.2")
                                                        .foregroundColor(.gray)
                                                )
                                        }
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(club.name)
                                                .font(TornyFonts.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.tornyTextPrimary)

                                            Text([club.state, club.country].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", "))
                                                .font(TornyFonts.bodySecondary)
                                                .foregroundColor(.tornyTextSecondary)
                                        }

                                        Spacer()

                                        Button(action: {
                                            selectedClub = nil
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                                .font(.title3)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.tornyBlue.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.tornyBlue, lineWidth: 1)
                                            )
                                    )
                                } else {
                                    // Search Button
                                    Button(action: {
                                        showingClubSearch = true
                                    }) {
                                        HStack {
                                            Image(systemName: "magnifyingglass")
                                            Text("Search for Club")
                                        }
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyBlue)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.tornyBlue, lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Notes
                        TornyCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Notes (Optional)")
                                    .font(TornyFonts.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.tornyTextPrimary)

                                TextField("Add any notes about this session", text: $notes, axis: .vertical)
                                    .textFieldStyle(TornyTextFieldStyle())
                                    .lineLimit(3...6)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Start Program Button
                        Button(action: startProgram) {
                            HStack {
                                if isLoading {
                                    TornyLoadingView()
                                    Text("Starting Program...")
                                } else {
                                    Image(systemName: "play.fill")
                                    Text("Start Program")
                                }
                            }
                        }
                        .buttonStyle(TornyPrimaryButton(isLarge: true))
                        .frame(maxWidth: .infinity)
                        .disabled(isLoading)
                        .padding(.horizontal, 20)

                        Spacer(minLength: 100)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Setup Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.tornyBlue)
                }
            }
        }
        .sheet(isPresented: $showingClubSearch) {
            ProgramClubSearchSheet(
                selectedClub: $selectedClub,
                clubSearchText: $clubSearchText,
                clubSearchResults: $clubSearchResults,
                isSearching: $isSearchingClubs,
                onSearch: searchClubs
            )
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $navigateToActiveSession) {
            if let response = sessionResponse, let nextShot = response.nextShot, let metadata = sessionMetadata {
                NavigationView {
                    ActiveProgramSessionView(
                        sessionInfo: response.session,
                        currentShot: nextShot,
                        programTitle: program.title,
                        sessionMetadata: metadata,
                        onCompleteProgram: {
                            // Dismiss the setup sheet
                            dismiss()
                            // Then dismiss all the way to the dashboard
                            onDismissToRoot?()
                        }
                    )
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    Text("Unable to start program")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("No shot data available")
                        .foregroundColor(.secondary)
                    Button("OK") {
                        dismiss()
                    }
                    .buttonStyle(TornyPrimaryButton(isLarge: true))
                    .padding(.horizontal, 40)
                }
                .padding()
            }
        }
    }

    private func weatherIcon(for weather: String) -> String {
        switch weather {
        case "cold": return "❄️"
        case "warm": return "☀️"
        case "hot": return "🔥"
        default: return "☀️"
        }
    }

    private func windDisplayName(for wind: String) -> String {
        switch wind {
        case "no_wind": return "No Wind"
        case "light": return "Light Wind"
        case "moderate": return "Moderate Wind"
        case "strong": return "Strong Wind"
        default: return wind.capitalized
        }
    }

    private func startProgram() {
        isLoading = true

        let equipment = StartProgramRequest.Equipment(
            bowls: "\(bowlsBrand) \(bowlsModel)",
            bowlSize: bowlSize,
            shoes: nil
        )

        let request = StartProgramRequest(
            location: location,
            greenType: greenType,
            greenSpeed: greenSpeed,
            rinkNumber: rinkNumber.isEmpty ? nil : Int(rinkNumber),
            weather: location == "outdoor" ? weather : nil,
            windConditions: location == "outdoor" ? windConditions : nil,
            notes: notes.isEmpty ? nil : notes,
            equipment: equipment,
            clubId: selectedClub?.id
        )

        Task {
            do {
                let response = try await apiService.startTrainingProgram(programId: program.id, config: request)

                // Check if nextShot is null - this indicates a backend issue
                if response.nextShot == nil {
                    print("❌ Backend error: next_shot is null in start response")
                    print("📋 Session created with ID: \(response.session.id)")
                    await MainActor.run {
                        isLoading = false
                        alertMessage = "Backend error: The program was created but no shot data was returned. Please check that the program has shots configured in the database."
                        showingAlert = true
                    }
                    return
                }

                // Create session metadata to pass to the active session view
                let sessionMetadata = ProgramSessionMetadata(
                    club: selectedClub,
                    bowls: "\(bowlsBrand) \(bowlsModel)",
                    bowlSize: bowlSize,
                    location: location,
                    greenType: greenType,
                    greenSpeed: greenSpeed,
                    startTime: Date()
                )

                await MainActor.run {
                    isLoading = false
                    sessionResponse = response
                    self.sessionMetadata = sessionMetadata
                    navigateToActiveSession = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Failed to start program: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }

    private func searchClubs() {
        guard clubSearchText.count >= 3 else {
            clubSearchResults = []
            return
        }

        isSearchingClubs = true

        Task {
            do {
                let results = try await apiService.searchClubs(name: clubSearchText)
                await MainActor.run {
                    clubSearchResults = results
                    isSearchingClubs = false
                }
            } catch {
                await MainActor.run {
                    clubSearchResults = []
                    isSearchingClubs = false
                }
            }
        }
    }
}

// MARK: - Program Club Search Sheet
struct ProgramClubSearchSheet: View {
    @Binding var selectedClub: Club?
    @Binding var clubSearchText: String
    @Binding var clubSearchResults: [Club]
    @Binding var isSearching: Bool
    let onSearch: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search clubs (min 3 characters)", text: $clubSearchText)
                        .onChange(of: clubSearchText) { _ in
                            onSearch()
                        }
                    if !clubSearchText.isEmpty {
                        Button("Clear") {
                            clubSearchText = ""
                            clubSearchResults = []
                        }
                        .foregroundColor(.tornyBlue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                // Search Results
                if isSearching {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if clubSearchResults.isEmpty && clubSearchText.count >= 3 {
                    VStack(spacing: 16) {
                        Image(systemName: "building.2")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No clubs found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Try adjusting your search terms")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                } else if clubSearchText.count < 3 {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Search for clubs")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Enter at least 3 characters to search")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(clubSearchResults) { club in
                                ProgramClubSearchRow(club: club) {
                                    selectedClub = club
                                    dismiss()
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Search Clubs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.tornyBlue)
                }
            }
        }
    }
}

// MARK: - Program Club Search Row
struct ProgramClubSearchRow: View {
    let club: Club
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: club.avatar ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "building.2")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 50, height: 50)
                .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(club.name)
                        .font(TornyFonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.tornyTextPrimary)

                    Text([club.state, club.country].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", "))
                        .font(TornyFonts.bodySecondary)
                        .foregroundColor(.tornyTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.tornyLightBlue, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Session Metadata
struct ProgramSessionMetadata {
    let club: Club?
    let bowls: String
    let bowlSize: String
    let location: String
    let greenType: String
    let greenSpeed: Int
    let startTime: Date
}
