import SwiftUI
import Foundation
import Charts

struct TrainingSessionView: View {
    @ObservedObject private var apiService = APIService.shared
    let session: TrainingSession
    let onSessionEnd: (() -> Void)?
    @State private var currentShot = ShotData()
    @State private var sessionStats = SessionStatistics(totalShots: 0, totalPoints: "0", maxPossiblePoints: 0, averageScore: "0.00", accuracyPercentage: "0.0", drawShots: "0", drawPoints: "0", drawAccuracyPercentage: nil, yardOnShots: "0", yardOnPoints: "0", yardOnAccuracyPercentage: nil, ditchWeightShots: "0", ditchWeightPoints: "0", ditchWeightAccuracyPercentage: nil, driveShots: "0", drivePoints: "0", driveAccuracyPercentage: nil, weightedShots: "0", weightedPoints: "0", weightedAccuracyPercentage: nil, drawBreakdown: nil)
    @State private var isRecording = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSessionEnd = false
    @State private var showingSuccessAlert = false
    @State private var successMessage = ""
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var chartData: ChartViewData?
    @State private var isLoadingChartData = false
    @State private var chartError: String?
    @State private var showCharts = false
    
    let shotTypes = ["draw", "yard_on", "ditch_weight", "drive"]
    let hands = ["forehand", "backhand"]
    let lengths = ["short", "medium", "long"]
    let distanceOptions = ["foot", "yard", "miss"]
    
    var body: some View {
        ZStack {
            TornyBackgroundView()

            VStack(spacing: 0) {
                    // Session Info Header
                    sessionInfoHeader
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Live Stats
                            liveStatsCard

                            // Charts toggle and display
                            chartsSection

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
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .alert("Shot Recorded!", isPresented: $showingSuccessAlert) {
            Button("Great!") { }
        } message: {
            Text(successMessage)
        }
        .sheet(isPresented: $showingSessionEnd) {
            SessionEndView(session: session, stats: sessionStats, onReturn: onSessionEnd)
                .onAppear {
                    print("📱 SessionEndView appeared")
                }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
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

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.tornyBlue)
                    Text(formatElapsedTime(elapsedTime))
                        .font(TornyFonts.bodySecondary)
                        .fontWeight(.medium)
                        .foregroundColor(.tornyBlue)
                }
            }
            
            Spacer()

            Button(action: {
                print("🔚 End button tapped - showing session end sheet")
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
                    value: "\(Int(Double(sessionStats.accuracyPercentage) ?? 0))%",
                    color: .tornyPurple
                )
            }
        }
    }

    private var chartsSection: some View {
        VStack(spacing: 16) {
            // Charts toggle button
            TornyCard {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showCharts.toggle()
                    }
                    // Fetch chart data when opening charts section
                    if showCharts {
                        fetchChartData()
                    }
                }) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title2)
                            .foregroundColor(.tornyBlue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Live Charts")
                                .font(TornyFonts.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.tornyTextPrimary)

                            Text("View real-time performance data")
                                .font(TornyFonts.bodySecondary)
                                .foregroundColor(.tornyTextSecondary)
                        }

                        Spacer()

                        Image(systemName: showCharts ? "chevron.up" : "chevron.down")
                            .font(.body)
                            .foregroundColor(.tornyTextSecondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Charts content
            if showCharts {
                if isLoadingChartData {
                    TornyCard {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Loading chart data...")
                                .font(TornyFonts.body)
                                .foregroundColor(.tornyTextSecondary)
                        }
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                    }
                } else if let error = chartError {
                    TornyCard {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundColor(.red)
                            Text("Chart Error")
                                .font(TornyFonts.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.tornyTextPrimary)
                            Text(error)
                                .font(TornyFonts.bodySecondary)
                                .foregroundColor(.tornyTextSecondary)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                fetchChartData()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    }
                } else if let chartViewData = chartData {
                    VStack(spacing: 12) {
                        // Refresh button
                        HStack {
                            Spacer()
                            Button(action: {
                                fetchChartData()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.caption)
                                    Text("Refresh Data")
                                        .font(TornyFonts.bodySecondary)
                                }
                                .foregroundColor(.tornyBlue)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.tornyBlue.opacity(0.1))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isLoadingChartData)
                        }
                        .padding(.horizontal)

                        LiveChartsComponent(chartData: chartViewData)
                            .transition(.opacity.combined(with: .scale))
                    }
                } else {
                    TornyCard {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.line.downtrend.xyaxis")
                                .font(.title)
                                .foregroundColor(.tornyTextSecondary)
                            Text("No chart data available")
                                .font(TornyFonts.body)
                                .foregroundColor(.tornyTextSecondary)
                        }
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                    }
                }
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
                
                // Distance from Jack (same for all shot types)
                distanceFromJackFields
                
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
    
    private var distanceFromJackFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Distance from Jack")
                .font(TornyFonts.body)
                .fontWeight(.medium)
                .foregroundColor(.tornyTextPrimary)
            
            VStack(spacing: 12) {
                ForEach(distanceOptions, id: \.self) { distance in
                    Button(action: {
                        currentShot.distanceFromJack = distance
                    }) {
                        HStack {
                            Image(systemName: currentShot.distanceFromJack == distance ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(distanceIconColor(for: distance))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(distanceDisplayName(for: distance))
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextPrimary)

                                Text(distanceDescription(for: distance))
                                    .font(TornyFonts.bodySecondary)
                                    .foregroundColor(distanceColor(for: distance))
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

    private func distanceDisplayName(for distance: String) -> String {
        switch distance {
        case "foot": return "Within Foot"
        case "yard": return "Within Yard"
        case "miss": return "Miss"
        default: return distance.capitalized
        }
    }

    private func distanceDescription(for distance: String) -> String {
        switch distance {
        case "foot": return "Success!"
        case "yard": return "Close"
        case "miss": return "Missed"
        default: return ""
        }
    }

    private func distanceColor(for distance: String) -> Color {
        switch distance {
        case "foot": return .tornyGreen
        case "yard": return .tornyTextSecondary
        case "miss": return .red
        default: return .tornyTextSecondary
        }
    }

    private func distanceIconColor(for distance: String) -> Color {
        switch distance {
        case "foot": return .tornyGreen
        case "yard": return .tornyPurple
        case "miss": return .red
        default: return .tornyBlue
        }
    }

    private func formatElapsedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        let seconds = Int(timeInterval) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func startTimer() {
        stopTimer() // Stop any existing timer

        if let startedAt = session.startedAt {
            elapsedTime = Date().timeIntervalSince(startedAt)
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startedAt = session.startedAt {
                elapsedTime = Date().timeIntervalSince(startedAt)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }


    // Helper function to calculate current and best streaks
    private func calculateStreaks(from shots: [ShotTypeSeries]) -> (current: Int, best: Int) {
        guard !shots.isEmpty else { return (0, 0) }

        var currentStreak = 0
        var bestStreak = 0
        var tempStreak = 0

        // Calculate streaks from the shot data (assuming shots are in chronological order)
        for shot in shots {
            if shot.score > 0 {
                tempStreak += 1
                bestStreak = max(bestStreak, tempStreak)
            } else {
                tempStreak = 0
            }
        }

        // Current streak is the streak at the end
        var reverseStreak = 0
        for shot in shots.reversed() {
            if shot.score > 0 {
                reverseStreak += 1
            } else {
                break
            }
        }

        currentStreak = reverseStreak
        return (currentStreak, bestStreak)
    }

    // Helper function to determine improvement trend
    private func determineTrend(from accuracyPoints: [AccuracyPointSimple]) -> String {
        guard accuracyPoints.count >= 2 else { return "stable" }

        let firstHalf = accuracyPoints.prefix(accuracyPoints.count / 2)
        let secondHalf = accuracyPoints.suffix(accuracyPoints.count / 2)

        let firstAvg = firstHalf.map(\.y).reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.map(\.y).reduce(0, +) / Double(secondHalf.count)

        let difference = secondAvg - firstAvg

        if difference > 5 {
            return "improving"
        } else if difference < -5 {
            return "declining"
        } else {
            return "stable"
        }
    }

    private func fetchChartData() {
        guard !isLoadingChartData else { return }

        isLoadingChartData = true
        chartError = nil

        Task {
            do {
                let response = try await apiService.getSessionChartData(session.id)

                await MainActor.run {
                    isLoadingChartData = false

                    // Convert the simple API response to our chart view data
                    let accuracyPoints = response.chartData.accuracyOverTime.map { point in
                        AccuracyPoint(
                            shotNumber: point.x,
                            cumulativeAccuracy: point.y,
                            timestamp: Date()
                        )
                    }

                    // Create shot type data from the shot type series
                    let shotTypeData: [ShotTypeData] = {
                        var typeMap: [String: (count: Int, totalScore: Int)] = [:]

                        for shot in response.chartData.shotTypeSeries {
                            let current = typeMap[shot.type] ?? (count: 0, totalScore: 0)
                            typeMap[shot.type] = (count: current.count + 1, totalScore: current.totalScore + shot.score)
                        }

                        let totalShots = max(response.totalShots, 1)

                        return typeMap.map { (type, data) in
                            let percentage = Double(data.count) / Double(totalShots) * 100.0
                            let maxPossibleScore = data.count * 2
                            let accuracy = maxPossibleScore > 0 ? (Double(data.totalScore) / Double(maxPossibleScore)) * 100.0 : 0.0

                            return ShotTypeData(
                                type: type,
                                count: data.count,
                                percentage: percentage,
                                averageAccuracy: accuracy
                            )
                        }
                    }()

                    // Calculate streaks from shot data
                    let (currentStreak, bestStreak) = calculateStreaks(from: response.chartData.shotTypeSeries)

                    // Calculate successful shots more accurately
                    let successfulShots = response.chartData.shotTypeSeries.filter { $0.score > 0 }.count

                    // Create performance metrics
                    let metrics = PerformanceMetrics(
                        totalShots: response.totalShots,
                        successfulShots: successfulShots,
                        overallAccuracy: response.overallAccuracy,
                        currentStreak: currentStreak,
                        bestStreak: bestStreak,
                        averageDistanceFromTarget: nil,
                        improvementTrend: determineTrend(from: response.chartData.accuracyOverTime)
                    )

                    // Parse dates
                    let dateFormatter = ISO8601DateFormatter()
                    let startTime = dateFormatter.date(from: response.startedAt) ?? Date()
                    let lastUpdated = dateFormatter.date(from: response.lastUpdated) ?? Date()

                    let metadata = ChartMetadata(
                        lastUpdated: lastUpdated,
                        sessionStartTime: startTime,
                        refreshIntervalSeconds: 0, // Manual refresh only
                        dataPoints: response.totalShots
                    )

                    // Create recent shots data from the last few shots
                    let recentShots = response.chartData.shotTypeSeries.suffix(5).map { shot in
                        let wasSuccessful = shot.score > 0
                        print("📊 Shot \(shot.x): type=\(shot.type), score=\(shot.score), successful=\(wasSuccessful)")

                        return RecentShotData(
                            shotNumber: shot.x,
                            type: shot.type,
                            points: shot.score,
                            distanceFromTarget: nil,
                            notes: nil,
                            timestamp: Date(),
                            wasSuccessful: wasSuccessful
                        )
                    }

                    chartData = ChartViewData(
                        accuracyPoints: accuracyPoints,
                        shotTypeData: shotTypeData,
                        metrics: metrics,
                        recentShots: Array(recentShots),
                        metadata: metadata
                    )
                }
            } catch {
                await MainActor.run {
                    isLoadingChartData = false
                    chartError = "Failed to load chart data: \(error.localizedDescription)"
                    print("❌ Chart data fetch error: \(error)")
                }
            }
        }
    }

    private func recordShot() {
        isRecording = true
        
        // Convert UI values to API format (same for all shot types)
        let distanceFromJack = DistanceFromJack(rawValue: currentShot.distanceFromJack ?? "miss") ?? .miss

        let shotRequest = RecordShotRequest(
            sessionId: session.id,
            shotType: ShotType(rawValue: currentShot.shotType) ?? .draw,
            hand: Hand(rawValue: currentShot.hand) ?? .forehand,
            length: Length(rawValue: currentShot.length) ?? .medium,
            distanceFromJack: distanceFromJack,
            notes: currentShot.notes.isEmpty ? nil : currentShot.notes
        )
        
        Task {
            do {
                let response = try await apiService.recordShot(shotRequest)
                
                await MainActor.run {
                    isRecording = false
                    sessionStats = response.sessionStats
                    currentShot.reset() // Reset form

                    // Show success message
                    let shotTypeDisplay = shotTypeDisplayName(for: shotRequest.shotType.rawValue)
                    let distanceDisplay = distanceDisplayName(for: distanceFromJack.rawValue)
                    successMessage = "\(shotTypeDisplay) shot recorded successfully!\nResult: \(distanceDisplay)"
                    showingSuccessAlert = true

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
    var notes: String = ""

    var isValid: Bool {
        return distanceFromJack != nil
    }

    mutating func reset() {
        shotType = "draw"
        hand = "forehand"
        length = "medium"
        distanceFromJack = nil
        notes = ""
    }
}

struct SessionEndView: View {
    let session: TrainingSession
    let stats: SessionStatistics
    let onReturn: (() -> Void)?
    @Environment(\.presentationMode) var presentationMode
    @State private var isEndingSession = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @ObservedObject private var apiService = APIService.shared
    
    var body: some View {
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
                                    value: "\(Int(Double(stats.accuracyPercentage) ?? 0))%",
                                    color: .tornyPurple
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Button(action: endSessionAndReturn) {
                        HStack {
                            if isEndingSession {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Ending Session...")
                            } else {
                                Text("Return to Dashboard")
                            }
                        }
                    }
                    .buttonStyle(TornyPrimaryButton(isLarge: true))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .disabled(isEndingSession)
                    
                    Spacer()
            }
            .padding(.top, 40)
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    private func endSessionAndReturn() {
        print("🚀 endSessionAndReturn called")
        isEndingSession = true

        Task {
            do {
                let now = Date()
                let duration = Int(now.timeIntervalSince(session.startedAt ?? now))
                let request = EndSessionRequest(
                    endedAt: ISO8601DateFormatter().string(from: now),
                    durationSeconds: duration
                )
                _ = try await apiService.endSession(session.id, request: request)

                await MainActor.run {
                    isEndingSession = false
                    presentationMode.wrappedValue.dismiss()
                    onReturn?()
                }
            } catch {
                await MainActor.run {
                    isEndingSession = false
                    alertMessage = "Failed to end session: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
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
        )
        
        TrainingSessionView(session: sampleSession, onSessionEnd: nil)
    }
}