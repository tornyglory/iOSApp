import SwiftUI
import Foundation
import PhotosUI
import UIKit

struct ProfileSetupView: View {
    @StateObject private var viewModel = ProfileSetupViewModel()
    @ObservedObject private var apiService = APIService.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section with Banner and Avatar
                        ProfileHeaderSection(viewModel: viewModel)

                        // Form Content
                        VStack(spacing: 24) {
                            // Sport Preference Section
                            SportPreferenceSection()

                            // Club Selection Section
                            ClubSelectionSection(viewModel: viewModel)

                            // Player Information Section
                            PlayerInformationSection(viewModel: viewModel)

                            // Location Section
                            LocationSection(viewModel: viewModel)

                            // Save Button
                            SaveButtonSection(viewModel: viewModel, dismiss: dismiss)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.showingClubSearch) {
            ClubSearchView(viewModel: viewModel)
        }
        .task {
            await viewModel.loadUserProfile()
        }
        .alert("Profile Update", isPresented: $viewModel.showingAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

// MARK: - Profile Header Section
struct ProfileHeaderSection: View {
    @ObservedObject var viewModel: ProfileSetupViewModel
    @State private var showingBannerPicker = false
    @State private var showingAvatarPicker = false

    var body: some View {
        ZStack(alignment: .top) {
            // Banner Background
            ZStack(alignment: .topTrailing) {
                if let bannerImage = viewModel.banner {
                    Image(uiImage: bannerImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 280)
                        .clipped()
                } else {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.0, green: 0.8, blue: 0.8),  // Aqua
                            Color(red: 0.5, green: 0.0, blue: 0.8)   // Purple
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 280)
                }

                // Dark overlay for better text visibility
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.5)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 280)

                // Camera button for banner
                PhotosPicker(selection: $viewModel.bannerItem, matching: .images, photoLibrary: .shared()) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding()
                .onChange(of: viewModel.bannerItem) { _ in
                    viewModel.loadBannerFromItem()
                }
            }

            VStack(spacing: 16) {
                // Navigation Bar (optional - could be removed if not needed)
                Spacer()
                    .frame(height: 30)

                // Badges at top
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.fill")
                            .font(.caption)
                        Text("Player")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .foregroundColor(.tornyBlue)
                    .cornerRadius(20)

                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text("Member since 2024")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .foregroundColor(.tornyPurple)
                    .cornerRadius(20)

                    Spacer()
                }
                .padding(.horizontal)

                Spacer()
                    .frame(height: 20)

                // Avatar positioned on the left
                HStack {
                    ZStack(alignment: .bottomTrailing) {
                        if let avatarImage = viewModel.avatar {
                            Image(uiImage: avatarImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        } else {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.0, green: 0.8, blue: 0.8),  // Aqua
                                        Color(red: 0.5, green: 0.0, blue: 0.8)   // Purple
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Text("T")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        }

                        PhotosPicker(selection: $viewModel.avatarItem, matching: .images, photoLibrary: .shared()) {
                            Image(systemName: "camera.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .onChange(of: viewModel.avatarItem) { _ in
                            viewModel.loadAvatarFromItem()
                        }
                    }
                    .padding(.leading, 20)

                    Spacer()
                }

                Spacer()
                    .frame(height: 20)

                // Name and Email Fields
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Name")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        TextField("Enter your name", text: $viewModel.name)
                            .textFieldStyle(DarkTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email Address")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        TextField("Enter your email", text: $viewModel.email)
                            .textFieldStyle(DarkTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
                    .frame(height: 10)
            }
        }
    }
}

// MARK: - Sport Preference Section
struct SportPreferenceSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sport Preference")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Sport")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "target")
                        .foregroundColor(.tornyBlue)
                    Text("Lawn Bowls")
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 1)
                )
            }

            Text("Currently, only Lawn Bowls is available.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Club Selection Section
struct ClubSelectionSection: View {
    @ObservedObject var viewModel: ProfileSetupViewModel
    @State private var showingSearch = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Club You Represent")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Search and Select Club")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Current Club Display (if any)
                if !viewModel.club.isEmpty {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Club")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(viewModel.club)
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        Spacer()
                        Button("Change") {
                            showingSearch = true
                            viewModel.clubSearchText = ""
                            viewModel.searchResults = []
                        }
                        .font(.caption)
                        .foregroundColor(.tornyBlue)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                // Search Input Field (show when no club or when searching)
                if viewModel.club.isEmpty || showingSearch {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search clubs (min 3 characters)", text: $viewModel.clubSearchText)
                            .onChange(of: viewModel.clubSearchText) { _ in
                                viewModel.searchClubs()
                            }
                        if !viewModel.clubSearchText.isEmpty {
                            Button("Clear") {
                                viewModel.clubSearchText = ""
                                viewModel.searchResults = []
                            }
                            .font(.caption)
                            .foregroundColor(.tornyBlue)
                        }

                        if !viewModel.club.isEmpty && showingSearch {
                            Button("Cancel") {
                                showingSearch = false
                                viewModel.clubSearchText = ""
                                viewModel.searchResults = []
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                }

                // Preview List
                if !viewModel.searchResults.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(viewModel.searchResults.prefix(3)) { club in
                            ClubPreviewRow(club: club) {
                                viewModel.selectClub(club)
                                showingSearch = false
                            }
                        }

                        if viewModel.searchResults.count > 3 {
                            Button("Show all \(viewModel.searchResults.count) results") {
                                viewModel.showingClubSearch = true
                            }
                            .font(.caption)
                            .foregroundColor(.tornyBlue)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.top, 8)
                } else if viewModel.clubSearchText.count >= 3 {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.secondary)
                            Text("No clubs found")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                    }
                } else if viewModel.clubSearchText.count > 0 && viewModel.clubSearchText.count < 3 {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                            Text("Enter at least 3 characters to search")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                    }
                }

                // Show selected club card if one is selected
                if let club = viewModel.selectedClub {
                    ClubInfoCard(club: club) {
                        viewModel.selectedClub = nil
                        viewModel.club = ""
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Player Information Section
struct PlayerInformationSection: View {
    @ObservedObject var viewModel: ProfileSetupViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Player Information")
                .font(.headline)
                .fontWeight(.semibold)

            // Gender
            VStack(alignment: .leading, spacing: 8) {
                Text("Gender")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Menu {
                    Button("Male") { viewModel.selectedGender = "Male" }
                    Button("Female") { viewModel.selectedGender = "Female" }
                    Button("Other") { viewModel.selectedGender = "Other" }
                    Button("Prefer not to say") { viewModel.selectedGender = "Prefer not to say" }
                } label: {
                    HStack {
                        Text(viewModel.selectedGender)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                }
            }

            // Phone Number
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("Phone Number", text: $viewModel.phone)
                    .textFieldStyle(BorderedTextFieldStyle())
                    .keyboardType(.phonePad)

                Text("\(viewModel.phone.count)/20")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Short Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Short Description")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("Short Description", text: $viewModel.shortDescription)
                    .textFieldStyle(BorderedTextFieldStyle())

                Text("\(viewModel.shortDescription.count)/100")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Full Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Description")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextEditor(text: $viewModel.fullDescription)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.separator), lineWidth: 1)
                    )

                Text("\(viewModel.fullDescription.count)/500")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Location Section
struct LocationSection: View {
    @ObservedObject var viewModel: ProfileSetupViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Location")
                .font(.headline)
                .fontWeight(.semibold)

            // Country
            VStack(alignment: .leading, spacing: 8) {
                Text("Country")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Menu {
                    Button("Australia") { viewModel.selectedCountry = "Australia" }
                    Button("New Zealand") { viewModel.selectedCountry = "New Zealand" }
                } label: {
                    HStack {
                        Text(viewModel.selectedCountry)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                }
            }

            // State/Region
            if viewModel.selectedCountry == "Australia" {
                VStack(alignment: .leading, spacing: 8) {
                    Text("State")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Menu {
                        ForEach(["Victoria", "New South Wales", "Queensland", "Western Australia", "South Australia", "Tasmania", "Northern Territory", "Australian Capital Territory"], id: \.self) { state in
                            Button(state) { viewModel.selectedState = state }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedState)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                    }
                }
            }

            // City/Region
            VStack(alignment: .leading, spacing: 8) {
                Text("City/Region")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("City/Region", text: $viewModel.region)
                    .textFieldStyle(BorderedTextFieldStyle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Save Button Section
struct SaveButtonSection: View {
    @ObservedObject var viewModel: ProfileSetupViewModel
    let dismiss: DismissAction

    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task {
                    await viewModel.saveProfile()
                    if viewModel.navigateToDashboard {
                        dismiss()
                    }
                }
            }) {
                if viewModel.isLoading {
                    TornyLoadingView(color: .white)
                        .scaleEffect(0.8)
                } else {
                    Text("Save Changes")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(viewModel.isFormValid ? Color.tornyBlue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
        }
        .padding()
    }
}

// MARK: - Club Info Card
struct ClubInfoCard: View {
    let club: Club
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: club.avatar)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(club.name)
                    .font(.headline)
                Text(club.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Text("\(club.region), \(club.state), \(club.country)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}

// MARK: - Club Preview Row
struct ClubPreviewRow: View {
    let club: Club
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Club Avatar
                AsyncImage(url: URL(string: club.avatar)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "building.2")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        )
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 2) {
                    Text(club.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        if !club.region.isEmpty {
                            Text(club.region)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if !club.state.isEmpty {
                            Text("• \(club.state)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Club Search View (remains the same as before)
struct ClubSearchView: View {
    @ObservedObject var viewModel: ProfileSetupViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search clubs (min 3 characters)", text: $viewModel.clubSearchText)
                        .onChange(of: viewModel.clubSearchText) { _ in
                            viewModel.searchClubs()
                        }
                    if !viewModel.clubSearchText.isEmpty {
                        Button("Clear") {
                            viewModel.clubSearchText = ""
                            viewModel.searchResults = []
                        }
                        .foregroundColor(.tornyBlue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                // Search Results
                if viewModel.searchResults.isEmpty && viewModel.clubSearchText.count >= 3 {
                    VStack(spacing: 16) {
                        Image(systemName: "building.2")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No clubs found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Try adjusting your search terms")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                } else if viewModel.clubSearchText.count < 3 {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Search for clubs")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Enter at least 3 characters to search")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                } else {
                    List(viewModel.searchResults) { club in
                        ClubRowView(club: club) {
                            viewModel.selectClub(club)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Select Club")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Club Row View (remains the same)
struct ClubRowView: View {
    let club: Club
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: club.avatar)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "building.2")
                                .foregroundColor(.secondary)
                        )
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text(club.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack {
                        if !club.region.isEmpty {
                            Text(club.region)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        if !club.state.isEmpty {
                            Text("• \(club.state)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    if !club.description.isEmpty {
                        Text(club.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom Styles
struct DarkTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(10)
            .foregroundColor(.black)
            .accentColor(.blue)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

struct BorderedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.separator), lineWidth: 1)
            )
    }
}


struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupView()
    }
}