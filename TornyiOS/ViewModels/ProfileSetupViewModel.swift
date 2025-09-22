import SwiftUI
import Foundation
import PhotosUI

@MainActor
class ProfileSetupViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var club = ""
    @Published var address = ""
    @Published var description = ""
    @Published var avatar: UIImage?
    @Published var avatarItem: PhotosPickerItem?
    @Published var selectedGender = "Male"
    @Published var selectedCountry = "Australia"
    @Published var selectedState = "Victoria"
    @Published var region = ""

    @Published var isLoading = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var navigateToDashboard = false

    private let apiService = APIService.shared
    private let genders = ["Male", "Female", "Other", "Prefer not to say"]
    private let countries = ["Australia", "New Zealand", "United Kingdom", "United States", "Other"]
    private let australianStates = ["Victoria", "New South Wales", "Queensland", "Western Australia", "South Australia", "Tasmania", "Northern Territory", "Australian Capital Territory"]

    var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty
    }

    func loadUserProfile() async {
        guard let user = apiService.currentUser else { return }

        name = user.name
        email = user.email
        phone = user.phone ?? ""
        club = user.club ?? ""
        address = user.address ?? ""
        description = user.description ?? ""
        selectedGender = user.gender ?? "Male"
        selectedCountry = user.country ?? "Australia"
        selectedState = user.state ?? "Victoria"
        region = user.region ?? ""

        if let avatarUrl = user.avatarUrl {
            await loadAvatarFromUrl(avatarUrl)
        }
    }

    private func loadAvatarFromUrl(_ urlString: String) async {
        guard let url = URL(string: urlString),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else { return }
        avatar = image
    }

    func saveProfile() async {
        guard isFormValid else {
            alertMessage = "Please fill in all required fields"
            showingAlert = true
            return
        }

        isLoading = true

        do {
            var avatarUrl: String?

            if let avatar = avatar {
                avatarUrl = try await uploadAvatar(avatar)
            }

            let request = ProfileUpdateRequest(
                name: name,
                email: email,
                phone: phone,
                gender: selectedGender,
                description: description,
                shortDescription: description,
                avatarUrl: avatarUrl,
                bannerUrl: nil,
                avatarBase64: nil,
                bannerBase64: nil,
                country: selectedCountry,
                state: selectedState,
                region: region,
                club: club,
                clubId: ""
            )

            let response = try await apiService.updateProfile(userId: String(apiService.currentUser?.id ?? 0), profile: request)

            // Profile updated successfully, fetch the updated profile
            if let currentUserId = apiService.currentUser?.id {
                let _ = try await apiService.getUserProfile(currentUserId)
                navigateToDashboard = true
            }

            isLoading = false
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
            isLoading = false
        }
    }

    private func uploadAvatar(_ image: UIImage) async throws -> String? {
        // TODO: Implement actual image upload
        // For now, return a placeholder URL
        return "https://example.com/avatar.jpg"
    }

    func loadAvatarFromItem() {
        Task {
            guard let item = avatarItem else { return }
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                avatar = uiImage
            }
        }
    }
}