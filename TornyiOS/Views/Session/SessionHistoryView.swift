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
    @State private var filterType: SessionFilterType = .all
    @Environment(\.dismiss) private var dismiss

    private let pageSize = 20

    enum SessionFilterType: Hashable {
        case all
        case programs
        case freestyle

        var displayName: String {
            switch self {
            case .all: return "All"
            case .programs: return "Programs"
            case .freestyle: return "Freestyle"
            }
        }
    }

    private var filteredSessions: [TrainingSession] {
        sessions.filter { session in
            switch filterType {
            case .all:
                return true
            case .programs:
                return session.programId != nil
            case .freestyle:
                return session.programId == nil
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()

                VStack(spacing: 0) {
                    // Filter Tabs
                    HStack(spacing: 0) {
                        ForEach([SessionFilterType.all, .programs, .freestyle], id: \.self) { filter in
                            Button(action: {
                                filterType = filter
                            }) {
                                Text(filter.displayName)
                                    .font(.subheadline)
                                    .fontWeight(filterType == filter ? .semibold : .regular)
                                    .foregroundColor(filterType == filter ? .tornyBlue : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        VStack(spacing: 0) {
                                            Color.clear
                                            Rectangle()
                                                .fill(filterType == filter ? Color.tornyBlue : Color.clear)
                                                .frame(height: 2)
                                        }
                                    )
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredSessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                SessionRowView(session: session)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        if hasMoreSessions && !sessions.isEmpty {
                            LoadMoreRow(isLoading: isLoading, loadMore: loadMoreSessions)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    }
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
                if filteredSessions.isEmpty && !isLoading {
                    EmptyHistoryView(filterType: filterType)
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
    let filterType: SessionHistoryView.SessionFilterType

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }

    private var iconName: String {
        switch filterType {
        case .all: return "clock"
        case .programs: return "list.bullet.clipboard"
        case .freestyle: return "figure.walk"
        }
    }

    private var title: String {
        switch filterType {
        case .all: return "No Training Sessions"
        case .programs: return "No Program Sessions"
        case .freestyle: return "No Freestyle Sessions"
        }
    }

    private var message: String {
        switch filterType {
        case .all:
            return "Start your first training session to see your history here."
        case .programs:
            return "Try a training program to track your progress with structured practice."
        case .freestyle:
            return "Start a freestyle training session to practice at your own pace."
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
                TornyLoadingView()
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


struct SessionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        SessionHistoryView()
    }
}