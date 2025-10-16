import SwiftUI
import Foundation

struct TrainingSetupView: View {
    @ObservedObject private var apiService = APIService.shared
    @State private var location = "outdoor"
    @State private var greenType = "bent"
    @State private var greenSpeed = 14
    @State private var rinkNumber = ""
    @State private var weather = "warm"
    @State private var windConditions = "light"
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var validationErrors: [String] = []
    @State private var validationWarnings: [String] = []
    @Environment(\.dismiss) private var dismiss

    // Equipment fields
    @State private var bowlsBrand = "Taylor"
    @State private var bowlsModel = "GTR"
    @State private var bowlsSize = 3
    @State private var biasType = "mid"

    // Club fields
    @State private var selectedClub: Club?
    @State private var showingClubSearch = false
    @State private var clubSearchText = ""
    @State private var clubSearchResults: [Club] = []
    @State private var isSearchingClubs = false

    let locations = ["outdoor", "indoor"]
    let weatherOptions = ["cold", "warm", "hot"]
    let windOptions = ["no_wind", "light", "moderate", "strong"]
    let bowlsBrands = ["Taylor", "Henselite", "Drakes Pride", "Aero"]
    let bowlsSizes = [0, 1, 2, 3, 4, 5, 6]
    let biasTypes = ["narrow", "mid", "wide"]

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

    var onSessionCreated: ((TrainingSession) -> Void)?

    init(onSessionCreated: ((TrainingSession) -> Void)? = nil) {
        self.onSessionCreated = onSessionCreated
    }

    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "target")
                                .font(.system(size: 60))
                                .foregroundColor(.tornyBlue)

                            Text("Start Training Session")
                                .font(TornyFonts.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.tornyTextPrimary)

                            Text("Set up your green conditions and environmental factors")
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
                                                // Reset green type if switching to indoor and current type isn't valid
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
                                Text("Equipment")
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

                                // Size
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Size")
                                        .font(TornyFonts.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.tornyTextPrimary)

                                    Menu {
                                        ForEach(bowlsSizes, id: \.self) { size in
                                            Button(size == 0 ? "00" : "\(size)") {
                                                bowlsSize = size
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(bowlsSize == 0 ? "00" : "\(bowlsSize)")
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

                                // Bias Type
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Bias Type")
                                        .font(TornyFonts.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.tornyTextPrimary)

                                    Menu {
                                        ForEach(biasTypes, id: \.self) { bias in
                                            Button(bias.capitalized) {
                                                biasType = bias
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(biasType.capitalized)
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
                        
                        // Start Training Button
                        Button(action: createSession) {
                            HStack {
                                if isLoading {
                                    TornyLoadingView(color: .white)
                                    Text("Creating Session...")
                                } else {
                                    Image(systemName: "play.fill")
                                    Text("Start Training Session")
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
            .navigationTitle("Start Training")
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
        }
        .sheet(isPresented: $showingClubSearch) {
            ClubSearchSheet(
                selectedClub: $selectedClub,
                clubSearchText: $clubSearchText,
                clubSearchResults: $clubSearchResults,
                isSearching: $isSearchingClubs,
                onSearch: searchClubs
            )
        }
        .alert(validationWarnings.isEmpty ? "Error" : "Notice", isPresented: $showingAlert) {
            if validationWarnings.isEmpty {
                Button("OK") { }
            } else {
                Button("Cancel", role: .cancel) { }
                Button("Continue") {
                    startSession()
                }
            }
        } message: {
            Text(alertMessage)
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
    
    private func validateForm() -> (isValid: Bool, hasWarnings: Bool) {
        validationErrors.removeAll()
        validationWarnings.removeAll()

        // Validate green speed
        if greenSpeed < 8 || greenSpeed > 22 {
            validationErrors.append("Green speed must be between 8-22 seconds")
        }

        // Validate rink number if provided
        if !rinkNumber.isEmpty {
            if let rink = Int(rinkNumber) {
                if rink < 1 || rink > 8 {
                    validationErrors.append("Rink number must be between 1-8")
                }
            } else {
                validationErrors.append("Rink number must be a valid number")
            }
        }

        // Club validation - show warning message if not selected
        if selectedClub == nil {
            validationWarnings.append("ℹ️ No club selected. Please add club details in the session notes at the end of your session.")
        }

        // For outdoor sessions, weather and wind are required (already set by defaults)
        // Indoor sessions should not have weather/wind (handled automatically)

        return (isValid: validationErrors.isEmpty, hasWarnings: !validationWarnings.isEmpty)
    }
    
    private func createSession() {
        // Validate form first
        let validation = validateForm()

        // Show errors if any
        if !validation.isValid {
            alertMessage = validationErrors.joined(separator: "\n")
            showingAlert = true
            return
        }

        // Show warnings if any (but allow continuation)
        if validation.hasWarnings {
            alertMessage = validationWarnings.joined(separator: "\n\n") + "\n\nDo you want to continue?"
            showingAlert = true
            return
        }

        startSession()
    }

    private func startSession() {
        isLoading = true
        
        let equipment = EquipmentData(
            bowlsBrand: bowlsBrand,
            bowlsModel: bowlsModel,
            size: bowlsSize,
            biasType: biasType,
            bag: nil,
            shoes: nil,
            accessories: nil,
            stickUsed: false
        )

        let sessionRequest = CreateSessionRequest(
            location: Location(rawValue: location) ?? .outdoor,
            greenType: GreenType(rawValue: greenType) ?? .bent,
            greenSpeed: greenSpeed,
            rinkNumber: rinkNumber.isEmpty ? nil : Int(rinkNumber),
            weather: location == "outdoor" ? Weather(rawValue: weather) : nil,
            windConditions: location == "outdoor" ? WindConditions(rawValue: windConditions) : nil,
            notes: nil,
            equipment: equipment,
            clubId: selectedClub?.id
        )

        // Log the payload
        if let jsonData = try? JSONEncoder().encode(sessionRequest),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 Create Session Payload:")
            print(jsonString)
        }

        Task {
            do {
                let response = try await apiService.createSession(sessionRequest)
                
                await MainActor.run {
                    isLoading = false
                    onSessionCreated?(response.session)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Failed to create session: \(error.localizedDescription)"
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

// MARK: - Club Search Sheet
struct ClubSearchSheet: View {
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
                                ClubSearchRow(club: club) {
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

// MARK: - Club Search Row
struct ClubSearchRow: View {
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

struct TrainingSetupView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingSetupView()
    }
}