import SwiftUI

struct DashboardView: View {
    @ObservedObject private var apiService = APIService.shared
    @State private var showSidebar = false
    @State private var selectedView: TornyComponents.DashboardView? = nil
    
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
                
                // Bottom navigation
                TornyBottomNavigation(
                    onHomeTap: { selectedView = nil },
                    onTrainingTap: { /* Navigate to training */ },
                    onAnalyticsTap: { selectedView = .analytics },
                    onProfileTap: { selectedView = .profile }
                )
            }
            
            // Sidebar overlay
            if showSidebar {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { showSidebar = false }
                
                HStack {
                    TornySidebar(isPresented: $showSidebar)
                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSidebar)
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

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}