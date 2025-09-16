import SwiftUI

struct SessionView: View {
    @ObservedObject private var apiService = APIService.shared
    @State private var currentSession: TrainingSession?
    @State private var showingNewSessionSheet = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let session = currentSession {
                    ActiveSessionView(session: session, onShotRecorded: refreshSession)
                } else {
                    EmptySessionView()
                }
            }
            .navigationTitle("Training Session")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(currentSession == nil ? "Start Session" : "End Session") {
                        if currentSession == nil {
                            showingNewSessionSheet = true
                        } else {
                            endSession()
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .sheet(isPresented: $showingNewSessionSheet) {
                NewSessionView(onSessionCreated: handleSessionCreated)
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func handleSessionCreated(_ session: TrainingSession) {
        currentSession = session
        showingNewSessionSheet = false
    }
    
    private func endSession() {
        currentSession = nil
    }
    
    private func refreshSession() {
        guard let sessionId = currentSession?.id else { return }
        
        isLoading = true
        Task {
            do {
                let response = try await apiService.getSessionDetails(sessionId)
                await MainActor.run {
                    currentSession = response.session
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
}

struct EmptySessionView: View {
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "sportscourt")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("No Active Session")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start a new training session to begin recording your shots and tracking your progress.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct ActiveSessionView: View {
    let session: TrainingSession
    let onShotRecorded: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            SessionInfoCard(session: session)
            
            if let stats = sessionStats {
                SessionStatsCard(stats: stats)
            }
            
            NavigationLink(destination: ShotRecordingView(session: session, onShotRecorded: onShotRecorded)) {
                HStack {
                    Image(systemName: "target")
                    Text("Record Shot")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    private var sessionStats: SessionStatistics? {
        guard let totalShots = session.totalShots,
              let drawShots = session.drawShots,
              let weightedShots = session.weightedShots,
              let drawAccuracy = session.drawAccuracy,
              let weightedAccuracy = session.weightedAccuracy,
              let overallAccuracy = session.overallAccuracy else {
            return nil
        }
        
        let successfulShots = Int(Double(totalShots) * overallAccuracy / 100.0)
        
        return SessionStatistics(
            totalShots: totalShots,
            totalPoints: "\(successfulShots)",
            maxPossiblePoints: totalShots,
            averageScore: String(format: "%.2f", overallAccuracy),
            accuracyPercentage: "\(overallAccuracy)",
            drawShots: "\(drawShots)",
            drawPoints: "\(Int(Double(drawShots) * drawAccuracy / 100.0))",
            drawAccuracyPercentage: "\(drawAccuracy)",
            yardOnShots: "0",
            yardOnPoints: "0",
            yardOnAccuracyPercentage: nil,
            ditchWeightShots: "0",
            ditchWeightPoints: "0",
            ditchWeightAccuracyPercentage: nil,
            driveShots: "0",
            drivePoints: "0",
            driveAccuracyPercentage: nil,
            weightedShots: "\(weightedShots)",
            weightedPoints: "\(Int(Double(weightedShots) * weightedAccuracy / 100.0))",
            weightedAccuracyPercentage: "\(weightedAccuracy)"
        )
    }
}

struct SessionInfoCard: View {
    let session: TrainingSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Session Info")
                    .font(.headline)
                Spacer()
                Text(session.sessionDate, style: .time)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label(session.location.rawValue.capitalized, systemImage: session.location == .outdoor ? "sun.max" : "house")
                Spacer()
                Label(session.greenType.rawValue.capitalized, systemImage: "leaf")
            }
            .font(.subheadline)
            
            HStack {
                Label("Speed: \(session.greenSpeed)s", systemImage: "speedometer")
                Spacer()
                if let rink = session.rinkNumber {
                    Label("Rink \(rink)", systemImage: "number")
                }
            }
            .font(.subheadline)
            
            if session.location == .outdoor {
                HStack {
                    if let weather = session.weather {
                        Label(weather.rawValue.capitalized, systemImage: "thermometer")
                    }
                    Spacer()
                    if let wind = session.windConditions {
                        Label(wind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized, systemImage: "wind")
                    }
                }
                .font(.subheadline)
            }
            
            if let notes = session.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SessionStatsCard: View {
    let stats: SessionStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Stats")
                .font(.headline)
            
            HStack {
                StatItem(title: "Total Shots", value: "\(stats.totalShots)")
                Spacer()
                StatItem(title: "Draw Shots", value: "\(stats.drawShots)")
                Spacer()
                StatItem(title: "Weighted", value: "\(stats.weightedShots)")
            }
            
            HStack {
                AccuracyItem(title: "Draw", accuracy: stats.drawAccuracy)
                Spacer()
                AccuracyItem(title: "Weighted", accuracy: stats.weightedAccuracy)
                Spacer()
                AccuracyItem(title: "Overall", accuracy: stats.overallAccuracy, isMain: true)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct AccuracyItem: View {
    let title: String
    let accuracy: Double
    let isMain: Bool
    
    init(title: String, accuracy: Double, isMain: Bool = false) {
        self.title = title
        self.accuracy = accuracy
        self.isMain = isMain
    }
    
    var body: some View {
        VStack {
            Text(String(format: "%.1f%%", accuracy))
                .font(isMain ? .title2 : .subheadline)
                .fontWeight(isMain ? .bold : .semibold)
                .foregroundColor(isMain ? .green : .primary)
            Text("\(title) Accuracy")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct NewSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var apiService = APIService.shared
    
    @State private var location: Location = .outdoor
    @State private var greenType: GreenType = .bent
    @State private var greenSpeed: Double = 14
    @State private var rinkNumber: String = ""
    @State private var weather: Weather = .warm
    @State private var windConditions: WindConditions = .light
    @State private var notes: String = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let onSessionCreated: (TrainingSession) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Green Conditions") {
                    Picker("Location", selection: $location) {
                        ForEach(Location.allCases, id: \.self) { location in
                            Text(location.rawValue.capitalized).tag(location)
                        }
                    }
                    
                    Picker("Green Type", selection: $greenType) {
                        ForEach(GreenType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    
                    HStack {
                        Text("Green Speed")
                        Spacer()
                        Text("\(Int(greenSpeed)) seconds")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $greenSpeed, in: 8...22, step: 1)
                    
                    HStack {
                        Text("Rink Number")
                        TextField("Optional", text: $rinkNumber)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                if location == .outdoor {
                    Section("Weather Conditions") {
                        Picker("Weather", selection: $weather) {
                            ForEach(Weather.allCases, id: \.self) { weather in
                                Text(weather.rawValue.capitalized).tag(weather)
                            }
                        }
                        
                        Picker("Wind", selection: $windConditions) {
                            ForEach(WindConditions.allCases, id: \.self) { wind in
                                Text(wind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized).tag(wind)
                            }
                        }
                    }
                }
                
                Section("Notes") {
                    TextField("Optional session notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Start") {
                        startSession()
                    }
                    .disabled(isLoading)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func startSession() {
        isLoading = true
        
        let request = CreateSessionRequest(
            location: location,
            greenType: greenType,
            greenSpeed: Int(greenSpeed),
            rinkNumber: rinkNumber.isEmpty ? nil : Int(rinkNumber),
            weather: location == .outdoor ? weather : nil,
            windConditions: location == .outdoor ? windConditions : nil,
            notes: notes.isEmpty ? nil : notes
        )
        
        Task {
            do {
                let response = try await apiService.createSession(request)
                await MainActor.run {
                    onSessionCreated(response.session)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
    }
}