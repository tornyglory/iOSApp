import SwiftUI

struct TrainingSetupView: View {
    @ObservedObject private var apiService = APIService.shared
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
    @State private var validationErrors: [String] = []
    
    let locations = ["outdoor", "indoor"]
    let greenTypes = ["couch", "tift", "bent", "synthetic", "carpet"]
    let weatherOptions = ["cold", "warm", "hot"]
    let windOptions = ["no_wind", "light", "moderate", "strong"]
    
    var onSessionCreated: ((TrainingSession) -> Void)?
    
    init(onSessionCreated: ((TrainingSession) -> Void)? = nil) {
        self.onSessionCreated = onSessionCreated
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
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
                        
                        // Notes
                        TornyCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Session Notes (Optional)")
                                    .font(TornyFonts.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.tornyTextPrimary)
                                
                                ZStack(alignment: .topLeading) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.tornyLightBlue, lineWidth: 1)
                                        )
                                        .frame(height: 100)
                                    
                                    TextEditor(text: $notes)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextPrimary)
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
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
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
    
    private func validateForm() -> Bool {
        validationErrors.removeAll()
        
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
        
        // Validate notes length
        if notes.count > 500 {
            validationErrors.append("Notes must be 500 characters or less")
        }
        
        // For outdoor sessions, weather and wind are required (already set by defaults)
        // Indoor sessions should not have weather/wind (handled automatically)
        
        return validationErrors.isEmpty
    }
    
    private func createSession() {
        // Validate form first
        guard validateForm() else {
            alertMessage = validationErrors.joined(separator: "\n")
            showingAlert = true
            return
        }
        
        isLoading = true
        
        let sessionRequest = CreateSessionRequest(
            location: Location(rawValue: location) ?? .outdoor,
            greenType: GreenType(rawValue: greenType) ?? .bent,
            greenSpeed: greenSpeed,
            rinkNumber: rinkNumber.isEmpty ? nil : Int(rinkNumber),
            weather: location == "outdoor" ? Weather(rawValue: weather) : nil,
            windConditions: location == "outdoor" ? WindConditions(rawValue: windConditions) : nil,
            notes: notes.isEmpty ? nil : notes
        )
        
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
}

struct TrainingSetupView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingSetupView()
    }
}