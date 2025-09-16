import SwiftUI

struct ProfileSetupView: View {
    @ObservedObject private var apiService = APIService.shared
    var onProfileCompleted: (() -> Void)? = nil
    @State private var name = ""
    @State private var email = ""
    
    init(onProfileCompleted: (() -> Void)? = nil) {
        self.onProfileCompleted = onProfileCompleted
        
        // Initialize with current user data if available
        if let user = APIService.shared.currentUser {
            _name = State(initialValue: user.name)
            _email = State(initialValue: user.email)
            print("🏏 ProfileSetupView init - Name: '\(user.name)', Email: '\(user.email)'")
        } else {
            print("❌ No current user found during ProfileSetupView init")
        }
    }
    @State private var selectedClub: Club?
    @State private var clubSearchText = ""
    @State private var searchedClubs: [Club] = []
    @State private var selectedGender = "Male"
    @State private var phoneNumber = ""
    @State private var shortDescription = ""
    @State private var fullDescription = ""
    @State private var selectedCountry = "Australia"
    @State private var selectedState = "Victoria"
    @State private var selectedArea = "Ballarat"
    @State private var isLoading = false
    @State private var isSearchingClubs = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSuccessMessage = false
    @State private var searchTask: Task<Void, Never>?
    @State private var showingImagePicker = false
    @State private var showingAvatarPicker = false
    @State private var selectedBannerImage: UIImage?
    @State private var selectedAvatarImage: UIImage?
    @State private var avatarUrl: String?
    @State private var bannerUrl: String?
    
    let genders = ["Male", "Female", "Other", "Prefer not to say"]
    let countries = ["Australia", "New Zealand", "United Kingdom", "United States"]
    let states = ["Victoria", "NSW", "Queensland", "South Australia", "Western Australia", "Tasmania", "ACT", "Northern Territory"]
    let areas = ["Melbourne", "Ballarat", "Geelong", "Bendigo", "Shepparton", "Warrnambool"]
    
    // Validation (matching Vue implementation)
    private var hasValidationErrors: Bool {
        return name.isEmpty || email.isEmpty
    }
    
    var body: some View {
        ZStack {
            TornyBackgroundView()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header with banner and avatar
                    ZStack {
                        // Banner background
                        Group {
                            if let bannerImage = selectedBannerImage {
                                Image(uiImage: bannerImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else if let bannerUrl = bannerUrl, !bannerUrl.isEmpty {
                                AsyncImage(url: URL(string: bannerUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    // Show gradient while loading
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.8),
                                            Color.purple.opacity(0.6),
                                            Color.teal.opacity(0.4)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                }
                            } else {
                                // Default banner gradient
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.8),
                                        Color.purple.opacity(0.6),
                                        Color.teal.opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        }
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Banner content overlay
                        VStack(spacing: 20) {
                            HStack {
                                Spacer()
                                
                                // Banner camera button
                                Button(action: {
                                    showingImagePicker = true
                                }) {
                                    Image(systemName: "camera.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.3)))
                                }
                                .padding(.trailing, 16)
                                .padding(.top, 16)
                            }
                            
                            Spacer()
                            
                            // Profile section
                            HStack(alignment: .bottom, spacing: 16) {
                                // Avatar
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 3)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(Color.tornyBlue, lineWidth: 3)
                                                .frame(width: 86, height: 86)
                                        )
                                    
                                    if let avatarImage = selectedAvatarImage {
                                        Image(uiImage: avatarImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                    } else if let avatarUrl = avatarUrl, !avatarUrl.isEmpty {
                                        AsyncImage(url: URL(string: avatarUrl)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        }
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                    } else {
                                        VStack {
                                            Image(systemName: "camera.fill")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                            Text("Add Photo")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    // Avatar camera icon overlay
                                    Button(action: {
                                        showingAvatarPicker = true
                                    }) {
                                        Image(systemName: "camera.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.tornyBlue)
                                            .background(Circle().fill(Color.white))
                                    }
                                    .offset(x: 28, y: 28)
                                }
                                .padding(.leading, 20)
                                .padding(.bottom, 16)
                                
                                Spacer()
                                
                                // Badges
                                VStack(alignment: .trailing, spacing: 8) {
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.tornyBlue)
                                        Text("Player")
                                            .foregroundColor(.tornyBlue)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(16)
                                    
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.tornyPurple)
                                        Text("Member since 2024")
                                            .foregroundColor(.tornyPurple)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(16)
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 10)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Profile Form
                    TornyCard {
                        VStack(spacing: 24) {
                            // Basic Info
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Your Name")
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextPrimary)
                                        .fontWeight(.medium)
                                    
                                    TextField("Enter your full name", text: $name)
                                        .textFieldStyle(TornyTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Email Address")
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextPrimary)
                                        .fontWeight(.medium)
                                    
                                    TextField("Enter your email", text: $email)
                                        .textFieldStyle(TornyTextFieldStyle())
                                        .disabled(true) // Email from login
                                        .opacity(0.7)
                                }
                            }
                            
                            Divider()
                            
                            // Sport Preference
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Sport Preference")
                                    .font(TornyFonts.title3)
                                    .foregroundColor(.tornyTextPrimary)
                                    .fontWeight(.semibold)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Sport")
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextPrimary)
                                        .fontWeight(.medium)
                                    
                                    Menu {
                                        Button("Lawn Bowls") { }
                                    } label: {
                                        HStack {
                                            Image(systemName: "target")
                                                .foregroundColor(.tornyBlue)
                                            Text("Lawn Bowls")
                                                .foregroundColor(.tornyTextPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.tornyLightBlue, lineWidth: 1)
                                                )
                                        )
                                    }
                                    
                                    Text("Currently, only Lawn Bowls is available.")
                                        .font(TornyFonts.bodySecondary)
                                        .foregroundColor(.tornyTextSecondary)
                                }
                            }
                            
                            Divider()
                            
                            // Club Selection
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Club You Represent")
                                    .font(TornyFonts.title3)
                                    .foregroundColor(.tornyTextPrimary)
                                    .fontWeight(.semibold)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Search and Select Club")
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextPrimary)
                                        .fontWeight(.medium)
                                    
                                    TextField("Type to search for clubs...", text: $clubSearchText)
                                        .textFieldStyle(TornyTextFieldStyle())
                                        .disabled(selectedClub != nil) // Disable when club is selected
                                        .onChange(of: clubSearchText) { newValue in
                                            // Only search when no club is selected and query is 3+ chars
                                            if selectedClub == nil && newValue.count >= 3 {
                                                searchClubsWithDebounce(query: newValue)
                                            } else if newValue.count < 3 {
                                                searchedClubs = []
                                            }
                                        }
                                    
                                    // Show selected club
                                    if let selectedClub = selectedClub {
                                        VStack(alignment: .leading, spacing: 12) {
                                            HStack {
                                                // Club logo or placeholder
                                                AsyncImage(url: URL(string: selectedClub.avatar)) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                } placeholder: {
                                                    Circle()
                                                        .fill(Color.orange)
                                                        .overlay(
                                                            Text("🏏")
                                                                .font(.title3)
                                                        )
                                                }
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.tornyBlue, lineWidth: 2)
                                                )
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(selectedClub.name)
                                                        .font(TornyFonts.body)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.tornyTextPrimary)
                                                    
                                                    Text(selectedClub.description)
                                                        .font(TornyFonts.bodySecondary)
                                                        .foregroundColor(.tornyTextSecondary)
                                                        .lineLimit(2)
                                                    
                                                    Text("\(selectedClub.region), \(selectedClub.state), \(selectedClub.country)")
                                                        .font(TornyFonts.bodySecondary)
                                                        .foregroundColor(.tornyTextSecondary)
                                                }
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    print("🏏 Deselecting club")
                                                    self.selectedClub = nil
                                                    self.clubSearchText = ""
                                                    self.searchedClubs = []
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                        .font(.title2)
                                                }
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.tornyGreen.opacity(0.1))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.tornyGreen, lineWidth: 2)
                                                    )
                                            )
                                        }
                                        .padding(.top, 8)
                                    }
                                    
                                    // Show search results dropdown (only when no club is selected)
                                    if selectedClub == nil && !clubSearchText.isEmpty && clubSearchText.count >= 3 {
                                        VStack(alignment: .leading, spacing: 0) {
                                            if isSearchingClubs {
                                                HStack {
                                                    TornyLoadingView()
                                                    Text("Searching clubs...")
                                                        .font(TornyFonts.bodySecondary)
                                                        .foregroundColor(.tornyTextSecondary)
                                                }
                                                .padding()
                                            } else if searchedClubs.isEmpty {
                                                Text("No clubs found. Try a different search term.")
                                                    .font(TornyFonts.bodySecondary)
                                                    .foregroundColor(.tornyTextSecondary)
                                                    .padding()
                                            } else {
                                                ScrollView {
                                                    LazyVStack(spacing: 0) {
                                                        ForEach(searchedClubs) { club in
                                                            Button(action: {
                                                                selectClub(club)
                                                            }) {
                                                                HStack(alignment: .top, spacing: 12) {
                                                                    // Club avatar
                                                                    AsyncImage(url: URL(string: club.avatar)) { image in
                                                                        image
                                                                            .resizable()
                                                                            .aspectRatio(contentMode: .fill)
                                                                    } placeholder: {
                                                                        Circle()
                                                                            .fill(Color.orange)
                                                                            .overlay(
                                                                                Text("🏏")
                                                                                    .font(.caption)
                                                                                    .foregroundColor(.white)
                                                                            )
                                                                    }
                                                                    .frame(width: 40, height: 40)
                                                                    .clipShape(Circle())
                                                                    .overlay(
                                                                        Circle()
                                                                            .stroke(Color.tornyBlue, lineWidth: 2)
                                                                    )
                                                                    
                                                                    VStack(alignment: .leading, spacing: 4) {
                                                                        // Club name (bold)
                                                                        Text(club.name)
                                                                            .font(TornyFonts.body)
                                                                            .fontWeight(.semibold)
                                                                            .foregroundColor(.tornyTextPrimary)
                                                                            .multilineTextAlignment(.leading)
                                                                        
                                                                        // Description (truncated, gray)
                                                                        if !club.description.isEmpty {
                                                                            Text(club.description)
                                                                                .font(TornyFonts.bodySecondary)
                                                                                .foregroundColor(.tornyTextSecondary)
                                                                                .lineLimit(2)
                                                                                .multilineTextAlignment(.leading)
                                                                        }
                                                                        
                                                                        // Location info
                                                                        Text("\(club.region), \(club.state), \(club.country)")
                                                                            .font(TornyFonts.caption)
                                                                            .foregroundColor(.tornyTextSecondary)
                                                                    }
                                                                    
                                                                    Spacer()
                                                                }
                                                                .padding(.horizontal, 16)
                                                                .padding(.vertical, 12)
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                            }
                                                            .buttonStyle(PlainButtonStyle())
                                                            .background(Color.white)
                                                            
                                                            if club.id != searchedClubs.last?.id {
                                                                Divider()
                                                                    .padding(.horizontal, 16)
                                                            }
                                                        }
                                                    }
                                                }
                                                .frame(maxHeight: 240) // Max height with scroll
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.tornyLightBlue, lineWidth: 1)
                                                )
                                        )
                                        .padding(.top, 8)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Player Information
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Player Information")
                                    .font(TornyFonts.title3)
                                    .foregroundColor(.tornyTextPrimary)
                                    .fontWeight(.semibold)
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Gender")
                                            .font(TornyFonts.body)
                                            .foregroundColor(.tornyTextPrimary)
                                            .fontWeight(.medium)
                                        
                                        Menu {
                                            ForEach(genders, id: \.self) { gender in
                                                Button(gender) {
                                                    selectedGender = gender
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(selectedGender)
                                                    .foregroundColor(.tornyTextPrimary)
                                                Spacer()
                                                Image(systemName: "chevron.down")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.tornyLightBlue, lineWidth: 1)
                                                    )
                                            )
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Phone Number")
                                                .font(TornyFonts.body)
                                                .foregroundColor(.tornyTextPrimary)
                                                .fontWeight(.medium)
                                            Spacer()
                                            Text("\(phoneNumber.count)/20")
                                                .font(TornyFonts.caption)
                                                .foregroundColor(.tornyTextSecondary)
                                        }
                                        
                                        TextField("Enter your phone number", text: $phoneNumber)
                                            .textFieldStyle(TornyTextFieldStyle())
                                            .keyboardType(.phonePad)
                                            .onChange(of: phoneNumber) { newValue in
                                                if newValue.count > 20 {
                                                    phoneNumber = String(newValue.prefix(20))
                                                }
                                            }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Short Description")
                                                .font(TornyFonts.body)
                                                .foregroundColor(.tornyTextPrimary)
                                                .fontWeight(.medium)
                                            Spacer()
                                            Text("\(shortDescription.count)/100")
                                                .font(TornyFonts.caption)
                                                .foregroundColor(.tornyTextSecondary)
                                        }
                                        
                                        TextField("Brief description about yourself", text: $shortDescription)
                                            .textFieldStyle(TornyTextFieldStyle())
                                            .onChange(of: shortDescription) { newValue in
                                                if newValue.count > 100 {
                                                    shortDescription = String(newValue.prefix(100))
                                                }
                                            }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Full Description")
                                                .font(TornyFonts.body)
                                                .foregroundColor(.tornyTextPrimary)
                                                .fontWeight(.medium)
                                            Spacer()
                                            Text("\(fullDescription.count)/500")
                                                .font(TornyFonts.caption)
                                                .foregroundColor(.tornyTextSecondary)
                                        }
                                        
                                        ZStack(alignment: .topLeading) {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.tornyLightBlue, lineWidth: 1)
                                                )
                                                .frame(height: 120)
                                            
                                            TextEditor(text: $fullDescription)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .font(TornyFonts.body)
                                                .foregroundColor(.tornyTextPrimary)
                                                .onChange(of: fullDescription) { newValue in
                                                    if newValue.count > 500 {
                                                        fullDescription = String(newValue.prefix(500))
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Location
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Location")
                                    .font(TornyFonts.title3)
                                    .foregroundColor(.tornyTextPrimary)
                                    .fontWeight(.semibold)
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Country")
                                            .font(TornyFonts.body)
                                            .foregroundColor(.tornyTextPrimary)
                                            .fontWeight(.medium)
                                        
                                        Menu {
                                            ForEach(countries, id: \.self) { country in
                                                Button(country) {
                                                    selectedCountry = country
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(selectedCountry)
                                                    .foregroundColor(.tornyTextPrimary)
                                                Spacer()
                                                Image(systemName: "chevron.down")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.tornyLightBlue, lineWidth: 1)
                                                    )
                                            )
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("State/Territory")
                                            .font(TornyFonts.body)
                                            .foregroundColor(.tornyTextPrimary)
                                            .fontWeight(.medium)
                                        
                                        Menu {
                                            ForEach(states, id: \.self) { state in
                                                Button(state) {
                                                    selectedState = state
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(selectedState)
                                                    .foregroundColor(.tornyTextPrimary)
                                                Spacer()
                                                Image(systemName: "chevron.down")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.tornyLightBlue, lineWidth: 1)
                                                    )
                                            )
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Area")
                                            .font(TornyFonts.body)
                                            .foregroundColor(.tornyTextPrimary)
                                            .fontWeight(.medium)
                                        
                                        Menu {
                                            ForEach(areas, id: \.self) { area in
                                                Button(area) {
                                                    selectedArea = area
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(selectedArea)
                                                    .foregroundColor(.tornyTextPrimary)
                                                Spacer()
                                                Image(systemName: "chevron.down")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.tornyLightBlue, lineWidth: 1)
                                                    )
                                            )
                                        }
                                    }
                                }
                            }
                            
                            // Save Button
                            Button(action: saveProfile) {
                                HStack {
                                    if isLoading {
                                        TornyLoadingView(color: .white)
                                        Text("Saving Changes...")
                                    } else {
                                        Text("Save Changes")
                                    }
                                }
                            }
                            .buttonStyle(TornyPrimaryButton(isLarge: true))
                            .frame(maxWidth: .infinity)
                            .disabled(isLoading || hasValidationErrors)
                            .padding(.top, 16)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
                .padding(.bottom, 50)
            }
            .scrollDismissesKeyboard(.interactively)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Success message overlay
            if showingSuccessMessage {
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.tornyGreen)
                        
                        Text("Profile saved successfully!")
                            .font(TornyFonts.body)
                            .fontWeight(.medium)
                            .foregroundColor(.tornyTextPrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingSuccessMessage)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            loadUserData()
        }
        .task {
            // Also try loading user data when view appears
            loadUserData()
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedBannerImage)
        }
        .sheet(isPresented: $showingAvatarPicker) {
            ImagePicker(selectedImage: $selectedAvatarImage)
        }
    }
    
    private func loadUserData() {
        if let user = apiService.currentUser {
            name = user.name
            email = user.email
            avatarUrl = user.avatarUrl
            bannerUrl = user.bannerUrl
            phoneNumber = user.phone ?? ""
            shortDescription = user.description ?? ""
            fullDescription = user.description ?? ""
            
            // Load club data if available
            if let clubData = user.clubData {
                selectedClub = clubData
                clubSearchText = clubData.name
                print("🏏 Loaded club: \(clubData.name)")
            } else if let clubName = user.club, !clubName.isEmpty {
                // If only club name is available, set search text
                clubSearchText = clubName
            }
            
            print("🏏 Loading user data - Name: '\(user.name)', Email: '\(user.email)'")
            print("🏏 Avatar URL: \(user.avatarUrl ?? "none")")
            print("🏏 Banner URL: \(user.bannerUrl ?? "none")")
            
            // Always fetch complete profile to get banner and club data
            fetchCompleteProfile()
        } else {
            print("❌ No current user found when loading profile data")
        }
    }
    
    private func fetchCompleteProfile() {
        guard let user = apiService.currentUser else { return }
        
        print("🏏 Fetching complete profile for user ID: \(user.id)")
        
        Task {
            do {
                let completeUser = try await apiService.getProfile(userId: String(user.id))
                
                await MainActor.run {
                    print("🏏 Complete profile fetched successfully")
                    print("🏏 Complete profile banner URL: \(completeUser.bannerUrl ?? "none")")
                    print("🏏 Complete profile avatar URL: \(completeUser.avatarUrl ?? "none")")
                    print("🏏 Complete profile club data: \(completeUser.clubData?.name ?? "none")")
                    
                    // Update the current user with complete data
                    apiService.currentUser = completeUser
                    
                    // Update local state with complete data
                    bannerUrl = completeUser.bannerUrl
                    avatarUrl = completeUser.avatarUrl
                    phoneNumber = completeUser.phone ?? phoneNumber
                    shortDescription = completeUser.description ?? shortDescription
                    fullDescription = completeUser.description ?? fullDescription
                    
                    // Update club data
                    if let clubData = completeUser.clubData {
                        selectedClub = clubData
                        clubSearchText = clubData.name
                        print("🏏 Updated selected club: \(clubData.name)")
                    } else if let clubName = completeUser.club, !clubName.isEmpty {
                        clubSearchText = clubName
                        print("🏏 Updated club search text: \(clubName)")
                    }
                }
            } catch {
                print("❌ Failed to fetch complete profile: \(error)")
            }
        }
    }
    
    private func selectClub(_ club: Club) {
        print("🏏 Selecting club: \(club.name)")
        self.selectedClub = club
        self.clubSearchText = club.name
        self.searchedClubs = []
        print("🏏 Selected club set: \(selectedClub?.name ?? "nil")")
        print("🏏 Club search text set: '\(clubSearchText)'")
    }
    
    private func searchClubsWithDebounce(query: String) {
        // Cancel previous search task
        searchTask?.cancel()
        
        // Clear results if query is too short
        if query.count < 3 {
            searchedClubs = []
            return
        }
        
        // Start new search task with 300ms debounce
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                isSearchingClubs = true
            }
            
            do {
                let clubs = try await apiService.searchClubs(name: query)
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    searchedClubs = clubs
                    isSearchingClubs = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    searchedClubs = []
                    isSearchingClubs = false
                    print("❌ Club search failed: \(error)")
                }
            }
        }
    }
    
    private func saveProfile() {
        guard let user = apiService.currentUser else {
            alertMessage = "User not found. Please log in again."
            showingAlert = true
            return
        }
        
        isLoading = true
        
        let profileRequest = ProfileUpdateRequest(
            name: name,
            email: email,
            phone: phoneNumber,
            gender: selectedGender,
            description: fullDescription,
            shortDescription: shortDescription,
            avatarUrl: nil,
            bannerUrl: nil,
            avatarBase64: selectedAvatarImage?.jpegData(compressionQuality: 0.8)?.base64EncodedString(),
            bannerBase64: selectedBannerImage?.jpegData(compressionQuality: 0.8)?.base64EncodedString(),
            country: selectedCountry,
            state: selectedState,
            region: selectedArea,
            club: selectedClub?.name ?? "",
            clubId: selectedClub?.stringId ?? ""
        )
        
        Task {
            do {
                _ = try await apiService.updateProfile(userId: String(user.id), profile: profileRequest)
                
                await MainActor.run {
                    isLoading = false
                    showingSuccessMessage = true
                    print("✅ Profile saved successfully!")
                    // Mark profile as completed
                    UserDefaults.standard.set(true, forKey: "profile_completed")
                    
                    // Redirect to Dashboard after 1.5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showingSuccessMessage = false
                        onProfileCompleted?()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Failed to save profile: \(error.localizedDescription)"
                    showingAlert = true
                    print("❌ Profile save failed: \(error)")
                }
            }
        }
    }
}

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupView()
    }
}