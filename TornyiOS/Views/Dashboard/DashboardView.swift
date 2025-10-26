import SwiftUI
import Foundation

struct DashboardView: View {
    @ObservedObject private var apiService = APIService.shared
    @State private var showSidebar = false
    @State private var selectedView: DashboardNavigationType? = nil
    @State private var showAIInsights = false

    var body: some View {
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

                                Text("Ready to practice like a pro?")
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 40)
                            .padding(.horizontal, 20)

                            // Shot Performance Section
                            ShotPerformanceSection()

                            // Quick actions
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {

                                // Start Training
                                DashboardCard(
                                    icon: "target",
                                    title: "Start Training",
                                    subtitle: "Begin a new session",
                                    color: .tornyBlue
                                ) {
                                    // Navigate to training
                                }

                                // View Analytics
                                DashboardCard(
                                    icon: "chart.bar.fill",
                                    title: "Analytics",
                                    subtitle: "Track your progress",
                                    color: .tornyGreen
                                ) {
                                    // Navigate to analytics
                                }

                                // Session History
                                DashboardCard(
                                    icon: "clock.fill",
                                    title: "History",
                                    subtitle: "Past sessions",
                                    color: .tornyPurple
                                ) {
                                    // Navigate to history
                                }

                                // Profile Settings
                                DashboardCard(
                                    icon: "person.crop.circle.fill",
                                    title: "Profile",
                                    subtitle: "Manage settings",
                                    color: .orange
                                ) {
                                    // Navigate to profile
                                }
                            }
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

                            // Torny AI Feature Button
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

                                        Image(systemName: "brain.head.profile")
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

                                        Text("Get personalised insights & recommendations")
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

                            // Share App (moved below AI button)
                            LazyVGrid(columns: [
                                GridItem(.flexible())
                            ], spacing: 16) {
                                DashboardCard(
                                    icon: "square.and.arrow.up.fill",
                                    title: "Share Torny",
                                    subtitle: "Invite friends",
                                    color: .tornyBlue.opacity(0.8)
                                ) {
                                    // Share app via Messages
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = windowScene.windows.first,
                                       let rootViewController = window.rootViewController {
                                        ShareService.shared.shareViaMessages(from: rootViewController)
                                    }
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
                                        ActivityRow(
                                            icon: "target",
                                            title: "Training Session",
                                            subtitle: "Completed 45 minutes ago",
                                            color: .tornyBlue
                                        )
                                        
                                        Divider()
                                        
                                        ActivityRow(
                                            icon: "chart.line.uptrend.xyaxis",
                                            title: "Personal Best",
                                            subtitle: "New accuracy record: 85%",
                                            color: .tornyGreen
                                        )
                                        
                                        Divider()
                                        
                                        ActivityRow(
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
            }

            // Sidebar overlay
            if showSidebar {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { showSidebar = false }

                HStack {
                    TornySidebar(isPresented: $showSidebar, onNavigate: { navType in
                        selectedView = navType
                        showSidebar = false
                    })
                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            TornyBottomNavigation(
                onHomeTap: { selectedView = nil },
                onTrainingTap: { /* Navigate to training */ },
                onAnalyticsTap: { selectedView = .analytics },
                onProfileTap: { selectedView = .profile }
            )
        }
        .animation(.easeInOut(duration: 0.3), value: showSidebar)
        .sheet(isPresented: $showAIInsights) {
            AIInsightsView()
        }
    }
}

// MARK: - Dashboard Card Component
struct DashboardCard: View {
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

// MARK: - Activity Row Component
struct ActivityRow: View {
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

// MARK: - Shot Performance Section
struct ShotPerformanceSection: View {
    @State private var shotTypeData: ShotTypeSummaryData?
    @State private var isLoading = false
    @State private var selectedPeriod: String = "all"
    private let apiService = APIService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with dropdown
            HStack {
                Text("Shot Performance")
                    .font(TornyFonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.tornyTextPrimary)

                Spacer()

                // Period dropdown
                Menu {
                    Button("7 Days") {
                        selectedPeriod = "7days"
                    }
                    Button("30 Days") {
                        selectedPeriod = "30days"
                    }
                    Button("90 Days") {
                        selectedPeriod = "90days"
                    }
                    Button("All Time") {
                        selectedPeriod = "all"
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(periodDisplayName)
                            .font(TornyFonts.bodySecondary)
                            .foregroundColor(.tornyTextSecondary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.tornyTextSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
            .padding(.horizontal, 20)

            Group {
                if isLoading {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<4) { _ in
                                ShotTypeCardSkeleton()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                } else if let data = shotTypeData {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                        ShotPerformanceCard(
                            type: "Draw",
                            stats: data.draw,
                            color: Color.tornyGreen
                        )

                        ShotPerformanceCard(
                            type: "Yard On",
                            stats: data.yardOn,
                            color: Color.tornyBlue
                        )

                        ShotPerformanceCard(
                            type: "D-Weight",
                            stats: data.ditchWeight,
                            color: Color.orange
                        )

                        ShotPerformanceCard(
                            type: "Drive",
                            stats: data.drive,
                            color: Color.tornyPurple
                        )
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                // Empty state - no data yet
                Text("No training data available")
                    .font(TornyFonts.body)
                    .foregroundColor(.tornyTextSecondary)
                    .padding(.horizontal, 20)
            }
            }
        }
        .onAppear {
            // Only fetch if we don't already have data and we're not currently loading
            if shotTypeData == nil && !isLoading {
                Task {
                    await fetchShotTypeData()
                }
            }
        }
        .onChange(of: selectedPeriod) { _ in
            Task {
                await fetchShotTypeData()
            }
        }
    }

    private var periodDisplayName: String {
        switch selectedPeriod {
        case "7days": return "7 Days"
        case "30days": return "30 Days"
        case "90days": return "90 Days"
        case "all": return "All Time"
        default: return "All Time"
        }
    }

    private func fetchShotTypeData() async {
        guard !isLoading else { return }
        isLoading = true
        do {
            let response = try await apiService.getShotTypeSummary(period: selectedPeriod)
            await MainActor.run {
                shotTypeData = response.data
                isLoading = false
            }
        } catch {
            print("Error fetching shot type summary: \(error)")
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

// MARK: - Shot Performance Card
struct ShotPerformanceCard: View {
    let type: String
    let stats: ShotTypeSummaryStats
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(type)
                .font(TornyFonts.bodySecondary)
                .fontWeight(.semibold)
                .foregroundColor(.tornyTextSecondary)

            Text("\(stats.accuracyPercentage, specifier: "%.1f")%")
                .font(TornyFonts.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            // Bar chart
            ZStack(alignment: .bottom) {
                // Background bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 40, height: 100)

                // Filled bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 40, height: CGFloat(stats.accuracyPercentage))
            }

            Text("\(stats.totalShots)")
                .font(TornyFonts.bodySecondary)
                .foregroundColor(.tornyTextSecondary)

            Text("shots")
                .font(TornyFonts.caption)
                .foregroundColor(.tornyTextSecondary)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Shot Type Card Skeleton
struct ShotTypeCardSkeleton: View {
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 12)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 20)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 40, height: 100)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 30, height: 12)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}