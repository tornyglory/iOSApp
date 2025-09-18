import SwiftUI
import Foundation

struct SessionHistoryView: View {
    @ObservedObject private var apiService = APIService.shared
    @State private var sessions: [TrainingSession] = []
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var hasMoreSessions = true
    @State private var currentOffset = 0
    @Environment(\.dismiss) private var dismiss

    private let pageSize = 20

    var body: some View {
        NavigationView {
            List {
                ForEach(sessions) { session in
                    NavigationLink(destination: SessionDetailView(session: session)) {
                        SessionRowView(session: session)
                    }
                }

                if hasMoreSessions && !sessions.isEmpty {
                    LoadMoreRow(isLoading: isLoading, loadMore: loadMoreSessions)
                }
            }
            .navigationTitle("Session History")
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
            .refreshable {
                await loadSessionsAsync(refresh: true)
            }
            .task {
                if sessions.isEmpty {
                    await loadSessionsAsync()
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .overlay {
                if sessions.isEmpty && !isLoading {
                    EmptyHistoryView()
                }
            }
        }
    }

    private func loadMoreSessions() {
        guard !isLoading && hasMoreSessions else { return }

        Task {
            await loadSessionsAsync()
        }
    }

    private func loadSessionsAsync(refresh: Bool = false) async {
        if refresh {
            currentOffset = 0
            sessions.removeAll()
            hasMoreSessions = true
        }

        isLoading = true

        do {
            let response = try await apiService.getSessions(
                limit: pageSize,
                offset: currentOffset
            )

            await MainActor.run {
                if refresh {
                    sessions = response.sessions
                } else {
                    sessions.append(contentsOf: response.sessions)
                }

                currentOffset += response.sessions.count
                hasMoreSessions = response.pagination.hasMore
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

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No Training Sessions")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start your first training session to see your history here.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }
}

struct LoadMoreRow: View {
    let isLoading: Bool
    let loadMore: () -> Void

    var body: some View {
        HStack {
            Spacer()
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Button("Load More") {
                    loadMore()
                }
                .font(.caption)
            }
            Spacer()
        }
        .padding()
        .onAppear {
            if !isLoading {
                loadMore()
            }
        }
    }
}

// MARK: - Session Row Components

struct SessionRowView: View {
    let session: TrainingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.sessionDate, style: .date)
                        .font(.headline)
                    Text(session.sessionDate, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let duration = session.durationSeconds, duration > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatDuration(duration))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }

                if let accuracy = session.overallAccuracy {
                    AccuracyBadge(accuracy: accuracy)
                }
            }

            HStack {
                SessionInfoPill(
                    icon: session.location == .outdoor ? "sun.max" : "house",
                    text: session.location.rawValue.capitalized
                )

                SessionInfoPill(
                    icon: "leaf",
                    text: session.greenType.rawValue.capitalized
                )

                SessionInfoPill(
                    icon: "speedometer",
                    text: "\(session.greenSpeed)s"
                )

                Spacer()
            }

            if let totalShots = session.totalShots {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(totalShots) total shots")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        if let accuracy = session.overallAccuracy {
                            Text("\(Int(accuracy))% accuracy")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }

                    HStack(spacing: 8) {
                        if let drawShots = session.drawShots, drawShots > 0 {
                            ShotTypePill(
                                title: "Draw",
                                count: drawShots,
                                accuracy: session.drawAccuracy,
                                color: .blue
                            )
                        }

                        if let yardOnShots = session.yardOnShots, yardOnShots > 0 {
                            ShotTypePill(
                                title: "Yard On",
                                count: yardOnShots,
                                accuracy: session.yardOnAccuracy,
                                color: .green
                            )
                        }

                        if let ditchWeightShots = session.ditchWeightShots, ditchWeightShots > 0 {
                            ShotTypePill(
                                title: "Ditch",
                                count: ditchWeightShots,
                                accuracy: session.ditchWeightAccuracy,
                                color: .orange
                            )
                        }

                        if let driveShots = session.driveShots, driveShots > 0 {
                            ShotTypePill(
                                title: "Drive",
                                count: driveShots,
                                accuracy: session.driveAccuracy,
                                color: .purple
                            )
                        }

                        Spacer()
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
}

struct SessionInfoPill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray5))
        .cornerRadius(12)
    }
}

struct ShotTypePill: View {
    let title: String
    let count: Int
    let accuracy: Double?
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)

                Text("(\(count))")
                    .font(.caption2)
            }

            if let accuracy = accuracy {
                Text("\(Int(accuracy))%")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(8)
    }
}

struct AccuracyBadge: View {
    let accuracy: Double

    var body: some View {
        Text(String(format: "%.1f%%", accuracy))
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(accuracyColor.opacity(0.2))
            .foregroundColor(accuracyColor)
            .cornerRadius(8)
    }

    private var accuracyColor: Color {
        if accuracy >= 80 {
            return .green
        } else if accuracy >= 60 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Session Detail View

struct SessionDetailView: View {
    let session: TrainingSession
    @ObservedObject private var apiService = APIService.shared
    @State private var sessionDetail: SessionDetailResponse?
    @State private var isLoading = true
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading session details...")
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if let detail = sessionDetail {
                    SessionHeaderCard(session: detail.session)
                    SessionStatsDetailCard(stats: detail.statistics)

                    ScoringSystemCard()

                    if !detail.shotsByType.isEmpty {
                        ShotsByTypeCard(shotsByType: detail.shotsByType, statistics: detail.statistics)
                    }

                    if !detail.shots.isEmpty {
                        ShotListCard(shots: detail.shots)
                    }
                } else {
                    Text("Failed to load session details")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Delete Session", role: .destructive) {
                        showingDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .task {
            await loadSessionDetail()
        }
        .alert("Delete Session", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSession()
            }
        } message: {
            Text("This will permanently delete this session and all its shots. This action cannot be undone.")
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    private func loadSessionDetail() async {
        do {
            let detail = try await apiService.getSessionDetails(session.id)
            await MainActor.run {
                sessionDetail = detail
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

    private func deleteSession() {
        Task {
            do {
                _ = try await apiService.deleteSession(session.id)
                // Navigate back would be handled by navigation coordinator in a real app
            } catch {
                await MainActor.run {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
}

struct SessionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        SessionHistoryView()
    }
}

// MARK: - Session Detail Components

struct SessionHeaderCard: View {
    let session: TrainingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.sessionDate, style: .date)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(session.sessionDate, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Session #\(session.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let rink = session.rinkNumber {
                        Text("Rink \(rink)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(session.location.rawValue.capitalized, systemImage: session.location == .outdoor ? "sun.max" : "house")
                    Spacer()
                    Label(session.greenType.rawValue.capitalized, systemImage: "leaf")
                }

                HStack {
                    Label("Speed: \(session.greenSpeed)s", systemImage: "speedometer")
                    Spacer()
                    if let duration = session.durationSeconds, duration > 0 {
                        Label("Duration: \(formatDurationForDetails(duration))", systemImage: "clock")
                    }
                }

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
                }
            }
            .font(.subheadline)

            if let notes = session.notes, !notes.isEmpty {
                Divider()
                Text("Notes")
                    .font(.headline)
                Text(notes)
                    .font(.body)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func formatDurationForDetails(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
}

struct SessionStatsDetailCard: View {
    let stats: SessionStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Session Statistics")
                .font(.headline)

            HStack {
                VStack {
                    Text("\(stats.totalShots)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Total Shots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack {
                    Text("\(stats.successfulShots)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Successful")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack {
                    Text(String(format: "%.1f%%", stats.overallAccuracy))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            Text("Shot Type Breakdown")
                .font(.subheadline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                HStack {
                    ShotTypeDetailCard(
                        title: "Draw",
                        shots: stats.shotCountForType("draw"),
                        points: stats.pointsForType("draw"),
                        accuracy: stats.displayAccuracyForType("draw"),
                        color: .blue
                    )

                    ShotTypeDetailCard(
                        title: "Yard On",
                        shots: stats.shotCountForType("yard_on"),
                        points: stats.pointsForType("yard_on"),
                        accuracy: stats.displayAccuracyForType("yard_on"),
                        color: .green
                    )
                }

                HStack {
                    ShotTypeDetailCard(
                        title: "Ditch Weight",
                        shots: stats.shotCountForType("ditch_weight"),
                        points: stats.pointsForType("ditch_weight"),
                        accuracy: stats.displayAccuracyForType("ditch_weight"),
                        color: .orange
                    )

                    ShotTypeDetailCard(
                        title: "Drive",
                        shots: stats.shotCountForType("drive"),
                        points: stats.pointsForType("drive"),
                        accuracy: stats.displayAccuracyForType("drive"),
                        color: .purple
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ShotTypeDetailCard: View {
    let title: String
    let shots: String
    let points: String
    let accuracy: String?
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text(shots)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("shots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text(points)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    Text("points")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if let accuracy = accuracy, !accuracy.isEmpty {
                // Remove the % sign if present and convert to Double
                let cleanAccuracy = accuracy.replacingOccurrences(of: "%", with: "")
                if let accuracyValue = Double(cleanAccuracy) {
                    Text(String(format: "%.1f%%", accuracyValue))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                } else {
                    Text("0.0%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No shots")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ScoringSystemCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Scoring System")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("2 points")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    Text("Within a foot of the jack")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                        Text("1 point")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    Text("Within a yard of the jack")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("0 points")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    Text("Miss (beyond a yard)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBlue).opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemBlue).opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Shot Components

struct ShotListCard: View {
    let shots: [TrainingShot]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shot History (\(shots.count) shots)")
                .font(.headline)

            LazyVStack(spacing: 8) {
                ForEach(shots) { shot in
                    ShotRowView(shot: shot)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ShotRowView: View {
    let shot: TrainingShot

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(shotTypeDisplayName(shot.shotType))
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(shot.hand.rawValue.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)

                    Text(shot.length.rawValue.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }

                if let notes = shot.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let distance = shot.distanceFromJack {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(colorForDistance(distance))
                            .frame(width: 8, height: 8)
                        Text(distance.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(colorForDistance(distance))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(colorForDistance(distance).opacity(0.1))
                    .cornerRadius(8)
                } else {
                    Image(systemName: (shot.success ?? false) ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor((shot.success ?? false) ? .green : .red)
                }

                Text(shot.createdAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(backgroundColorForShot(shot))
        .cornerRadius(8)
    }

    private func colorForDistance(_ distance: DistanceFromJack) -> Color {
        switch distance {
        case .foot: return .green
        case .yard: return .orange
        case .miss: return .red
        }
    }

    private func backgroundColorForShot(_ shot: TrainingShot) -> Color {
        return colorForShotType(shot.shotType).opacity(0.1)
    }

    private func colorForShotType(_ type: ShotType) -> Color {
        switch type {
        case .draw: return .blue
        case .yardOn: return .green
        case .ditchWeight: return .orange
        case .drive: return .purple
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
}

struct ShotsByTypeCard: View {
    let shotsByType: [String: [TrainingShot]]
    let statistics: SessionStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Shot Breakdown")
                .font(.headline)

            ForEach(Array(shotsByType.keys.sorted()), id: \.self) { shotType in
                let shots = shotsByType[shotType] ?? []
                if !shots.isEmpty {
                    ShotTypeSection(shotType: shotType, shots: shots, statistics: statistics)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ShotTypeSection: View {
    let shotType: String
    let shots: [TrainingShot]
    let statistics: SessionStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(shotType.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(colorForShotType(shotType))

                Spacer()

                Text("\(shots.count) shots • \(totalPointsForShots(shots)) points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let breakdown = statistics.drawBreakdown, shotType == "draw" {
                DrawBreakdownView(breakdown: breakdown)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(shots) { shot in
                    CompactShotRowView(shot: shot)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func colorForShotType(_ type: String) -> Color {
        switch type {
        case "draw": return .blue
        case "yard_on": return .green
        case "ditch_weight": return .orange
        case "drive": return .purple
        default: return .gray
        }
    }

    private func totalPointsForShots(_ shots: [TrainingShot]) -> Int {
        return shots.compactMap { $0.score }.reduce(0, +)
    }
}

struct DrawBreakdownView: View {
    let breakdown: DrawBreakdown

    var body: some View {
        HStack(spacing: 16) {
            DrawBreakdownItem(label: "Foot", count: breakdown.foot, color: .green)
            DrawBreakdownItem(label: "Yard", count: breakdown.yard, color: .orange)
            DrawBreakdownItem(label: "Miss", count: breakdown.miss, color: .red)
        }
        .padding(.horizontal, 8)
    }
}

struct DrawBreakdownItem: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct CompactShotRowView: View {
    let shot: TrainingShot

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(shot.hand.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(shot.length.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(shot.score ?? 0) pts")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor((shot.score ?? 0) > 0 ? .green : .red)
                if let distance = shot.distanceFromJack {
                    HStack(spacing: 3) {
                        Circle()
                            .fill(colorForDistance(distance))
                            .frame(width: 6, height: 6)
                        Text(distance.rawValue.capitalized)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(colorForDistance(distance))
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(backgroundColorForShot(shot))
        .cornerRadius(6)
    }

    private func colorForDistance(_ distance: DistanceFromJack) -> Color {
        switch distance {
        case .foot: return .green
        case .yard: return .orange
        case .miss: return .red
        }
    }

    private func backgroundColorForShot(_ shot: TrainingShot) -> Color {
        return colorForShotType(shot.shotType).opacity(0.1)
    }

    private func colorForShotType(_ type: ShotType) -> Color {
        switch type {
        case .draw: return .blue
        case .yardOn: return .green
        case .ditchWeight: return .orange
        case .drive: return .purple
        }
    }
}
