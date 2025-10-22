import SwiftUI
import Foundation

struct TrainingSessionView: View {
    @ObservedObject private var apiService = APIService.shared
    let session: TrainingSession
    let onSessionEnd: (() -> Void)?
    @State private var currentShot = ShotData()
    @State private var sessionStats = SessionStatistics(totalShots: 0, totalPoints: "0", maxPossiblePoints: 0, averageScore: "0.00", accuracyPercentage: "0.0", drawShots: "0", drawPoints: "0", drawAccuracyPercentage: nil, yardOnShots: "0", yardOnPoints: "0", yardOnAccuracyPercentage: nil, ditchWeightShots: "0", ditchWeightPoints: "0", ditchWeightAccuracyPercentage: nil, driveShots: "0", drivePoints: "0", driveAccuracyPercentage: nil, weightedShots: "0", weightedPoints: "0", weightedAccuracyPercentage: nil, drawBreakdown: nil)
    @State private var isRecording = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSuccessAlert = false
    @State private var showingSessionEnd = false
    @State private var sessionTimer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var chartData: ChartViewData?
    @State private var isLoadingChartData = false
    @State private var chartDataError: String?
    @State private var showLiveCharts = false
    
    let shotTypes = ["draw", "yard_on", "ditch_weight", "drive"]
    let hands = ["forehand", "backhand"]
    let lengths = ["short", "medium", "long"]
    let distanceOptions = ["foot", "yard", "miss"]
    
    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()
                
                VStack(spacing: 0) {
                    // Session Info Header
                    sessionInfoHeader

                    ScrollView {
                        VStack(spacing: 16) {
                            // Live Stats
                            liveStatsCard

                            // Live Charts Toggle
                            liveChartsToggle

                            // Live Charts (if enabled)
                            if showLiveCharts {
                                liveChartsSection
                            }

                            // Shot Recording Form
                            shotRecordingForm
                            
                            // Record Shot Button
                            recordShotButton
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
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
        .alert("Shot Recorded!", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Your shot has been successfully recorded.")
        }
        .sheet(isPresented: $showingSessionEnd) {
            SessionEndView(session: session, stats: sessionStats, onReturn: onSessionEnd)
        }
        .onChange(of: showingSessionEnd) { isShowing in
            if isShowing {
                print("Session end sheet is being presented")
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
            // Left side - Session info
            VStack(alignment: .leading, spacing: 6) {
                Text("Training Session")
                    .font(TornyFonts.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.tornyTextPrimary)

                Text("\(session.greenType.rawValue.capitalized) • \(session.greenSpeed)s • \(session.location.rawValue.capitalized)")
                    .font(TornyFonts.bodySecondary)
                    .foregroundColor(.tornyTextSecondary)

                // Timer
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .foregroundColor(.tornyBlue)
                        .font(.caption)
                    Text(formattedTime)
                        .font(TornyFonts.body)
                        .fontWeight(.medium)
                        .foregroundColor(.tornyBlue)
                }
                .padding(.top, 2)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white.shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1))
        .overlay(
            // Overlay the button independently
            HStack {
                Spacer()

                Text("End")
                    .font(TornyFonts.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 70, height: 36)
                    .background(Color.tornyBlue)
                    .cornerRadius(8)
                    .onTapGesture {
                        print("End button tapped - ending session")
                        showingSessionEnd = true
                    }
            }
            .padding(.horizontal, 20)
        )
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
                    value: "\(self.calculateSuccessfulShots(from: sessionStats))",
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

    private var liveChartsToggle: some View {
        Button(action: {
            showLiveCharts.toggle()
            if showLiveCharts && chartData == nil {
                loadChartData()
            }
        }) {
            HStack {
                Image(systemName: showLiveCharts ? "chart.bar.fill" : "chart.bar")
                    .foregroundColor(.tornyBlue)

                Text(showLiveCharts ? "Hide Live Charts" : "Show Live Charts")
                    .font(TornyFonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(.tornyBlue)

                Spacer()

                Image(systemName: showLiveCharts ? "chevron.up" : "chevron.down")
                    .foregroundColor(.tornyBlue)
                    .font(.caption)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.tornyBlue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.tornyBlue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var liveChartsSection: some View {
        TornyCard {
            VStack(spacing: 0) {
                HStack {
                    Text("Live Charts")
                        .font(TornyFonts.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.tornyTextPrimary)

                    Spacer()

                    if isLoadingChartData {
                        TornyLoadingView()
                    } else {
                        Button(action: {
                            print("Refresh button tapped - loading chart data")
                            loadChartData()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                Text(chartDataError != nil ? "Retry" : "Refresh")
                            }
                            .font(TornyFonts.bodySecondary)
                            .foregroundColor(.tornyBlue)
                        }
                        .frame(minHeight: 32)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.tornyBlue.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                if let error = chartDataError {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title2)
                            .foregroundColor(.red)

                        Text("Failed to load chart data")
                            .font(TornyFonts.body)
                            .foregroundColor(.tornyTextPrimary)

                        Text(error)
                            .font(TornyFonts.bodySecondary)
                            .foregroundColor(.tornyTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                } else if let chartData = chartData {
                    LiveChartsComponent(chartData: chartData)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.title2)
                            .foregroundColor(.tornyTextSecondary)

                        Text("No chart data available")
                            .font(TornyFonts.body)
                            .foregroundColor(.tornyTextSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
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
                
                // Distance from Jack (for all shot types)
                drawShotFields
                
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
            
            VStack(spacing: 8) {
                ForEach(distanceOptions, id: \.self) { distance in
                    Button(action: {
                        currentShot.distanceFromJack = distance
                    }) {
                        HStack {
                            Image(systemName: currentShot.distanceFromJack == distance ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(distanceColor(for: distance))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(distanceDisplayName(for: distance))
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextPrimary)

                                Text(distanceSubtitle(for: distance))
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
                    TornyButtonSpinner()
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
        
        // Convert UI values to API format
        let distanceFromJack = DistanceFromJack(rawValue: currentShot.distanceFromJack ?? "yard") ?? .yard

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
                    currentShot = ShotData() // Reset form
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

    private func startTimer() {
        guard sessionTimer == nil else { return }

        let startTime = session.startedAt ?? Date()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(startTime)
        }
    }

    private func stopTimer() {
        sessionTimer?.invalidate()
        sessionTimer = nil
    }

    private var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func distanceDisplayName(for distance: String) -> String {
        switch distance {
        case "foot": return "Within Foot"
        case "yard": return "Within Yard"
        case "miss": return "Miss"
        default: return distance.capitalized
        }
    }

    private func distanceSubtitle(for distance: String) -> String {
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
        case "yard": return .tornyPurple
        case "miss": return .red
        default: return .tornyTextSecondary
        }
    }

    private func calculateSuccessfulShots(from stats: SessionStatistics) -> Int {
        let accuracy = Double(stats.accuracyPercentage) ?? 0.0
        return Int(round(Double(stats.totalShots) * accuracy / 100.0))
    }

    private func loadChartData() {
        print("loadChartData() called - starting to load")
        isLoadingChartData = true
        chartDataError = nil

        Task {
            do {
                let response = try await apiService.getLiveChartData(sessionId: session.id)

                await MainActor.run {
                    print("Chart data loaded successfully, transforming data")
                    isLoadingChartData = false

                    // Transform ChartDataSimple to ChartViewData
                    let accuracyPoints = response.chartData.accuracyOverTime.map { point in
                        AccuracyPoint(
                            shotNumber: point.x,
                            cumulativeAccuracy: point.y,
                            timestamp: ISO8601DateFormatter().date(from: point.timestamp) ?? Date()
                        )
                    }

                    // Transform shot type series into shot type data
                    let shotTypeCounts = Dictionary(grouping: response.chartData.shotTypeSeries, by: { $0.type })
                        .mapValues { shots in
                            (count: shots.count, totalScore: shots.reduce(0) { $0 + $1.score })
                        }

                    let totalShots = response.totalShots
                    let shotTypeData: [ShotTypeData] = shotTypeCounts.map { (type, data) in
                        let percentage = totalShots > 0 ? (Double(data.count) / Double(totalShots)) * 100.0 : 0.0
                        let averageAccuracy = data.count > 0 ? (Double(data.totalScore) / Double(data.count)) * 100.0 : 0.0

                        return ShotTypeData(
                            type: type,
                            count: data.count,
                            percentage: percentage,
                            averageAccuracy: averageAccuracy
                        )
                    }.sorted { $0.count > $1.count }

                    let metrics = PerformanceMetrics(
                        totalShots: response.totalShots,
                        successfulShots: Int(Double(response.totalShots) * response.overallAccuracy / 100.0),
                        overallAccuracy: response.overallAccuracy,
                        currentStreak: 0,
                        bestStreak: 0,
                        averageDistanceFromTarget: nil,
                        improvementTrend: "stable"
                    )

                    // Transform shot type series into recent shots (take the most recent ones)
                    let recentShots: [RecentShotData] = response.chartData.shotTypeSeries
                        .sorted { shot1, shot2 in
                            // Sort by shot number (x) in descending order to get most recent first
                            shot1.x > shot2.x
                        }
                        .prefix(10) // Take only the 10 most recent shots
                        .map { shot in
                            RecentShotData(
                                shotNumber: shot.x,
                                type: shot.type,
                                points: shot.score,
                                distanceFromTarget: nil,
                                notes: nil,
                                timestamp: ISO8601DateFormatter().date(from: shot.timestamp) ?? Date(),
                                wasSuccessful: shot.score > 0
                            )
                        }

                    let metadata = ChartMetadata(
                        lastUpdated: ISO8601DateFormatter().date(from: response.lastUpdated) ?? Date(),
                        sessionStartTime: ISO8601DateFormatter().date(from: response.startedAt) ?? Date(),
                        refreshIntervalSeconds: 30,
                        dataPoints: response.chartData.accuracyOverTime.count
                    )

                    chartData = ChartViewData(
                        accuracyPoints: accuracyPoints,
                        shotTypeData: shotTypeData,
                        metrics: metrics,
                        recentShots: recentShots,
                        metadata: metadata
                    )
                    print("Chart data updated with \(accuracyPoints.count) accuracy points, \(shotTypeData.count) shot types")
                }
            } catch {
                print("Error loading chart data: \(error)")
                await MainActor.run {
                    isLoadingChartData = false
                    chartDataError = error.localizedDescription
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
}

struct SessionEndView: View {
    let session: TrainingSession
    let stats: SessionStatistics
    let onReturn: (() -> Void)?
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var apiService = APIService.shared
    @State private var sessionNotes: String = ""
    @State private var isEnding = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()

                ScrollView {
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
                        .padding(.top, 40)

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
                                        value: "\(self.calculateSuccessfulShots(from: stats))",
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

                        // Session Notes
                        TornyCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Session Notes (Optional)")
                                        .font(TornyFonts.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.tornyTextPrimary)

                                    Spacer()

                                    // Voice input indicator
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.tornyBlue)
                                }

                                HStack {
                                    Text("Tap the microphone on your keyboard to use voice-to-text")
                                        .font(TornyFonts.caption)
                                        .foregroundColor(.tornyTextSecondary)

                                    Spacer()

                                    Text("\(sessionNotes.count)/3000")
                                        .font(TornyFonts.caption)
                                        .foregroundColor(sessionNotes.count > 2800 ? .orange : .tornyTextSecondary)
                                }

                                ZStack(alignment: .topLeading) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.tornyLightBlue, lineWidth: 1)
                                        )
                                        .frame(height: 120)

                                    if sessionNotes.isEmpty {
                                        Text("e.g., 'Rink 3, green running at 14 seconds, slight headwind...'")
                                            .font(TornyFonts.body)
                                            .foregroundColor(.tornyTextSecondary.opacity(0.5))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 16)
                                            .allowsHitTesting(false)
                                    }

                                    TextEditor(text: $sessionNotes)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextPrimary)
                                        .scrollContentBackground(.hidden)
                                        .onChange(of: sessionNotes) { newValue in
                                            if newValue.count > 3000 {
                                                sessionNotes = String(newValue.prefix(3000))
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        Button(action: endSession) {
                            HStack {
                                if isEnding {
                                    TornyButtonSpinner()
                                } else {
                                    Text("End Session & Return to Dashboard")
                                }
                            }
                        }
                        .buttonStyle(TornyPrimaryButton(isLarge: true))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .disabled(isEnding)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func endSession() {
        isEnding = true

        Task {
            do {
                let now = Date()
                let sessionStart = session.sessionDate
                let duration = Int(now.timeIntervalSince(sessionStart))

                let request = EndSessionRequest(
                    endedAt: ISO8601DateFormatter().string(from: now),
                    durationSeconds: duration,
                    notes: sessionNotes.isEmpty ? nil : sessionNotes
                )

                _ = try await apiService.endSession(session.id, request: request)

                await MainActor.run {
                    isEnding = false
                    presentationMode.wrappedValue.dismiss()
                    onReturn?()
                }
            } catch {
                await MainActor.run {
                    isEnding = false
                    errorMessage = "Failed to end session: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }

    private func calculateSuccessfulShots(from stats: SessionStatistics) -> Int {
        let accuracy = Double(stats.accuracyPercentage) ?? 0.0
        return Int(round(Double(stats.totalShots) * accuracy / 100.0))
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