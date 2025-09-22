import SwiftUI

struct SessionDetailView: View {
    let session: TrainingSession

    var body: some View {
        Text("Session Details")
            .navigationTitle("Session \(session.id)")
    }
}