import SwiftUI
import Foundation


struct ContentView: View {
    @ObservedObject private var apiService = APIService.shared
    @State private var selectedTab = 0
    @State private var showingProfileSetup = false
    @State private var hasCompletedProfile = false
    @State private var showingSplashScreen = true

    var body: some View {
        ZStack {
            if showingSplashScreen {
                LaunchScreen()
                    .transition(.opacity)
            } else {
                if apiService.isAuthenticated {
                    if hasCompletedProfile && !showingProfileSetup {
                        MainDashboardView()
                    } else {
                        ProfileSetupView()
                    }
                } else {
                    AuthView()
                }
            }
        }
        .animation(.easeInOut(duration: 0.8), value: showingSplashScreen)
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

            // Hide splash screen after a brief delay to show the launch screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showingSplashScreen = false
                }
            }
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    @ObservedObject private var apiService = APIService.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TrainingSetupView()
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
                    VStack(spacing: 0) {
                        // Club Banner Section
                        if let user = apiService.currentUser,
                           let clubData = user.clubData,
                           let bannerUrl = clubData.displayBannerUrl {
                            ZStack(alignment: .bottomLeading) {
                                // Banner Image
                                AsyncImage(url: URL(string: bannerUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 200)
                                        .clipped()
                                } placeholder: {
                                    Rectangle()
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [.tornyBlue.opacity(0.3), .tornyPurple.opacity(0.3)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(height: 200)
                                }

                                // Gradient overlay for better text visibility
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.5)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: 100)
                                .frame(maxHeight: .infinity, alignment: .bottom)

                                // Club info overlay
                                HStack(spacing: 12) {
                                    if let logoUrl = clubData.displayLogoUrl {
                                        AsyncImage(url: URL(string: logoUrl)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 60, height: 60)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 2)
                                                )
                                        } placeholder: {
                                            Circle()
                                                .fill(Color.white.opacity(0.3))
                                                .frame(width: 60, height: 60)
                                        }
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(clubData.name)
                                            .font(TornyFonts.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)

                                        Text(clubData.region)
                                            .font(TornyFonts.caption)
                                            .foregroundColor(.white.opacity(0.9))
                                    }

                                    Spacer()
                                }
                                .padding()
                            }
                            .frame(height: 200)
                        } else {
                            // Fallback header when no club banner
                            VStack(spacing: 16) {
                                TornyLogoView(size: CGSize(width: 60, height: 60))

                                Text("Profile")
                                    .font(TornyFonts.title1)
                                    .foregroundColor(.tornyTextPrimary)
                                    .fontWeight(.bold)
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 24)
                        }

                        VStack(spacing: 24) {
                            // User Avatar and Basic Info Card
                            if let user = apiService.currentUser {
                                TornyCard {
                                    VStack(spacing: 20) {
                                        // User Avatar Section
                                        HStack(spacing: 16) {
                                            if let avatarUrl = user.avatarUrl {
                                                AsyncImage(url: URL(string: avatarUrl)) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 80, height: 80)
                                                        .clipShape(Circle())
                                                } placeholder: {
                                                    Circle()
                                                        .fill(Color.tornyBlue.opacity(0.1))
                                                        .frame(width: 80, height: 80)
                                                        .overlay(
                                                            Image(systemName: "person.fill")
                                                                .font(.largeTitle)
                                                                .foregroundColor(.tornyBlue.opacity(0.5))
                                                        )
                                                }
                                            } else {
                                                Circle()
                                                    .fill(Color.tornyBlue.opacity(0.1))
                                                    .frame(width: 80, height: 80)
                                                    .overlay(
                                                        Image(systemName: "person.fill")
                                                            .font(.largeTitle)
                                                            .foregroundColor(.tornyBlue.opacity(0.5))
                                                    )
                                            }

                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(user.name)
                                                    .font(TornyFonts.title2)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.tornyTextPrimary)

                                                Text(user.userType.capitalized)
                                                    .font(TornyFonts.body)
                                                    .foregroundColor(.tornyBlue)

                                                if let created = user.created {
                                                    let year = String(created.prefix(4))
                                                    Text("Member since \(year)")
                                                        .font(TornyFonts.caption)
                                                        .foregroundColor(.tornyTextSecondary)
                                                }
                                            }

                                            Spacer()
                                        }

                                        Divider()

                                        // Account Details
                                        VStack(alignment: .leading, spacing: 12) {
                                            ProfileRow(label: "Email", value: user.email)

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
                                }
                                .padding(.horizontal, 20)
                            }

                            // Actions
                            VStack(spacing: 16) {
                                NavigationLink("Edit Profile", destination: ProfileSetupView())
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
    @State private var selectedView: DashboardNavigationType? = nil
    @State private var showingTrainingSetup = false
    @State private var showingHistory = false
    @State private var showingAnalytics = false
    @State private var showingProfileSetup = false
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

                            // Profile content with banner
                            ProfileView()

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
                                    showingProfileSetup = true
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
                                    
                                    Text("Practice like a pro!")
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
                                        showingProfileSetup = true
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
                            showingProfileSetup = true
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
                            if view == .history {
                                showingHistory = true
                            } else if view == .analytics {
                                showingAnalytics = true
                            } else if view == .settings {
                                showingProfileSetup = true
                            } else {
                                selectedView = view
                            }
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
        .sheet(isPresented: $showingProfileSetup) {
            ProfileSetupView()
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
