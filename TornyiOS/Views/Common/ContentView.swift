import SwiftUI
import Foundation
import MessageUI


struct ContentView: View {
    @ObservedObject private var apiService = APIService.shared
    @State private var selectedTab = 0
    @State private var showingProfileSetup = false
    @AppStorage("profile_completed") private var profileCompletedStorage = false
    @State private var hasCompletedProfile = false
    @State private var showingSplashScreen = true

    var body: some View {
        ZStack {
            if showingSplashScreen {
                LaunchScreen()
                    .transition(.opacity)
            } else {
                if apiService.isAuthenticated {
                    if hasCompletedProfile {
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
        .onChange(of: apiService.currentUser?.profileCompleted) { newValue in
            if newValue == 1 {
                hasCompletedProfile = true
                profileCompletedStorage = true
            }
        }
        .onChange(of: profileCompletedStorage) { newValue in
            if newValue {
                hasCompletedProfile = true
            }
        }
        .onChange(of: apiService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // Check profile completion status when user logs in
                hasCompletedProfile = profileCompletedStorage || apiService.currentUser?.profileCompleted == 1
                showingProfileSetup = !hasCompletedProfile
            }
        }
        .onAppear {
            // Initialize profile completion state
            if apiService.isAuthenticated {
                hasCompletedProfile = profileCompletedStorage || apiService.currentUser?.profileCompleted == 1
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
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @State private var showSidebar = false
    @State private var selectedView: DashboardNavigationType? = nil
    @State private var showingTrainingSetup = false
    @State private var showingHistory = false
    @State private var showingAnalytics = false
    @State private var showingProfileSetup = false
    @State private var showAIInsights = false
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
                    case .trainingPrograms:
                        NavigationView {
                            TrainingProgramsListView(onDismiss: {
                                selectedView = nil
                            })
                        }
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
                    if currentView != .settings && currentView != .history && currentView != .analytics && currentView != .trainingPrograms {
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
                    // Refresh dashboard data after session completion
                    Task {
                        await dashboardViewModel.loadDashboard()
                    }
                }
            } else {
                // Show main dashboard
                ZStack {
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
                                    
                                    Text("Ready to practice like a pro!")
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

                                // Training Loop Feature Button
                                Button(action: {
                                    showAIInsights = true
                                }) {
                                    HStack(spacing: 16) {
                                        // Icon with gradient background
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [.purple, .blue]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 60, height: 60)

                                            Image(systemName: "chart.line.uptrend.xyaxis")
                                                .font(.system(size: 28))
                                                .foregroundColor(.white)
                                        }

                                        // Text content
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Text("Training Loop")
                                                    .font(TornyFonts.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.tornyTextPrimary)

                                                Image(systemName: "sparkles")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.purple)
                                            }

                                            Text("Understand weaknesses & keep improving")
                                                .font(TornyFonts.bodySecondary)
                                                .foregroundColor(.tornyTextSecondary)
                                                .multilineTextAlignment(.leading)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.tornyTextSecondary)
                                    }
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .shadow(color: Color.purple.opacity(0.2), radius: 8, x: 0, y: 4)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.purple.opacity(0.3), .blue.opacity(0.3)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 20)

                                // Training Programs Button
                                Button(action: {
                                    selectedView = .trainingPrograms
                                }) {
                                    HStack(spacing: 16) {
                                        // Icon with gradient background
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [.orange, .red]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 60, height: 60)

                                            Image(systemName: "list.bullet.clipboard")
                                                .font(.system(size: 28))
                                                .foregroundColor(.white)
                                        }

                                        // Text content
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Text("Training Programs")
                                                    .font(TornyFonts.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.tornyTextPrimary)

                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.orange)
                                            }

                                            Text("Follow structured practice sessions")
                                                .font(TornyFonts.bodySecondary)
                                                .foregroundColor(.tornyTextSecondary)
                                                .multilineTextAlignment(.leading)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.tornyTextSecondary)
                                    }
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .shadow(color: Color.orange.opacity(0.2), radius: 8, x: 0, y: 4)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.orange.opacity(0.3), .red.opacity(0.3)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 20)

                                // Share with Friends Button
                                Button(action: {
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = windowScene.windows.first {
                                        ShareService.shared.shareViaMessages(from: window.rootViewController!)
                                    }
                                }) {
                                    HStack(spacing: 16) {
                                        // Icon with gradient background
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [.tornyGreen, .green]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 60, height: 60)

                                            Image(systemName: "square.and.arrow.up")
                                                .font(.system(size: 28))
                                                .foregroundColor(.white)
                                        }

                                        // Text content
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Text("Share with Friends")
                                                    .font(TornyFonts.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.tornyTextPrimary)

                                                Image(systemName: "heart.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.tornyGreen)
                                            }

                                            Text("Help others improve with guided programs")
                                                .font(TornyFonts.bodySecondary)
                                                .foregroundColor(.tornyTextSecondary)
                                                .multilineTextAlignment(.leading)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.tornyTextSecondary)
                                    }
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .shadow(color: Color.tornyGreen.opacity(0.2), radius: 8, x: 0, y: 4)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.tornyGreen.opacity(0.3), .green.opacity(0.3)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 20)

                                // Shot Performance Section
                                ShotPerformanceSection()

                                // Recent activity section
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Recent Activity")
                                        .font(TornyFonts.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.tornyTextPrimary)

                                    TornyCard {
                                        VStack(alignment: .leading, spacing: 16) {
                                            if dashboardViewModel.isLoading {
                                            HStack {
                                                Spacer()
                                                TornyLoadingView()
                                                Spacer()
                                            }
                                            .padding(.vertical, 40)
                                        } else {
                                            VStack(spacing: 12) {
                                                // Recent session
                                                if let lastSession = dashboardViewModel.recentSessions.first {
                                                    DashboardActivityRow(
                                                        icon: "target",
                                                        title: "Training Session",
                                                        subtitle: recentSessionSubtitle(session: lastSession),
                                                        color: .tornyBlue
                                                    )

                                                    Divider()
                                                }

                                                // Performance stats
                                                if dashboardViewModel.stats.overallAccuracy > 0 {
                                                    DashboardActivityRow(
                                                        icon: "chart.line.uptrend.xyaxis",
                                                        title: "Overall Performance",
                                                        subtitle: String(format: "%.1f%% accuracy over %d sessions", dashboardViewModel.stats.overallAccuracy, dashboardViewModel.stats.totalSessions),
                                                        color: .tornyGreen
                                                    )

                                                    Divider()
                                                }

                                                // Club info or weekly activity
                                                if dashboardViewModel.stats.thisWeekSessions > 0 {
                                                    DashboardActivityRow(
                                                        icon: "calendar",
                                                        title: "This Week",
                                                        subtitle: "\(dashboardViewModel.stats.thisWeekSessions) training sessions completed",
                                                        color: .tornyPurple
                                                    )
                                                } else if let club = apiService.currentUser?.club {
                                                    DashboardActivityRow(
                                                        icon: "person.2.fill",
                                                        title: "Joined Club",
                                                        subtitle: club,
                                                        color: .tornyPurple
                                                    )
                                                } else {
                                                    DashboardActivityRow(
                                                        icon: "info.circle",
                                                        title: "Getting Started",
                                                        subtitle: "Start your first training session to see activity",
                                                        color: .tornyTextSecondary
                                                    )
                                                }
                                            }
                                        }
                                    }
                                }

                                Spacer(minLength: 100)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
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
        }
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 0) {
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
            .background(Color.white)
            .edgesIgnoringSafeArea(.bottom)
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
                // Refresh dashboard data when returning from training
                Task {
                    await dashboardViewModel.loadDashboard()
                }
            }
        }
        .sheet(isPresented: $showingHistory) {
            SessionHistoryView()
        }
        .sheet(isPresented: $showingAnalytics) {
            AnalyticsView()
        }
        .sheet(isPresented: $showingProfileSetup) {
            ProfileSetupViewContent(isPresented: $showingProfileSetup, showDoneButton: true)
        }
        .sheet(isPresented: $showAIInsights) {
            AIInsightsView()
        }
        .onAppear {
            Task {
                await dashboardViewModel.loadDashboard()
            }
        }
    }

    // MARK: - Helper Functions

    private func recentSessionSubtitle(session: TrainingSession) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        let timeAgo = formatter.localizedString(for: session.sessionDate, relativeTo: Date())

        if let accuracy = session.overallAccuracy {
            return String(format: "%.1f%% accuracy • %@", accuracy, timeAgo)
        } else if let totalShots = session.totalShots {
            return "\(totalShots) shots • \(timeAgo)"
        } else {
            return "Completed \(timeAgo)"
        }
    }
}

// MARK: - Invite Button Style
struct InviteButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
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
            VStack(spacing: 16) {
                // Icon with gradient circle background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                }

                VStack(spacing: 6) {
                    Text(title)
                        .font(TornyFonts.body)
                        .fontWeight(.bold)
                        .foregroundColor(.tornyTextPrimary)

                    Text(subtitle)
                        .font(TornyFonts.caption)
                        .foregroundColor(.tornyTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: color.opacity(0.15), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.2), color.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
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
