import SwiftUI

struct TrainingSessionView: View {
    @ObservedObject private var apiService = APIService.shared
    let session: TrainingSession
    let onSessionEnd: (() -> Void)?
    @State private var currentShot = ShotData()
    @State private var sessionStats = SessionStats(totalShots: 0, successfulShots: 0, accuracyPercentage: 0.0)
    @State private var isRecording = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSessionEnd = false
    
    let shotTypes = ["draw", "yard_on", "ditch_weight", "drive"]
    let hands = ["forehand", "backhand"]
    let lengths = ["short", "medium", "long"]
    let distanceOptions = ["foot", "yard"]
    
    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()
                
                VStack(spacing: 0) {
                    // Session Info Header
                    sessionInfoHeader
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Live Stats
                            liveStatsCard
                            
                            // Shot Recording Form
                            shotRecordingForm
                            
                            // Record Shot Button
                            recordShotButton
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingSessionEnd) {
            SessionEndView(session: session, stats: sessionStats, onReturn: onSessionEnd)
        }
    }
    
    private var sessionInfoHeader: some View {
        HStack {
            Button(action: {
                showingSessionEnd = true
            }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.tornyTextPrimary)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Training Session")
                    .font(TornyFonts.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.tornyTextPrimary)
                
                Text("\(session.greenType.rawValue.capitalized) • \(session.greenSpeed)s • \(session.location.rawValue.capitalized)")
                    .font(TornyFonts.bodySecondary)
                    .foregroundColor(.tornyTextSecondary)
            }
            
            Spacer()
            
            Button(action: {
                showingSessionEnd = true
            }) {
                Text("End")
                    .font(TornyFonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(.tornyBlue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white.shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1))
    }
    
    private var liveStatsCard: some View {
        TornyCard {
            HStack {
                StatItem(
                    title: "Total Shots",
                    value: "\(sessionStats.totalShots)",
                    color: .tornyBlue
                )
                
                Divider()
                    .frame(height: 40)
                
                StatItem(
                    title: "Successful",
                    value: "\(sessionStats.successfulShots)",
                    color: .tornyGreen
                )
                
                Divider()
                    .frame(height: 40)
                
                StatItem(
                    title: "Accuracy",
                    value: "\(Int(sessionStats.accuracyPercentage))%",
                    color: .tornyPurple
                )
            }
        }
    }
    
    private var shotRecordingForm: some View {
        TornyCard {
            VStack(alignment: .leading, spacing: 20) {
                Text("Record Shot")
                    .font(TornyFonts.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.tornyTextPrimary)
                
                // Shot Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Shot Type")
                        .font(TornyFonts.body)
                        .fontWeight(.medium)
                        .foregroundColor(.tornyTextPrimary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(shotTypes, id: \.self) { type in
                            Button(action: {
                                currentShot.shotType = type
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: shotTypeIcon(for: type))
                                        .font(.title2)
                                        .foregroundColor(currentShot.shotType == type ? .white : .tornyBlue)
                                    
                                    Text(shotTypeDisplayName(for: type))
                                        .font(TornyFonts.bodySecondary)
                                        .foregroundColor(currentShot.shotType == type ? .white : .tornyTextPrimary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(currentShot.shotType == type ? Color.tornyBlue : Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(currentShot.shotType == type ? Color.tornyBlue : Color.tornyLightBlue, lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Hand and Length
                HStack(spacing: 16) {
                    // Hand
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hand")
                            .font(TornyFonts.body)
                            .fontWeight(.medium)
                            .foregroundColor(.tornyTextPrimary)
                        
                        VStack(spacing: 8) {
                            ForEach(hands, id: \.self) { hand in
                                Button(action: {
                                    currentShot.hand = hand
                                }) {
                                    HStack {
                                        Image(systemName: currentShot.hand == hand ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(.tornyBlue)
                                        Text(hand.capitalized)
                                            .font(TornyFonts.body)
                                            .foregroundColor(.tornyTextPrimary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(currentShot.hand == hand ? Color.tornyBlue.opacity(0.1) : Color.clear)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Length
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Length")
                            .font(TornyFonts.body)
                            .fontWeight(.medium)
                            .foregroundColor(.tornyTextPrimary)
                        
                        VStack(spacing: 8) {
                            ForEach(lengths, id: \.self) { length in
                                Button(action: {
                                    currentShot.length = length
                                }) {
                                    HStack {
                                        Image(systemName: currentShot.length == length ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(.tornyBlue)
                                        Text(length.capitalized)
                                            .font(TornyFonts.body)
                                            .foregroundColor(.tornyTextPrimary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(currentShot.length == length ? Color.tornyBlue.opacity(0.1) : Color.clear)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Shot-specific fields
                if currentShot.shotType == "draw" {
                    drawShotFields
                } else if ["yard_on", "ditch_weight", "drive"].contains(currentShot.shotType) {
                    weightedShotFields
                }
                
                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (Optional)")
                        .font(TornyFonts.body)
                        .fontWeight(.medium)
                        .foregroundColor(.tornyTextPrimary)
                    
                    TextField("Add notes about this shot", text: $currentShot.notes)
                        .textFieldStyle(TornyTextFieldStyle())
                }
            }
        }
    }
    
    private var drawShotFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Distance from Jack")
                .font(TornyFonts.body)
                .fontWeight(.medium)
                .foregroundColor(.tornyTextPrimary)
            
            HStack(spacing: 12) {
                ForEach(distanceOptions, id: \.self) { distance in
                    Button(action: {
                        currentShot.distanceFromJack = distance
                    }) {
                        HStack {
                            Image(systemName: currentShot.distanceFromJack == distance ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(distance == "foot" ? .tornyGreen : .tornyPurple)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(distance == "foot" ? "Within Foot" : "Within Yard")
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextPrimary)
                                
                                Text(distance == "foot" ? "Success!" : "Close")
                                    .font(TornyFonts.bodySecondary)
                                    .foregroundColor(distance == "foot" ? .tornyGreen : .tornyTextSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(currentShot.distanceFromJack == distance ? Color.tornyBlue.opacity(0.1) : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(currentShot.distanceFromJack == distance ? Color.tornyBlue : Color.tornyLightBlue, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var weightedShotFields: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Hit Target?")
                    .font(TornyFonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(.tornyTextPrimary)
                
                HStack(spacing: 12) {
                    Button(action: {
                        currentShot.hitTarget = true
                        currentShot.withinFoot = nil // Clear this when hit target is true
                    }) {
                        HStack {
                            Image(systemName: currentShot.hitTarget == true ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(.tornyGreen)
                            Text("Yes - Success!")
                                .font(TornyFonts.body)
                                .foregroundColor(.tornyTextPrimary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(currentShot.hitTarget == true ? Color.tornyGreen.opacity(0.1) : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(currentShot.hitTarget == true ? Color.tornyGreen : Color.tornyLightBlue, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        currentShot.hitTarget = false
                    }) {
                        HStack {
                            Image(systemName: currentShot.hitTarget == false ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(.tornyPurple)
                            Text("No - Missed")
                                .font(TornyFonts.body)
                                .foregroundColor(.tornyTextPrimary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(currentShot.hitTarget == false ? Color.tornyPurple.opacity(0.1) : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(currentShot.hitTarget == false ? Color.tornyPurple : Color.tornyLightBlue, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Within foot option (only if missed target)
            if currentShot.hitTarget == false {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Within a Foot of Target?")
                        .font(TornyFonts.body)
                        .fontWeight(.medium)
                        .foregroundColor(.tornyTextPrimary)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            currentShot.withinFoot = true
                        }) {
                            HStack {
                                Image(systemName: currentShot.withinFoot == true ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.tornyBlue)
                                Text("Yes")
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextPrimary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            currentShot.withinFoot = false
                        }) {
                            HStack {
                                Image(systemName: currentShot.withinFoot == false ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.tornyBlue)
                                Text("No")
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextPrimary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    private var recordShotButton: some View {
        Button(action: recordShot) {
            HStack {
                if isRecording {
                    TornyLoadingView(color: .white)
                    Text("Recording...")
                } else {
                    Image(systemName: "plus.circle.fill")
                    Text("Record Shot")
                }
            }
        }
        .buttonStyle(TornyPrimaryButton(isLarge: true))
        .frame(maxWidth: .infinity)
        .disabled(isRecording || !currentShot.isValid)
    }
    
    private func shotTypeIcon(for type: String) -> String {
        switch type {
        case "draw": return "target"
        case "yard_on": return "arrow.forward.circle"
        case "ditch_weight": return "arrow.down.circle"
        case "drive": return "bolt.circle"
        default: return "target"
        }
    }
    
    private func shotTypeDisplayName(for type: String) -> String {
        switch type {
        case "yard_on": return "Yard On"
        case "ditch_weight": return "Ditch Weight"
        default: return type.capitalized
        }
    }
    
    private func recordShot() {
        isRecording = true
        
        let shotRequest = RecordShotRequest(
            sessionId: session.id,
            shotType: ShotType(rawValue: currentShot.shotType) ?? .draw,
            hand: Hand(rawValue: currentShot.hand) ?? .forehand,
            length: Length(rawValue: currentShot.length) ?? .medium,
            distanceFromJack: currentShot.shotType == "draw" ? DistanceFromJack(rawValue: currentShot.distanceFromJack ?? "") : nil,
            hitTarget: currentShot.shotType != "draw" ? currentShot.hitTarget : nil,
            withinFoot: currentShot.shotType != "draw" ? currentShot.withinFoot : nil,
            notes: currentShot.notes.isEmpty ? nil : currentShot.notes
        )
        
        Task {
            do {
                let response = try await apiService.recordShot(shotRequest)
                
                await MainActor.run {
                    isRecording = false
                    sessionStats = response.sessionStats
                    currentShot = ShotData() // Reset form
                }
            } catch {
                await MainActor.run {
                    isRecording = false
                    alertMessage = "Failed to record shot: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - Supporting Views and Models

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(TornyFonts.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(TornyFonts.bodySecondary)
                .foregroundColor(.tornyTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ShotData {
    var shotType: String = "draw"
    var hand: String = "forehand"
    var length: String = "medium"
    var distanceFromJack: String? = nil
    var hitTarget: Bool? = nil
    var withinFoot: Bool? = nil
    var notes: String = ""
    
    var isValid: Bool {
        if shotType == "draw" {
            return distanceFromJack != nil
        } else {
            return hitTarget != nil
        }
    }
}

struct SessionEndView: View {
    let session: TrainingSession
    let stats: SessionStats
    let onReturn: (() -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()
                
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.tornyGreen)
                        
                        Text("Session Complete!")
                            .font(TornyFonts.title1)
                            .fontWeight(.bold)
                            .foregroundColor(.tornyTextPrimary)
                        
                        Text("Great work on your training session")
                            .font(TornyFonts.body)
                            .foregroundColor(.tornyTextSecondary)
                    }
                    
                    TornyCard {
                        VStack(spacing: 20) {
                            Text("Session Summary")
                                .font(TornyFonts.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.tornyTextPrimary)
                            
                            HStack {
                                StatItem(
                                    title: "Total Shots",
                                    value: "\(stats.totalShots)",
                                    color: .tornyBlue
                                )
                                
                                Divider()
                                    .frame(height: 60)
                                
                                StatItem(
                                    title: "Successful",
                                    value: "\(stats.successfulShots)",
                                    color: .tornyGreen
                                )
                                
                                Divider()
                                    .frame(height: 60)
                                
                                StatItem(
                                    title: "Accuracy",
                                    value: "\(Int(stats.accuracyPercentage))%",
                                    color: .tornyPurple
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Button("Return to Dashboard") {
                        presentationMode.wrappedValue.dismiss()
                        onReturn?()
                    }
                    .buttonStyle(TornyPrimaryButton(isLarge: true))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
}

struct TrainingSessionView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleSession = TrainingSession(
            id: 1,
            playerId: 1,
            sport: "lawn_bowls",
            sessionDate: Date(),
            location: .outdoor,
            greenType: .bent,
            greenSpeed: 14,
            rinkNumber: 3,
            weather: .warm,
            windConditions: .light,
            notes: "Perfect conditions",
            createdAt: Date(),
            updatedAt: Date(),
            totalShots: nil,
            drawShots: nil,
            weightedShots: nil,
            drawAccuracy: nil,
            weightedAccuracy: nil,
            overallAccuracy: nil,
            startedAt: Date(),
            endedAt: nil,
            durationSeconds: nil,
            _isActive: 1
        )
        
        TrainingSessionView(session: sampleSession, onSessionEnd: nil)
    }
}