import SwiftUI

struct SessionHistoryView: View {
    @ObservedObject private var apiService = APIService.shared
    @State private var sessions: [TrainingSession] = []
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var hasMoreSessions = true
    @State private var currentOffset = 0
    
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
                    
                    // Shot type breakdown
                    HStack(spacing: 12) {
                        if let drawShots = session.drawShots, drawShots > 0 {
                            ShotTypePill(
                                title: "Draw",
                                count: drawShots,
                                accuracy: session.drawAccuracy,
                                color: .blue
                            )
                        }
                        
                        if let weightedShots = session.weightedShots, weightedShots > 0 {
                            ShotTypePill(
                                title: "Weighted",
                                count: weightedShots,
                                accuracy: session.weightedAccuracy,
                                color: .orange
                            )
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(.vertical, 4)
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
        HStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
            
            Text("(\(count))")
                .font(.caption2)
            
            if let accuracy = accuracy {
                Text("\(Int(accuracy))%")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
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
                        accuracy: stats.displayAccuracyForType("draw"),
                        color: .blue
                    )
                    
                    ShotTypeDetailCard(
                        title: "Yard On",
                        shots: stats.shotCountForType("yard_on"),
                        accuracy: stats.displayAccuracyForType("yard_on"),
                        color: .green
                    )
                }
                
                HStack {
                    ShotTypeDetailCard(
                        title: "Ditch Weight",
                        shots: stats.shotCountForType("ditch_weight"),
                        accuracy: stats.displayAccuracyForType("ditch_weight"),
                        color: .orange
                    )
                    
                    ShotTypeDetailCard(
                        title: "Drive",
                        shots: stats.shotCountForType("drive"),
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
    let accuracy: String?
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(shots)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("shots")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let accuracy = accuracy, let accuracyValue = Double(accuracy) {
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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

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
                Image(systemName: (shot.success ?? false) ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor((shot.success ?? false) ? .green : .red)
                
                Text(shot.createdAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background((shot.success ?? false) ? Color.green.opacity(0.05) : Color.red.opacity(0.05))
        .cornerRadius(8)
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

struct SessionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        SessionHistoryView()
    }
}