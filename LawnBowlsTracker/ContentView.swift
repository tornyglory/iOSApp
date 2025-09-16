import SwiftUI

// MARK: - Temporary stub implementations
// TODO: Remove these when the actual training views are properly imported

struct StubTrainingSetupView: View {
    let onSessionCreated: ((TrainingSession) -> Void)?
    
    var body: some View {
        VStack {
            Text("Training Setup View")
                .font(.title)
            Text("This is a temporary stub. The real implementation should load.")
            Button("Create Mock Session") {
                // Create a mock session for testing
                let mockSession = TrainingSession(
                    id: 1,
                    playerId: 1,
                    sport: "lawn_bowls",
                    sessionDate: Date(),
                    location: .outdoor,
                    greenType: .bent,
                    greenSpeed: 14,
                    rinkNumber: nil,
                    weather: .warm,
                    windConditions: .light,
                    notes: nil,
                    createdAt: Date(),
                    updatedAt: Date(),
                    totalShots: nil,
                    drawShots: nil,
                    weightedShots: nil,
                    drawAccuracy: nil,
                    weightedAccuracy: nil,
                    overallAccuracy: nil,
                    startedAt: Date(),
                    endedAt: nil,
                    durationSeconds: nil,
                    _isActive: 1
                )
                onSessionCreated?(mockSession)
            }
        }
        .padding()
    }
    
    init(onSessionCreated: ((TrainingSession) -> Void)? = nil) {
        self.onSessionCreated = onSessionCreated
    }
}

struct StubTrainingSessionView: View {
    let session: TrainingSession
    let onSessionEnd: (() -> Void)?
    
    var body: some View {
        VStack {
            Text("Training Session View")
                .font(.title)
            Text("Session ID: \(session.id)")
            Text("This is a temporary stub. The real implementation should load.")
            Button("End Session") {
                onSessionEnd?()
            }
        }
        .padding()
    }
    
    init(session: TrainingSession, onSessionEnd: (() -> Void)? = nil) {
        self.session = session
        self.onSessionEnd = onSessionEnd
    }
}

struct ContentView: View {
    @ObservedObject private var apiService = APIService.shared
    @State private var selectedTab = 0
    @State private var showingProfileSetup = false
    
    var body: some View {
        Group {
            if apiService.isAuthenticated {
                // Check if user has completed profile setup
                let hasCompletedProfile = UserDefaults.standard.bool(forKey: "profile_completed") || apiService.currentUser?.profileCompleted == 1
                
                if hasCompletedProfile && !showingProfileSetup {
                    MainDashboardView()
                } else {
                    ProfileSetupView { 
                        // Profile completion callback
                        showingProfileSetup = false
                    }
                }
            } else {
                AuthView()
            }
        }
        .onAppear {
            // For testing: clear any stored authentication data
            // Remove this line in production
            apiService.clearAllStoredData()
        }
        .onChange(of: apiService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // Reset profile setup state when user logs in
                let hasCompletedProfile = UserDefaults.standard.bool(forKey: "profile_completed") || apiService.currentUser?.profileCompleted == 1
                showingProfileSetup = !hasCompletedProfile
            }
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    @ObservedObject private var apiService = APIService.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SessionView()
                .tabItem {
                    Image(systemName: "figure.bowling")
                    Text("Training")
                }
                .tag(0)
            
            SessionHistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
                .tag(1)
            
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Analytics")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.tornyBlue)
    }
}

struct ProfileView: View {
    @ObservedObject private var apiService = APIService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            TornyLogoView(size: CGSize(width: 60, height: 60))
                            
                            Text("Profile")
                                .font(TornyFonts.title1)
                                .foregroundColor(.tornyTextPrimary)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 20)
                        
                        // User Info Card
                        if let user = apiService.currentUser {
                            TornyCard {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Account Information")
                                        .font(TornyFonts.title3)
                                        .foregroundColor(.tornyTextPrimary)
                                    
                                    ProfileRow(label: "Name", value: user.name)
                                    ProfileRow(label: "Email", value: user.email)
                                    ProfileRow(label: "User Type", value: user.userType.capitalized)
                                    
                                    if let phone = user.phone {
                                        ProfileRow(label: "Phone", value: phone)
                                    }
                                    
                                    if let sport = user.sport {
                                        ProfileRow(label: "Sport", value: sport)
                                    }
                                    
                                    if let club = user.club {
                                        ProfileRow(label: "Club", value: club)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Actions
                        VStack(spacing: 16) {
                            Button("Edit Profile") {
                                // TODO: Implement edit profile
                            }
                            .buttonStyle(TornySecondaryButton(isLarge: true))
                            .frame(maxWidth: .infinity)
                            
                            Button("Sign Out") {
                                apiService.logout()
                            }
                            .buttonStyle(TornyPrimaryButton(isLarge: true))
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ProfileRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(TornyFonts.body)
                .foregroundColor(.tornyTextSecondary)
            Spacer()
            Text(value)
                .font(TornyFonts.body)
                .foregroundColor(.tornyTextPrimary)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Dashboard View
struct MainDashboardView: View {
    @ObservedObject private var apiService = APIService.shared
    @State private var showSidebar = false
    @State private var selectedView: DashboardView? = nil
    @State private var showingTrainingSetup = false
    @State private var currentTrainingSession: TrainingSession? = nil
    @State private var selectedBottomTab = 0
    
    var body: some View {
        ZStack {
            if let currentView = selectedView {
                // Show selected view
                Group {
                    switch currentView {
                    case .analytics:
                        AnalyticsView()
                    case .profile:
                        ProfileView()
                    case .history:
                        SessionHistoryView()
                    case .settings:
                        VStack(spacing: 0) {
                            // Navigation bar
                            TornyNavBar(showSidebar: $showSidebar)
                            
                            // Settings content
                            ProfileSetupView {
                                // Settings completion callback - go back to dashboard
                                selectedView = nil
                            }
                            
                            // Bottom navigation
                            TornyBottomNavigation(
                                selectedTab: $selectedBottomTab,
                                onHomeTap: { 
                                    selectedView = nil
                                    selectedBottomTab = 0
                                },
                                onTrainingTap: { 
                                    showingTrainingSetup = true
                                    selectedBottomTab = 1
                                },
                                onAnalyticsTap: { 
                                    selectedView = .analytics
                                    selectedBottomTab = 2
                                },
                                onProfileTap: { 
                                    selectedView = .profile
                                    selectedBottomTab = 3
                                }
                            )
                        }
                    }
                }
                // Back button overlay for views that need it
                .overlay(
                    Group {
                        if currentView != .settings {
                            VStack {
                                HStack {
                                    Button(action: {
                                        selectedView = nil
                                    }) {
                                        HStack {
                                            Image(systemName: "chevron.left")
                                            Text("Dashboard")
                                        }
                                        .foregroundColor(.tornyBlue)
                                        .padding()
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    },
                    alignment: .topLeading
                )
            } else if let trainingSession = currentTrainingSession {
                // Show training session view
                RealTrainingSessionView(session: trainingSession) {
                    // Session end callback
                    currentTrainingSession = nil
                }
            } else {
                // Show main dashboard
                VStack(spacing: 0) {
                    // Navigation bar
                    TornyNavBar(showSidebar: $showSidebar)
                    
                    // Main content
                    ZStack {
                        TornyBackgroundView()
                        
                        ScrollView {
                            VStack(spacing: 24) {
                                // Welcome section
                                VStack(spacing: 16) {
                                    Text("Welcome back, \(apiService.userFirstName)!")
                                        .font(TornyFonts.title1)
                                        .fontWeight(.bold)
                                        .foregroundColor(.tornyTextPrimary)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Ready to improve your bowling game?")
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.top, 40)
                                .padding(.horizontal, 20)
                                
                                // Quick actions
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ], spacing: 16) {
                                    
                                    // Start Training
                                    DashboardActionCard(
                                        icon: "target",
                                        title: "Start Training",
                                        subtitle: "Begin a new session",
                                        color: .tornyBlue
                                    ) {
                                        showingTrainingSetup = true
                                    }
                                    
                                    // View Analytics
                                    DashboardActionCard(
                                        icon: "chart.bar.fill",
                                        title: "Analytics",
                                        subtitle: "Track your progress",
                                        color: .tornyGreen
                                    ) {
                                        selectedView = .analytics
                                    }
                                    
                                    // Session History
                                    DashboardActionCard(
                                        icon: "clock.fill",
                                        title: "History",
                                        subtitle: "Past sessions",
                                        color: .tornyPurple
                                    ) {
                                        selectedView = .history
                                    }
                                    
                                    // Profile Settings
                                    DashboardActionCard(
                                        icon: "person.crop.circle.fill",
                                        title: "Profile",
                                        subtitle: "Manage settings",
                                        color: .orange
                                    ) {
                                        selectedView = .profile
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                // Recent activity section
                                TornyCard {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Recent Activity")
                                            .font(TornyFonts.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.tornyTextPrimary)
                                        
                                        VStack(spacing: 12) {
                                            DashboardActivityRow(
                                                icon: "target",
                                                title: "Training Session",
                                                subtitle: "Completed 45 minutes ago",
                                                color: .tornyBlue
                                            )
                                            
                                            Divider()
                                            
                                            DashboardActivityRow(
                                                icon: "chart.line.uptrend.xyaxis",
                                                title: "Personal Best",
                                                subtitle: "New accuracy record: 85%",
                                                color: .tornyGreen
                                            )
                                            
                                            Divider()
                                            
                                            DashboardActivityRow(
                                                icon: "person.2.fill",
                                                title: "Joined Club",
                                                subtitle: "\(apiService.currentUser?.club ?? "Local Club")",
                                                color: .tornyPurple
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                Spacer(minLength: 100)
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    
                    // Bottom navigation
                    TornyBottomNavigation(
                        selectedTab: $selectedBottomTab,
                        onHomeTap: { 
                            selectedView = nil
                            selectedBottomTab = 0
                        },
                        onTrainingTap: { 
                            showingTrainingSetup = true
                            selectedBottomTab = 1
                        },
                        onAnalyticsTap: { 
                            selectedView = .analytics
                            selectedBottomTab = 2
                        },
                        onProfileTap: { 
                            selectedView = .profile
                            selectedBottomTab = 3
                        }
                    )
                }
                
                // Sidebar overlay
                if showSidebar {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { showSidebar = false }
                    
                    HStack {
                        TornySidebar(isPresented: $showSidebar) { view in
                            selectedView = view
                        }
                        Spacer()
                    }
                    .transition(.move(edge: .leading))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSidebar)
        .onChange(of: selectedView) { newView in
            // Sync bottom tab selection with current view
            switch newView {
            case nil:
                selectedBottomTab = 0  // Home
            case .analytics:
                selectedBottomTab = 2  // Analytics
            case .profile:
                selectedBottomTab = 3  // Profile
            default:
                break
            }
        }
        .sheet(isPresented: $showingTrainingSetup) {
            RealTrainingSetupView { session in
                // Session created callback
                showingTrainingSetup = false
                currentTrainingSession = session
            }
        }
    }
}

// MARK: - Dashboard Action Card
struct DashboardActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(TornyFonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.tornyTextPrimary)
                    
                    Text(subtitle)
                        .font(TornyFonts.bodySecondary)
                        .foregroundColor(.tornyTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Dashboard Activity Row
struct DashboardActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TornyFonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(.tornyTextPrimary)
                
                Text(subtitle)
                    .font(TornyFonts.bodySecondary)
                    .foregroundColor(.tornyTextSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Real Training Setup View
struct RealTrainingSetupView: View {
    @ObservedObject private var apiService = APIService.shared
    @State private var location = "outdoor"
    @State private var greenType = "bent"
    @State private var greenSpeed = 14
    @State private var rinkNumber = ""
    @State private var weather = "warm"
    @State private var windConditions = "light"
    @State private var notes = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let locations = ["outdoor", "indoor"]
    let outdoorGreenTypes = ["couch", "tift", "bent", "synthetic"]
    let indoorGreenTypes = ["carpet", "synthetic"]
    let weatherOptions = ["cold", "warm", "hot"]
    let windOptions = ["no_wind", "light", "moderate", "strong"]
    
    var availableGreenTypes: [String] {
        location == "indoor" ? indoorGreenTypes : outdoorGreenTypes
    }
    
    var onSessionCreated: ((TrainingSession) -> Void)?
    
    init(onSessionCreated: ((TrainingSession) -> Void)? = nil) {
        self.onSessionCreated = onSessionCreated
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "target")
                                .font(.system(size: 60))
                                .foregroundColor(.tornyBlue)
                            
                            Text("Start Training Session")
                                .font(TornyFonts.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.tornyTextPrimary)
                            
                            Text("Set up your green conditions and environmental factors")
                                .font(TornyFonts.body)
                                .foregroundColor(.tornyTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        
                        // Green Conditions
                        TornyCard {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Green Conditions")
                                    .font(TornyFonts.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.tornyTextPrimary)
                                
                                // Location
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Location")
                                            .font(TornyFonts.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.tornyTextPrimary)
                                        Text("*")
                                            .foregroundColor(.red)
                                    }
                                    
                                    HStack(spacing: 12) {
                                        ForEach(locations, id: \.self) { loc in
                                            Button(action: {
                                                let previousLocation = location
                                                location = loc
                                                
                                                // Reset green type if switching location and current type isn't available
                                                if previousLocation != loc && !availableGreenTypes.contains(greenType) {
                                                    greenType = loc == "indoor" ? "carpet" : "bent"
                                                }
                                            }) {
                                                HStack {
                                                    Image(systemName: location == loc ? "checkmark.circle.fill" : "circle")
                                                        .foregroundColor(.tornyBlue)
                                                    Text(loc.capitalized)
                                                        .font(TornyFonts.body)
                                                        .foregroundColor(.tornyTextPrimary)
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(location == loc ? Color.tornyBlue.opacity(0.1) : Color.white)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(location == loc ? Color.tornyBlue : Color.tornyLightBlue, lineWidth: 1)
                                                        )
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                                
                                // Green Type
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Green Type")
                                            .font(TornyFonts.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.tornyTextPrimary)
                                        Text("*")
                                            .foregroundColor(.red)
                                    }
                                    
                                    Menu {
                                        ForEach(availableGreenTypes, id: \.self) { type in
                                            Button(type.capitalized) {
                                                greenType = type
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(greenType.capitalized)
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
                                    
                                    Text(location == "indoor" ? "Indoor: Carpet or Synthetic surfaces" : "Outdoor: Natural grass or synthetic surfaces")
                                        .font(TornyFonts.caption)
                                        .foregroundColor(.tornyTextSecondary)
                                }
                                
                                // Green Speed
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        HStack {
                                            Text("Green Speed")
                                                .font(TornyFonts.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.tornyTextPrimary)
                                            Text("*")
                                                .foregroundColor(.red)
                                        }
                                        Spacer()
                                        Text("\(greenSpeed) seconds")
                                            .font(TornyFonts.body)
                                            .foregroundColor(.tornyBlue)
                                            .fontWeight(.medium)
                                    }
                                    
                                    Slider(value: .init(
                                        get: { Double(greenSpeed) },
                                        set: { greenSpeed = Int($0) }
                                    ), in: 8...22, step: 1)
                                    .accentColor(.tornyBlue)
                                    
                                    HStack {
                                        Text("8 sec (Fast)")
                                            .font(TornyFonts.caption)
                                            .foregroundColor(.tornyTextSecondary)
                                        Spacer()
                                        Text("22 sec (Slow)")
                                            .font(TornyFonts.caption)
                                            .foregroundColor(.tornyTextSecondary)
                                    }
                                }
                                
                                // Rink Number
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Rink Number (Optional)")
                                        .font(TornyFonts.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.tornyTextPrimary)
                                    
                                    TextField("Enter rink number", text: $rinkNumber)
                                        .textFieldStyle(TornyTextFieldStyle())
                                        .keyboardType(.numberPad)
                                    
                                    Text("Rink number (1-8)")
                                        .font(TornyFonts.caption)
                                        .foregroundColor(.tornyTextSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Environmental Conditions (Outdoor Only)
                        if location == "outdoor" {
                            TornyCard {
                                VStack(alignment: .leading, spacing: 20) {
                                    Text("Environmental Conditions")
                                        .font(TornyFonts.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.tornyTextPrimary)
                                    
                                    // Weather
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Weather")
                                                .font(TornyFonts.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.tornyTextPrimary)
                                            Text("*")
                                                .foregroundColor(.red)
                                        }
                                        
                                        HStack(spacing: 12) {
                                            ForEach(weatherOptions, id: \.self) { w in
                                                Button(action: {
                                                    weather = w
                                                }) {
                                                    VStack(spacing: 4) {
                                                        Text(weatherIcon(for: w))
                                                            .font(.title2)
                                                        Text(w.capitalized)
                                                            .font(TornyFonts.bodySecondary)
                                                            .foregroundColor(.tornyTextPrimary)
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 12)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(weather == w ? Color.tornyBlue.opacity(0.1) : Color.white)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 12)
                                                                    .stroke(weather == w ? Color.tornyBlue : Color.tornyLightBlue, lineWidth: 1)
                                                            )
                                                    )
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                    
                                    // Wind Conditions
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Wind Conditions")
                                                .font(TornyFonts.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.tornyTextPrimary)
                                            Text("*")
                                                .foregroundColor(.red)
                                        }
                                        
                                        Menu {
                                            ForEach(windOptions, id: \.self) { wind in
                                                Button(windDisplayName(for: wind)) {
                                                    windConditions = wind
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(windDisplayName(for: windConditions))
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
                            .padding(.horizontal, 20)
                        }
                        
                        // Notes
                        TornyCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Session Notes (Optional)")
                                    .font(TornyFonts.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.tornyTextPrimary)
                                
                                ZStack(alignment: .topLeading) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.tornyLightBlue, lineWidth: 1)
                                        )
                                        .frame(height: 100)
                                    
                                    TextEditor(text: $notes)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextPrimary)
                                }
                                
                                Text("Any additional notes about conditions... (max 500 characters)")
                                    .font(TornyFonts.caption)
                                    .foregroundColor(.tornyTextSecondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Start Training Button
                        Button(action: createSession) {
                            HStack {
                                if isLoading {
                                    TornyLoadingView(color: .white)
                                    Text("Creating Session...")
                                } else {
                                    Image(systemName: "play.fill")
                                    Text("Start Training Session")
                                }
                            }
                        }
                        .buttonStyle(TornyPrimaryButton(isLarge: true))
                        .frame(maxWidth: .infinity)
                        .disabled(isLoading)
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func weatherIcon(for weather: String) -> String {
        switch weather {
        case "cold": return "❄️"
        case "warm": return "☀️"
        case "hot": return "🔥"
        default: return "☀️"
        }
    }
    
    private func windDisplayName(for wind: String) -> String {
        switch wind {
        case "light": return "Light breeze"
        case "moderate": return "Moderate wind"
        case "strong": return "Strong wind"
        default: return "Light breeze"
        }
    }
    
    private func createSession() {
        isLoading = true
        
        let request = CreateSessionRequest(
            location: Location(rawValue: location) ?? .outdoor,
            greenType: GreenType(rawValue: greenType) ?? .bent,
            greenSpeed: greenSpeed,
            rinkNumber: rinkNumber.isEmpty ? nil : Int(rinkNumber),
            weather: location == "outdoor" ? Weather(rawValue: weather) : nil,
            windConditions: location == "outdoor" ? WindConditions(rawValue: windConditions) : nil,
            notes: notes.isEmpty ? nil : notes
        )
        
        Task {
            do {
                let response = try await apiService.createSession(request)
                await MainActor.run {
                    onSessionCreated?(response.session)
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
}

// MARK: - Real Training Session View
struct RealTrainingSessionView: View {
    @ObservedObject private var apiService = APIService.shared
    let session: TrainingSession
    let onSessionEnd: (() -> Void)?
    @State private var currentShot = ShotData()
    @State private var sessionStats = SessionStatistics(
        totalShots: 0,
        totalPoints: "0",
        maxPossiblePoints: 0,
        averageScore: "0.00",
        accuracyPercentage: "0.0",
        drawShots: "0",
        drawPoints: "0",
        drawAccuracyPercentage: nil,
        yardOnShots: "0",
        yardOnPoints: "0", 
        yardOnAccuracyPercentage: nil,
        ditchWeightShots: "0",
        ditchWeightPoints: "0",
        ditchWeightAccuracyPercentage: nil,
        driveShots: "0",
        drivePoints: "0",
        driveAccuracyPercentage: nil,
        weightedShots: "0",
        weightedPoints: "0",
        weightedAccuracyPercentage: nil
    )
    @State private var isRecording = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSessionEnd = false
    @State private var showingSuccessMessage = false
    @State private var successMessage = ""
    @State private var currentTime = Date()
    @State private var timer: Timer?
    @State private var sessionStartTime: Date = Date()
    @State private var sessionDurationSeconds: Int?
    
    let shotTypes = ["draw", "yard_on", "ditch_weight", "drive"]
    let hands = ["forehand", "backhand"]
    let lengths = ["short", "medium", "long"]
    let distanceOptions: [DistanceFromJack] = [.foot, .yard, .miss]
    
    var body: some View {
        ZStack {
            TornyBackgroundView()
            
            ScrollView {
                    VStack(spacing: 24) {
                        // Session Info Header moved into scroll content
                        sessionInfoHeader
                        
                        VStack(spacing: 24) {
                            // Live Stats
                            liveStatsCard
                            
                            // Shot Recording Form
                            shotRecordingForm
                            
                            // Record Shot Button
                            recordShotButton
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .alert("Success!", isPresented: $showingSuccessMessage) {
            Button("Continue") { }
        } message: {
            Text(successMessage)
        }
        .sheet(isPresented: $showingSessionEnd) {
            SessionEndView(session: session, stats: sessionStats, durationSeconds: sessionDurationSeconds, onReturn: onSessionEnd)
                .onAppear {
                    print("Sheet is being presented - showingSessionEnd: \(showingSessionEnd)")
                }
        }
    }
    
    private var sessionInfoHeader: some View {
        TornyCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Training Session")
                            .font(TornyFonts.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.tornyTextPrimary)
                        
                        if session.isActive == true {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                        }
                    }

                    Text("\(session.greenType.rawValue.capitalized) • \(session.greenSpeed)s • \(session.location.rawValue.capitalized)")
                        .font(TornyFonts.bodySecondary)
                        .foregroundColor(.tornyTextSecondary)
                    
                    // Timer display  
                    HStack(spacing: 4) {
                        Image(systemName: session.isActive == true ? "clock" : "clock.fill")
                            .font(.caption)
                        Text(formattedElapsedTime)
                            .font(TornyFonts.caption)
                            .fontWeight(.semibold)
                            .monospacedDigit() // Ensures consistent width for changing numbers
                    }
                    .foregroundColor(session.isActive == true ? .tornyBlue : .gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((session.isActive == true ? Color.tornyBlue : Color.gray).opacity(0.1))
                    .cornerRadius(8)
                    .scaleEffect(session.isActive == true ? 1.0 : 0.95)
                    .animation(.easeInOut(duration: 0.2), value: session.isActive)
                }
                
                Spacer()
                
                Button(action: {
                    endSessionWithTiming()
                }) {
                    Text("End")
                        .font(TornyFonts.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var formattedElapsedTime: String {
        // Use session startedAt if available, otherwise use the stored session start time
        let startTime = session.startedAt ?? sessionStartTime
        
        let elapsedTime: TimeInterval = currentTime.timeIntervalSince(startTime)
        
        // Ensure we don't show negative times
        let positiveElapsedTime = max(0, elapsedTime)
        
        let hours = Int(positiveElapsedTime) / 3600
        let minutes = Int(positiveElapsedTime) % 3600 / 60
        let seconds = Int(positiveElapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private func startTimer() {
        // Ensure we don't have multiple timers running
        stopTimer()
        
        // Set the session start time if not already set
        if session.startedAt == nil {
            sessionStartTime = Date()
        } else {
            sessionStartTime = session.startedAt!
        }
        
        // Start a new timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private var liveStatsCard: some View {
        TornyCard {
            VStack(spacing: 16) {
                // Overall session stats
                VStack(spacing: 8) {
                    Text("Session Overview")
                        .font(TornyFonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.tornyTextPrimary)
                    
                    HStack {
                        StatItem(
                            title: "Total Shots",
                            value: "\(sessionStats.totalShots)"
                        )
                        
                        Divider()
                            .frame(height: 30)
                        
                        StatItem(
                            title: "Points",
                            value: "\(sessionStats.totalPoints ?? "0")/\(sessionStats.maxPossiblePoints ?? 0)"
                        )
                        
                        Divider()
                            .frame(height: 30)
                        
                        StatItem(
                            title: "Accuracy",
                            value: "\(sessionStats.accuracyPercentage)%"
                        )
                    }
                }
                
                Divider()
                
                // Shot type breakdown
                VStack(spacing: 8) {
                    Text("Shot Type Breakdown")
                        .font(TornyFonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.tornyTextPrimary)
                    
                    VStack(spacing: 6) {
                        ShotTypeStatRow(
                            title: "Draw",
                            shots: sessionStats.shotCountForType("draw"),
                            points: sessionStats.pointsForType("draw"),
                            accuracy: sessionStats.displayAccuracyForType("draw")
                        )
                        
                        ShotTypeStatRow(
                            title: "Yard On",
                            shots: sessionStats.shotCountForType("yard_on"),
                            points: sessionStats.pointsForType("yard_on"),
                            accuracy: sessionStats.displayAccuracyForType("yard_on")
                        )
                        
                        ShotTypeStatRow(
                            title: "Ditch Weight",
                            shots: sessionStats.shotCountForType("ditch_weight"),
                            points: sessionStats.pointsForType("ditch_weight"),
                            accuracy: sessionStats.displayAccuracyForType("ditch_weight")
                        )
                        
                        ShotTypeStatRow(
                            title: "Drive",
                            shots: sessionStats.shotCountForType("drive"),
                            points: sessionStats.pointsForType("drive"),
                            accuracy: sessionStats.displayAccuracyForType("drive")
                        )
                    }
                }
            }
        }
    }
    
    private var shotRecordingForm: some View {
        TornyCard {
            VStack(alignment: .leading, spacing: 20) {
                Text("Record Shot")
                    .font(TornyFonts.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.tornyTextPrimary)
                
                // Shot Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Shot Type")
                        .font(TornyFonts.body)
                        .fontWeight(.medium)
                        .foregroundColor(.tornyTextPrimary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(shotTypes, id: \.self) { type in
                            Button(action: {
                                currentShot.shotType = type
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: shotTypeIcon(for: type))
                                        .font(.title2)
                                        .foregroundColor(currentShot.shotType == type ? .white : .tornyBlue)
                                    
                                    Text(shotTypeDisplayName(for: type))
                                        .font(TornyFonts.bodySecondary)
                                        .foregroundColor(currentShot.shotType == type ? .white : .tornyTextPrimary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(currentShot.shotType == type ? Color.tornyBlue : Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(currentShot.shotType == type ? Color.tornyBlue : Color.tornyLightBlue, lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Hand and Length
                HStack(spacing: 16) {
                    // Hand
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hand")
                            .font(TornyFonts.body)
                            .fontWeight(.medium)
                            .foregroundColor(.tornyTextPrimary)
                        
                        VStack(spacing: 8) {
                            ForEach(hands, id: \.self) { hand in
                                Button(action: {
                                    currentShot.hand = hand
                                }) {
                                    HStack {
                                        Image(systemName: currentShot.hand == hand ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(.tornyBlue)
                                        Text(hand.capitalized)
                                            .font(TornyFonts.body)
                                            .foregroundColor(.tornyTextPrimary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(currentShot.hand == hand ? Color.tornyBlue.opacity(0.1) : Color.clear)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Length
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Length")
                            .font(TornyFonts.body)
                            .fontWeight(.medium)
                            .foregroundColor(.tornyTextPrimary)
                        
                        VStack(spacing: 8) {
                            ForEach(lengths, id: \.self) { length in
                                Button(action: {
                                    currentShot.length = length
                                }) {
                                    HStack {
                                        Image(systemName: currentShot.length == length ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(.tornyBlue)
                                        Text(length.capitalized)
                                            .font(TornyFonts.body)
                                            .foregroundColor(.tornyTextPrimary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(currentShot.length == length ? Color.tornyBlue.opacity(0.1) : Color.clear)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Shot-specific fields
                if currentShot.shotType == "draw" {
                    drawShotFields
                } else if ["yard_on", "ditch_weight", "drive"].contains(currentShot.shotType) {
                    weightedShotFields
                }
                
                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (Optional)")
                        .font(TornyFonts.body)
                        .fontWeight(.medium)
                        .foregroundColor(.tornyTextPrimary)
                    
                    TextField("Add notes about this shot", text: $currentShot.notes)
                        .textFieldStyle(TornyTextFieldStyle())
                }
            }
        }
    }
    
    private var drawShotFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Distance from Jack")
                .font(TornyFonts.body)
                .fontWeight(.medium)
                .foregroundColor(.tornyTextPrimary)
            
            VStack(spacing: 12) {
                ForEach(distanceOptions, id: \.self) { distance in
                    Button(action: {
                        currentShot.distanceFromJack = distance
                    }) {
                        HStack {
                            Image(systemName: currentShot.distanceFromJack == distance ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(
                                    distance == .foot ? .tornyGreen : 
                                    distance == .yard ? .tornyPurple : .red
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(distanceDisplayName(for: distance))
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextPrimary)
                                
                                Text(distanceDescription(for: distance))
                                    .font(TornyFonts.bodySecondary)
                                    .foregroundColor(
                                        distance == .foot ? .tornyGreen : 
                                        distance == .yard ? .tornyTextSecondary : .red
                                    )
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(currentShot.distanceFromJack == distance ? Color.tornyBlue.opacity(0.1) : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(currentShot.distanceFromJack == distance ? Color.tornyBlue : Color.tornyLightBlue, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var weightedShotFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Distance from Target")
                .font(TornyFonts.body)
                .fontWeight(.medium)
                .foregroundColor(.tornyTextPrimary)
            
            VStack(spacing: 12) {
                // Within Foot (2 points)
                Button(action: {
                    currentShot.distanceFromJack = .foot
                }) {
                    HStack {
                        Image(systemName: currentShot.distanceFromJack == .foot ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.tornyGreen)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Within Foot")
                                .font(TornyFonts.body)
                                .fontWeight(.medium)
                                .foregroundColor(.tornyTextPrimary)
                            Text("2 points!")
                                .font(TornyFonts.bodySecondary)
                                .foregroundColor(.tornyGreen)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(currentShot.distanceFromJack == .foot ? Color.tornyGreen.opacity(0.1) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(currentShot.distanceFromJack == .foot ? Color.tornyGreen : Color.tornyLightBlue, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Within Target (1 point)
                Button(action: {
                    currentShot.distanceFromJack = .yard
                }) {
                    HStack {
                        Image(systemName: currentShot.distanceFromJack == .yard ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.tornyPurple)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Within Yard")
                                .font(TornyFonts.body)
                                .fontWeight(.medium)
                                .foregroundColor(.tornyTextPrimary)
                            Text("Close")
                                .font(TornyFonts.bodySecondary)
                                .foregroundColor(.tornyPurple)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(currentShot.distanceFromJack == .yard ? Color.tornyPurple.opacity(0.1) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(currentShot.distanceFromJack == .yard ? Color.tornyPurple : Color.tornyLightBlue, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Missed Completely (0 points)
                Button(action: {
                    currentShot.distanceFromJack = .miss
                }) {
                    HStack {
                        Image(systemName: currentShot.distanceFromJack == .miss ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Missed Completely")
                                .font(TornyFonts.body)
                                .fontWeight(.medium)
                                .foregroundColor(.tornyTextPrimary)
                            Text("Too far from target")
                                .font(TornyFonts.bodySecondary)
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(currentShot.distanceFromJack == .miss ? Color.red.opacity(0.1) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(currentShot.distanceFromJack == .miss ? Color.red : Color.tornyLightBlue, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var recordShotButton: some View {
        Button(action: recordShot) {
            HStack {
                if isRecording {
                    TornyLoadingView(color: .white)
                    Text("Recording...")
                } else {
                    Image(systemName: "plus.circle.fill")
                    Text("Record Shot")
                }
            }
        }
        .buttonStyle(TornyPrimaryButton(isLarge: true))
        .frame(maxWidth: .infinity)
        .disabled(isRecording || !currentShot.isValid)
    }
    
    private func shotTypeIcon(for type: String) -> String {
        switch type {
        case "draw": return "target"
        case "yard_on": return "arrow.forward.circle"
        case "ditch_weight": return "arrow.down.circle"
        case "drive": return "bolt.circle"
        default: return "target"
        }
    }
    
    private func shotTypeDisplayName(for type: String) -> String {
        switch type {
        case "yard_on": return "Yard On"
        case "ditch_weight": return "Ditch Weight"
        default: return type.capitalized
        }
    }
    
    private func recordShot() {
        isRecording = true
        
        let shotRequest = RecordShotRequest(
            sessionId: session.id,
            shotType: ShotType(rawValue: currentShot.shotType) ?? .draw,
            hand: Hand(rawValue: currentShot.hand) ?? .forehand,
            length: Length(rawValue: currentShot.length) ?? .medium,
            distanceFromJack: currentShot.distanceFromJack ?? .yard,
            notes: currentShot.notes.isEmpty ? nil : currentShot.notes
        )
        
        Task {
            do {
                let response = try await apiService.recordShot(shotRequest)
                
                await MainActor.run {
                    isRecording = false
                    sessionStats = response.sessionStats
                    let recordedShotType = currentShot.shotType // Store before reset
                    currentShot = ShotData() // Reset form
                    
                    // Show success message
                    let shotName = shotTypeDisplayName(for: recordedShotType)
                    let points = response.shot.score ?? 0
                    successMessage = "\(shotName) shot recorded! Scored \(points) points."
                    showingSuccessMessage = true
                    
                    // Auto-dismiss after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        showingSuccessMessage = false
                    }
                }
            } catch {
                await MainActor.run {
                    isRecording = false
                    alertMessage = "Failed to record shot: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func endSessionWithTiming() {
        Task {
            do {
                // Calculate duration from frontend timer
                let endTime = Date()
                let startTime = session.startedAt ?? sessionStartTime
                let duration = Int(endTime.timeIntervalSince(startTime))
                
                // Create request with frontend-calculated duration
                let request = EndSessionRequest(
                    endedAt: endTime.ISO8601Format(),
                    durationSeconds: duration
                )
                
                let response = try await apiService.endSession(session.id, request: request)
                
                await MainActor.run {
                    // Store the session duration for display
                    sessionDurationSeconds = duration
                    // Stop the timer since session is ending
                    stopTimer()
                    // Show end session with duration
                    showingSessionEnd = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to end session: \(error.localizedDescription)"
                    showingAlert = true
                    
                    // Fallback to original behavior on error
                    onSessionEnd?()
                }
            }
        }
    }
    
    private func distanceDisplayName(for distance: DistanceFromJack) -> String {
        switch distance {
        case .foot: return "Within Foot"
        case .yard: return "Within Yard"
        case .miss: return "Missed Completely"
        }
    }
    
    private func distanceDescription(for distance: DistanceFromJack) -> String {
        switch distance {
        case .foot: return "Success!"
        case .yard: return "Close"
        case .miss: return "Too far from jack"
        }
    }
}

// MARK: - Supporting Views and Models for Training Session

struct ShotData {
    var shotType: String = "draw"
    var hand: String = "forehand"
    var length: String = "medium"
    var distanceFromJack: DistanceFromJack? = nil
    var notes: String = ""
    
    var isValid: Bool {
        return distanceFromJack != nil
    }
}

struct ShotTypeStatRow: View {
    let title: String
    let shots: String
    let points: String
    let accuracy: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(TornyFonts.body)
                .fontWeight(.medium)
                .foregroundColor(.tornyTextPrimary)
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            Text("\(shots) shots")
                .font(TornyFonts.caption)
                .foregroundColor(.tornyTextSecondary)
                .frame(width: 60, alignment: .trailing)
            
            Text("\(points) pts")
                .font(TornyFonts.caption)
                .foregroundColor(.tornyTextSecondary)
                .frame(width: 40, alignment: .trailing)
            
            Text(accuracy)
                .font(TornyFonts.caption)
                .fontWeight(.medium)
                .foregroundColor(accuracy == "Not practiced" ? .tornyTextSecondary : .tornyBlue)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.tornyLightBlue.opacity(0.1))
        )
    }
}

struct SessionEndView: View {
    let session: TrainingSession
    let stats: SessionStatistics
    let durationSeconds: Int?
    let onReturn: (() -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    var formattedDuration: String {
        guard let duration = durationSeconds else { 
            return "In Progress" 
        }
        
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let secs = duration % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()
                
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.tornyGreen)
                        
                        Text("Session Complete!")
                            .font(TornyFonts.title1)
                            .fontWeight(.bold)
                            .foregroundColor(.tornyTextPrimary)
                        
                        Text("Great work on your training session")
                            .font(TornyFonts.body)
                            .foregroundColor(.tornyTextSecondary)
                    }
                    
                    TornyCard {
                        VStack(spacing: 20) {
                            Text("Session Summary")
                                .font(TornyFonts.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.tornyTextPrimary)
                            
                            // Session Duration
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.tornyBlue)
                                Text("Duration: \(formattedDuration)")
                                    .font(TornyFonts.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.tornyTextPrimary)
                                Spacer()
                            }
                            .padding(.bottom, 8)
                            
                            // Overall session stats
                            VStack(spacing: 8) {
                                Text("Session Overview")
                                    .font(TornyFonts.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.tornyTextPrimary)
                                
                                HStack {
                                    StatItem(
                                        title: "Total Shots",
                                        value: "\(stats.totalShots)"
                                    )
                                    
                                    Divider()
                                        .frame(height: 40)
                                    
                                    StatItem(
                                        title: "Points",
                                        value: "\(stats.totalPoints ?? "0")/\(stats.maxPossiblePoints ?? 0)"
                                    )
                                    
                                    Divider()
                                        .frame(height: 40)
                                    
                                    StatItem(
                                        title: "Accuracy",
                                        value: "\(stats.accuracyPercentage)%"
                                    )
                                }
                            }
                            
                            Divider()
                            
                            // Shot type breakdown
                            VStack(spacing: 8) {
                                Text("Shot Type Performance")
                                    .font(TornyFonts.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.tornyTextPrimary)
                                
                                VStack(spacing: 6) {
                                    ShotTypeStatRow(
                                        title: "Draw",
                                        shots: stats.shotCountForType("draw"),
                                        points: stats.pointsForType("draw"),
                                        accuracy: stats.displayAccuracyForType("draw")
                                    )
                                    
                                    ShotTypeStatRow(
                                        title: "Yard On",
                                        shots: stats.shotCountForType("yard_on"),
                                        points: stats.pointsForType("yard_on"),
                                        accuracy: stats.displayAccuracyForType("yard_on")
                                    )
                                    
                                    ShotTypeStatRow(
                                        title: "Ditch Weight",
                                        shots: stats.shotCountForType("ditch_weight"),
                                        points: stats.pointsForType("ditch_weight"),
                                        accuracy: stats.displayAccuracyForType("ditch_weight")
                                    )
                                    
                                    ShotTypeStatRow(
                                        title: "Drive",
                                        shots: stats.shotCountForType("drive"),
                                        points: stats.pointsForType("drive"),
                                        accuracy: stats.displayAccuracyForType("drive")
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Button("Return to Dashboard") {
                        presentationMode.wrappedValue.dismiss()
                        onReturn?()
                    }
                    .buttonStyle(TornyPrimaryButton(isLarge: true))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
