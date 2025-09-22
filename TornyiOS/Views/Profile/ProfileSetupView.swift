import SwiftUI
import Foundation

struct ProfileSetupView: View {
    @ObservedObject private var apiService = APIService.shared

    var body: some View {
        VStack {
            Text("Profile Setup")
        }
        .navigationTitle("Profile")
    }
}

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupView()
    }
}