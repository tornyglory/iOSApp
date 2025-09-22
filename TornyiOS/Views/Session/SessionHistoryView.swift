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
                TornyLoadingView(color: .tornyBlue)
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