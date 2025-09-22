import SwiftUI

struct SessionRowView: View {
    let session: TrainingSession

    var body: some View {
        HStack {
            Text("Session \(session.id)")
            Spacer()
            Text("\(session.shots.count) shots")
        }
    }
}