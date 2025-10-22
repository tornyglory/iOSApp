import SwiftUI
import Foundation

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
        ScrollView {
            VStack(spacing: 24) {
                // Shot Type Selection - 2x2 Grid
                VStack(alignment: .leading, spacing: 16) {
                    Text("Shot Type")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            ShotTypeCard(
                                title: "Draw",
                                icon: "target",
                                isSelected: shotType == .draw
                            ) {
                                shotType = .draw
                                resetShotSpecificFields()
                            }

                            ShotTypeCard(
                                title: "Yard On",
                                icon: "arrow.forward.circle",
                                isSelected: shotType == .yardOn
                            ) {
                                shotType = .yardOn
                                resetShotSpecificFields()
                            }
                        }

                        HStack(spacing: 12) {
                            ShotTypeCard(
                                title: "Ditch Weight",
                                icon: "arrow.down.circle",
                                isSelected: shotType == .ditchWeight
                            ) {
                                shotType = .ditchWeight
                                resetShotSpecificFields()
                            }

                            ShotTypeCard(
                                title: "Drive",
                                icon: "bolt.circle",
                                isSelected: shotType == .drive
                            ) {
                                shotType = .drive
                                resetShotSpecificFields()
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Hand and Length Selection
                HStack(spacing: 24) {
                    // Hand Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Hand")
                            .font(.headline)

                        VStack(spacing: 8) {
                            ForEach(Hand.allCases, id: \.self) { handOption in
                                HandOptionView(
                                    hand: handOption,
                                    isSelected: hand == handOption
                                ) {
                                    hand = handOption
                                }
                            }
                        }
                    }

                    // Length Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Length")
                            .font(.headline)

                        VStack(spacing: 8) {
                            ForEach(Length.allCases, id: \.self) { lengthOption in
                                LengthOptionView(
                                    length: lengthOption,
                                    isSelected: length == lengthOption
                                ) {
                                    length = lengthOption
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Distance from Jack (for draw shots)
                if shotType == .draw {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Distance from Jack")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            DistanceOptionCard(
                                title: "Within Foot",
                                subtitle: "Success!",
                                color: .green,
                                isSelected: distanceFromJack == .foot
                            ) {
                                distanceFromJack = .foot
                            }

                            DistanceOptionCard(
                                title: "Within Yard",
                                subtitle: "Close",
                                color: .blue,
                                isSelected: distanceFromJack == .yard
                            ) {
                                distanceFromJack = .yard
                            }

                            DistanceOptionCard(
                                title: "Miss",
                                subtitle: "Missed",
                                color: .red,
                                isSelected: distanceFromJack == .miss
                            ) {
                                distanceFromJack = .miss
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Notes Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notes (Optional)")
                        .font(.headline)
                        .padding(.horizontal)

                    TextField("Add notes about this shot", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                // Record Shot Button
                Button(action: recordShot) {
                    HStack {
                        if isLoading {
                            TornyButtonSpinner()
                        } else {
                            Image(systemName: "plus.circle.fill")
                        }
                        Text("Record Shot")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(16)
                }
                .disabled(isLoading)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Training Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("End") {
                    dismiss()
                }
                .foregroundColor(.blue)
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

// MARK: - Component Views

struct ShotTypeCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct HandOptionView: View {
    let hand: Hand
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .gray)

                Text(hand.rawValue.capitalized)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct LengthOptionView: View {
    let length: Length
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .gray)

                Text(length.rawValue.capitalized)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct DistanceOptionCard: View {
    let title: String
    let subtitle: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? color : .gray)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(color)
                }

                Spacer()
            }
            .padding()
            .background(isSelected ? color.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
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
                _drawShots: nil,
                _weightedShots: nil,
                drawAccuracy: nil,
                weightedAccuracy: nil,
                overallAccuracy: nil,
                startedAt: Date(),
                endedAt: nil,
                durationSeconds: nil,
                _isActive: 1,
                _totalPoints: nil,
                _averageScore: nil,
                _accuracyPercentage: nil,
                _yardOnShots: nil,
                yardOnAccuracy: nil,
                _ditchWeightShots: nil,
                ditchWeightAccuracy: nil,
                _driveShots: nil,
                driveAccuracy: nil
            ),
            onShotRecorded: {}
        )
    }
}