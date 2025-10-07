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
    @Published var shortDescription = ""
    @Published var fullDescription = ""
    @Published var avatar: UIImage?
    @Published var banner: UIImage?
    @Published var avatarItem: PhotosPickerItem?
    @Published var bannerItem: PhotosPickerItem?
    @Published var selectedGender = "Male"
    @Published var selectedCountry = "Australia"
    @Published var selectedState = "Victoria"
    @Published var region = ""

    // Club search
    @Published var clubSearchText = ""
    @Published var searchResults: [Club] = []
    @Published var selectedClub: Club?
    @Published var showingClubSearch = false

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
        // First, fetch the latest profile from the API
        do {
            if let userId = apiService.currentUser?.id {
                let _ = try await apiService.getUserProfile(userId)
            }
        } catch {
            // If fetching fails, continue with cached data
            print("Failed to fetch latest profile: \(error)")
        }

        // Now load from the (potentially updated) currentUser
        guard let user = apiService.currentUser else { return }

        await MainActor.run {
            name = user.name
            email = user.email
            phone = user.phone ?? ""
            club = user.club ?? ""
            address = user.address ?? ""

            // Use description for both short and full if shortDescription is not available
            shortDescription = user.shortDescription ?? user.description ?? ""
            fullDescription = user.description ?? ""

            selectedGender = user.gender ?? "Male"
            selectedCountry = user.country ?? "Australia"
            selectedState = user.state ?? "Victoria"
            region = user.region ?? ""
        }

        // Load avatar image
        if let avatarUrl = user.avatarUrl, !avatarUrl.isEmpty {
            print("Loading avatar from URL: \(avatarUrl)")
            await loadImageFromUrl(avatarUrl) { image in
                self.avatar = image
            }
        } else {
            print("No avatar URL available")
        }

        // Load banner image
        if let bannerUrl = user.bannerUrl, !bannerUrl.isEmpty {
            print("Loading banner from URL: \(bannerUrl)")
            await loadImageFromUrl(bannerUrl) { image in
                self.banner = image
            }
        } else {
            print("No banner URL available")
        }
    }

    private func loadImageFromUrl(_ urlString: String, completion: @escaping (UIImage) -> Void) async {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }

        do {
            print("Fetching image from URL: \(url)")
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse {
                print("Image fetch response code: \(httpResponse.statusCode)")
            }

            if let image = UIImage(data: data) {
                print("Successfully loaded image, size: \(image.size)")
                await MainActor.run {
                    completion(image)
                }
            } else {
                print("Failed to create UIImage from data")
            }
        } catch {
            print("Failed to load image from \(urlString): \(error)")
        }
    }

    func saveProfile() async {
        guard isFormValid else {
            alertMessage = "Please fill in all required fields"
            showingAlert = true
            return
        }

        isLoading = true

        do {
            // Convert images to base64 if they were selected
            var avatarBase64: String?
            var bannerBase64: String?

            if let avatar = avatar {
                avatarBase64 = convertImageToBase64(image: avatar)
            }

            if let banner = banner {
                bannerBase64 = convertImageToBase64(image: banner)
            }

            let request = ProfileUpdateRequest(
                name: name,
                email: email,
                phone: phone,
                gender: selectedGender,
                description: fullDescription,
                shortDescription: shortDescription,
                avatarUrl: apiService.currentUser?.avatarUrl,  // Keep existing URL
                bannerUrl: apiService.currentUser?.bannerUrl,  // Keep existing URL
                avatarBase64: avatarBase64,  // Include base64 if new image selected
                bannerBase64: bannerBase64,  // Include base64 if new image selected
                country: selectedCountry,
                state: selectedState,
                region: region,
                club: club,
                clubId: selectedClub != nil ? String(selectedClub!.id) : ""
            )

            let _ = try await apiService.updateProfile(userId: String(apiService.currentUser?.id ?? 0), profile: request)

            // Profile updated successfully - the APIService has already updated currentUser
            navigateToDashboard = true
            isLoading = false
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
            isLoading = false
        }
    }

    private func convertImageToBase64(image: UIImage, compressionQuality: CGFloat = 0.8) -> String? {
        // Resize image if needed to avoid overly large uploads
        let maxDimension: CGFloat = 1024
        let resizedImage = resizeImage(image: image, maxDimension: maxDimension)

        // Convert to JPEG with compression
        guard let imageData = resizedImage.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }

        // Convert to base64 string with data URI prefix
        let base64String = imageData.base64EncodedString()
        return "data:image/jpeg;base64,\(base64String)"
    }

    private func resizeImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size

        // Calculate new size maintaining aspect ratio
        var newSize: CGSize
        if size.width > size.height {
            if size.width > maxDimension {
                newSize = CGSize(width: maxDimension, height: (size.height / size.width) * maxDimension)
            } else {
                return image // No need to resize
            }
        } else {
            if size.height > maxDimension {
                newSize = CGSize(width: (size.width / size.height) * maxDimension, height: maxDimension)
            } else {
                return image // No need to resize
            }
        }

        // Create resized image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()

        return resizedImage
    }

    func loadAvatarFromItem() {
        Task {
            guard let item = avatarItem else { return }
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    avatar = uiImage
                }
            }
        }
    }

    func loadBannerFromItem() {
        Task {
            guard let item = bannerItem else { return }
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    banner = uiImage
                }
            }
        }
    }

    // MARK: - Club Search Functions

    func searchClubs() {
        guard clubSearchText.count >= 3 else {
            searchResults = []
            return
        }

        Task {
            do {
                let clubs = try await apiService.searchClubs(name: clubSearchText)
                await MainActor.run {
                    searchResults = clubs
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to search clubs: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }

    func selectClub(_ club: Club) {
        selectedClub = club
        self.club = club.name
        showingClubSearch = false
        clubSearchText = ""
        searchResults = []
    }
}