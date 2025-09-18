import SwiftUI
import Foundation


struct ContentView: View {
    @ObservedObject private var apiService = APIService.shared
    @State private var selectedTab = 0
    @State private var showingProfileSetup = false
    @State private var hasCompletedProfile = false
    
    var body: some View {
        Group {
            if apiService.isAuthenticated {
                if hasCompletedProfile && !showingProfileSetup {
                    MainDashboardView()
                } else {
                    ProfileSetupView {
                        // Profile completion callback
                        hasCompletedProfile = true
                        showingProfileSetup = false
                    }
                }
            } else {
                AuthView()
            }
        }
        .onChange(of: apiService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // Check profile completion status when user logs in
                hasCompletedProfile = UserDefaults.standard.bool(forKey: "profile_completed") || apiService.currentUser?.profileCompleted == 1
                showingProfileSetup = !hasCompletedProfile
            }
        }
        .onAppear {
            // Initialize profile completion state
            if apiService.isAuthenticated {
                hasCompletedProfile = UserDefaults.standard.bool(forKey: "profile_completed") || apiService.currentUser?.profileCompleted == 1
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
    @State private var isRefreshing = false

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
                        if isRefreshing {
                            TornyCard {
                                VStack(spacing: 16) {
                                    TornyLoadingView(color: .tornyBlue)
                                    Text("Refreshing profile...")
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextSecondary)
                                }
                                .frame(minHeight: 200)
                            }
                            .padding(.horizontal, 20)
                        } else if let user = apiService.currentUser {
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
        .onAppear {
            refreshProfile()
        }
        .refreshable {
            await refreshProfileAsync()
        }
    }

    private func refreshProfile() {
        guard !isRefreshing else { return }

        Task {
            await refreshProfileAsync()
        }
    }

    private func refreshProfileAsync() async {
        guard let userIdString = UserDefaults.standard.string(forKey: "current_user_id"),
              let userId = Int(userIdString) else {
            print("❌ No stored user ID found for profile refresh")
            return
        }

        await MainActor.run {
            isRefreshing = true
        }

        do {
            let updatedUser = try await apiService.getUserProfile(userId)
            await MainActor.run {
                apiService.currentUser = updatedUser
                isRefreshing = false
                print("✅ Profile refreshed successfully")
            }
        } catch {
            await MainActor.run {
                isRefreshing = false
                print("❌ Failed to refresh profile: \(error.localizedDescription)")
            }
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
    @State private var showingHistory = false
    @State private var showingAnalytics = false
    @State private var currentTrainingSession: TrainingSession? = nil
    @State private var selectedBottomTab = 0
    
    var body: some View {
        ZStack {
            if let currentView = selectedView {
                // Show selected view
                Group {
                    switch currentView {
                    case .analytics:
                        // Analytics is now handled by sheet presentation
                        EmptyView()
                    case .profile:
                        ProfileView()
                    case .history:
                        // History is now handled by sheet presentation
                        EmptyView()
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
                                    selectedView = .settings
                                    selectedBottomTab = 3
                                }
                            )
                        }
                    }
                }
                // Back button overlay for views that need it
                .safeAreaInset(edge: .top) {
                    if currentView != .settings && currentView != .history && currentView != .analytics {
                        HStack {
                            TornyBackButton(title: "Back") {
                                print("🔙 Back button tapped, setting selectedView to nil")
                                selectedView = nil
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.95))
                    }
                }
            } else if let trainingSession = currentTrainingSession {
                // Show training session view
                TrainingSessionView(session: trainingSession) {
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
                                        showingAnalytics = true
                                    }
                                    
                                    // Session History
                                    DashboardActionCard(
                                        icon: "clock.fill",
                                        title: "History",
                                        subtitle: "Past sessions",
                                        color: .tornyPurple
                                    ) {
                                        showingHistory = true
                                    }
                                    
                                    // Profile Settings
                                    DashboardActionCard(
                                        icon: "person.crop.circle.fill",
                                        title: "Profile",
                                        subtitle: "Manage settings",
                                        color: .orange
                                    ) {
                                        selectedView = .settings
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
                            showingAnalytics = true
                            selectedBottomTab = 2
                        },
                        onProfileTap: {
                            selectedView = .settings
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
                        Spacer()
                        TornySidebar(isPresented: $showSidebar) { view in
                            if view == .history {
                                showingHistory = true
                            } else if view == .analytics {
                                showingAnalytics = true
                            } else {
                                selectedView = view
                            }
                        }
                    }
                    .transition(.move(edge: .trailing))
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
                // Analytics is now handled by modal, don't change tab
                break
            case .profile:
                selectedBottomTab = 3  // Profile
            default:
                break
            }
        }
        .onChange(of: showingAnalytics) { showing in
            if !showing {
                selectedBottomTab = 0  // Reset to home when analytics modal is dismissed
            }
        }
        .onChange(of: showingHistory) { showing in
            if !showing {
                selectedBottomTab = 0  // Reset to home when history modal is dismissed
            }
        }
        .sheet(isPresented: $showingTrainingSetup) {
            TrainingSetupView { session in
                // Session created callback
                showingTrainingSetup = false
                currentTrainingSession = session
            }
        }
        .sheet(isPresented: $showingHistory) {
            SessionHistoryView()
        }
        .sheet(isPresented: $showingAnalytics) {
            AnalyticsView()
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



// MARK: - Supporting Views and Models for Training Session

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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
