import SwiftUI

struct ShotRecordingView: View {
    let session: TrainingSession
    let onShotRecorded: () -> Void
    
    @ObservedObject private var apiService = APIService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var shotType: ShotType = .draw
    @State private var hand: Hand = .forehand
    @State private var length: Length = .medium
    @State private var distanceFromJack: DistanceFromJack = .yard
    @State private var hitTarget: Bool = false
    @State private var withinFoot: Bool = false
    @State private var notes: String = ""
    
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Shot Details") {
                    Picker("Shot Type", selection: $shotType) {
                        ForEach(ShotType.allCases, id: \.self) { type in
                            Text(shotTypeDisplayName(type)).tag(type)
                        }
                    }
                    .onChange(of: shotType) { _ in
                        resetShotSpecificFields()
                    }
                    
                    Picker("Hand", selection: $hand) {
                        ForEach(Hand.allCases, id: \.self) { hand in
                            Text(hand.rawValue.capitalized).tag(hand)
                        }
                    }
                    
                    Picker("Length", selection: $length) {
                        ForEach(Length.allCases, id: \.self) { length in
                            Text(length.rawValue.capitalized).tag(length)
                        }
                    }
                }
                
                // Shot-specific fields
                if shotType == .draw {
                    DrawShotSection(distanceFromJack: $distanceFromJack)
                } else {
                    WeightedShotSection(
                        hitTarget: $hitTarget,
                        withinFoot: $withinFoot
                    )
                }
                
                Section("Notes") {
                    TextField("Optional shot notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section {
                    ShotPreview(
                        shotType: shotType,
                        hand: hand,
                        length: length,
                        distanceFromJack: shotType == .draw ? distanceFromJack : nil,
                        hitTarget: shotType != .draw ? hitTarget : nil,
                        success: calculateSuccess()
                    )
                }
            }
            .navigationTitle("Record Shot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Record") {
                        recordShot()
                    }
                    .disabled(isLoading)
                }
            }
            .alert("Success", isPresented: $showingSuccessAlert) {
                Button("Record Another") {
                    resetForm()
                }
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Shot recorded successfully!")
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func shotTypeDisplayName(_ type: ShotType) -> String {
        switch type {
        case .draw: return "Draw"
        case .yardOn: return "Yard On"
        case .ditchWeight: return "Ditch Weight"
        case .drive: return "Drive"
        }
    }
    
    private func calculateSuccess() -> Bool {
        if shotType == .draw {
            return distanceFromJack == .foot
        } else {
            return hitTarget
        }
    }
    
    private func resetShotSpecificFields() {
        distanceFromJack = .yard
        hitTarget = false
        withinFoot = false
    }
    
    private func resetForm() {
        shotType = .draw
        hand = .forehand
        length = .medium
        distanceFromJack = .yard
        hitTarget = false
        withinFoot = false
        notes = ""
    }
    
    private func recordShot() {
        isLoading = true
        
        let request = RecordShotRequest(
            sessionId: session.id,
            shotType: shotType,
            hand: hand,
            length: length,
            distanceFromJack: distanceFromJack,
            notes: notes.isEmpty ? nil : notes
        )
        
        Task {
            do {
                _ = try await apiService.recordShot(request)
                await MainActor.run {
                    onShotRecorded()
                    showingSuccessAlert = true
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

struct DrawShotSection: View {
    @Binding var distanceFromJack: DistanceFromJack
    
    var body: some View {
        Section("Draw Shot Result") {
            Picker("Distance from Jack", selection: $distanceFromJack) {
                Text("Within 1 foot ✓").tag(DistanceFromJack.foot)
                Text("More than 1 foot").tag(DistanceFromJack.yard)
            }
            .pickerStyle(.segmented)
            
            HStack {
                Image(systemName: distanceFromJack == .foot ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(distanceFromJack == .foot ? .green : .red)
                Text(distanceFromJack == .foot ? "Successful shot" : "Unsuccessful shot")
                    .foregroundColor(distanceFromJack == .foot ? .green : .red)
                Spacer()
            }
            .font(.subheadline)
        }
    }
}

struct WeightedShotSection: View {
    @Binding var hitTarget: Bool
    @Binding var withinFoot: Bool
    
    var body: some View {
        Section("Weighted Shot Result") {
            Toggle("Hit Target", isOn: $hitTarget)
                .onChange(of: hitTarget) { newValue in
                    if newValue {
                        withinFoot = false
                    }
                }
            
            if !hitTarget {
                Toggle("Within 1 foot of target", isOn: $withinFoot)
            }
            
            HStack {
                Image(systemName: hitTarget ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(hitTarget ? .green : .red)
                Text(hitTarget ? "Successful shot" : "Unsuccessful shot")
                    .foregroundColor(hitTarget ? .green : .red)
                Spacer()
            }
            .font(.subheadline)
        }
    }
}

struct ShotPreview: View {
    let shotType: ShotType
    let hand: Hand
    let length: Length
    let distanceFromJack: DistanceFromJack?
    let hitTarget: Bool?
    let success: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shot Summary")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(shotTypeDisplayName) • \(hand.rawValue.capitalized) • \(length.rawValue.capitalized)")
                        .font(.subheadline)
                    
                    if let distanceFromJack = distanceFromJack {
                        Text("Distance: \(distanceDisplayName(distanceFromJack))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let hitTarget = hitTarget {
                        Text("Hit target: \(hitTarget ? "Yes" : "No")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(success ? .green : .red)
                    Text(success ? "Success" : "Miss")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(success ? .green : .red)
                }
            }
        }
        .padding()
        .background(success ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var shotTypeDisplayName: String {
        switch shotType {
        case .draw: return "Draw"
        case .yardOn: return "Yard On"
        case .ditchWeight: return "Ditch Weight"
        case .drive: return "Drive"
        }
    }
    
    private func distanceDisplayName(_ distance: DistanceFromJack) -> String {
        switch distance {
        case .foot: return "Within 1 foot"
        case .yard: return "More than 1 foot"
        case .miss: return "Missed completely"
        }
    }
    
}

struct ShotRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        ShotRecordingView(
            session: TrainingSession(
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
                notes: "Test session",
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
            ),
            onShotRecorded: {}
        )
    }
}