import SwiftUI
import Foundation

// MARK: - Dashboard Navigation Type
enum DashboardNavigationType {
    case analytics
    case profile
    case history
    case settings
    case trainingPrograms
}

// MARK: - Torny Background View
struct TornyBackgroundView: View {
    var body: some View {
        ZStack {
            TornyGradients.skyGradient
                .ignoresSafeArea()
            
            TornyCloudView()
        }
    }
}

// MARK: - Animated Cloud View
struct TornyCloudView: View {
    @State private var cloudOffset1: CGFloat = -200
    @State private var cloudOffset2: CGFloat = -300
    @State private var cloudOffset3: CGFloat = -250
    
    var body: some View {
        ZStack {
            CloudShape()
                .fill(Color.white.opacity(0.7))
                .frame(width: 120, height: 60)
                .offset(x: cloudOffset1, y: -200)
                .onAppear {
                    animateCloud(offset: $cloudOffset1, duration: 35)
                }
            
            CloudShape()
                .fill(Color.white.opacity(0.6))
                .frame(width: 80, height: 40)
                .offset(x: cloudOffset2, y: -150)
                .onAppear {
                    animateCloud(offset: $cloudOffset2, duration: 40)
                }
            
            CloudShape()
                .fill(Color.white.opacity(0.8))
                .frame(width: 100, height: 50)
                .offset(x: cloudOffset3, y: -250)
                .onAppear {
                    animateCloud(offset: $cloudOffset3, duration: 30)
                }
        }
    }
    
    private func animateCloud(offset: Binding<CGFloat>, duration: Double) {
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            offset.wrappedValue = UIScreen.main.bounds.width + 200
        }
    }
}

// MARK: - Cloud Shape
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Create a cloud-like shape using curves
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.6))
        path.addCurve(to: CGPoint(x: width * 0.1, y: height * 0.4),
                      control1: CGPoint(x: width * 0.05, y: height * 0.6),
                      control2: CGPoint(x: width * 0.05, y: height * 0.4))
        path.addCurve(to: CGPoint(x: width * 0.25, y: height * 0.1),
                      control1: CGPoint(x: width * 0.1, y: height * 0.2),
                      control2: CGPoint(x: width * 0.15, y: height * 0.1))
        path.addCurve(to: CGPoint(x: width * 0.5, y: height * 0.05),
                      control1: CGPoint(x: width * 0.3, y: height * 0.05),
                      control2: CGPoint(x: width * 0.4, y: height * 0.02))
        path.addCurve(to: CGPoint(x: width * 0.75, y: height * 0.1),
                      control1: CGPoint(x: width * 0.6, y: height * 0.02),
                      control2: CGPoint(x: width * 0.7, y: height * 0.05))
        path.addCurve(to: CGPoint(x: width * 0.9, y: height * 0.4),
                      control1: CGPoint(x: width * 0.85, y: height * 0.1),
                      control2: CGPoint(x: width * 0.95, y: height * 0.2))
        path.addCurve(to: CGPoint(x: width * 0.8, y: height * 0.6),
                      control1: CGPoint(x: width * 0.95, y: height * 0.4),
                      control2: CGPoint(x: width * 0.95, y: height * 0.6))
        path.addCurve(to: CGPoint(x: width * 0.2, y: height * 0.6),
                      control1: CGPoint(x: width * 0.6, y: height * 0.65),
                      control2: CGPoint(x: width * 0.4, y: height * 0.65))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Torny Button Styles
struct TornyPrimaryButton: ButtonStyle {
    let isLarge: Bool
    
    init(isLarge: Bool = false) {
        self.isLarge = isLarge
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(isLarge ? TornyFonts.buttonLarge : TornyFonts.button)
            .foregroundColor(.white)
            .padding(.horizontal, isLarge ? 28 : 24)
            .padding(.vertical, isLarge ? 14 : 12)
            .frame(maxWidth: .infinity)
            .frame(height: isLarge ? 50 : 44)
            .background(
                RoundedRectangle(cornerRadius: isLarge ? 25 : 22)
                    .fill(configuration.isPressed ? Color.tornyDarkBlue : Color.tornyBlue)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TornySecondaryButton: ButtonStyle {
    let isLarge: Bool
    
    init(isLarge: Bool = false) {
        self.isLarge = isLarge
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(isLarge ? TornyFonts.buttonLarge : TornyFonts.button)
            .foregroundColor(.tornyBlue)
            .padding(.horizontal, isLarge ? 28 : 24)
            .padding(.vertical, isLarge ? 14 : 12)
            .frame(maxWidth: .infinity)
            .frame(height: isLarge ? 50 : 44)
            .background(
                RoundedRectangle(cornerRadius: isLarge ? 25 : 22)
                    .fill(configuration.isPressed ? Color.tornyLightBlue : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: isLarge ? 25 : 22)
                            .stroke(Color.tornyBlue, lineWidth: 2)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Torny Card View
struct TornyCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Torny Text Field Style
struct TornyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.tornyLightBlue, lineWidth: 1)
                    )
            )
            .font(TornyFonts.body)
            .foregroundColor(.tornyTextPrimary)
    }
}

// MARK: - Torny Logo View
struct TornyLogoView: View {
    let size: CGSize

    init(size: CGSize = CGSize(width: 80, height: 80)) {
        self.size = size
    }

    var body: some View {
        Image("torny_logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size.width, height: size.height)
    }
    
    private func customFont(size: CGFloat) -> Font {
        // Try different font names that might work
        let fontNames = [
            "PermanentMarker-Regular",
            "Permanent Marker",
            "PermanentMarker",
            "Permanent Marker Regular"
        ]
        
        for fontName in fontNames {
            if UIFont(name: fontName, size: size) != nil {
                return .custom(fontName, size: size)
            }
        }
        
        // If custom font fails, use bold rounded as fallback
        return .system(size: size, weight: .black, design: .rounded)
    }
    
    private func loadCustomFont() {
        guard let fontPath = Bundle.main.path(forResource: "PermanentMarker-Regular", ofType: "ttf"),
              let fontData = NSData(contentsOfFile: fontPath),
              let dataProvider = CGDataProvider(data: fontData),
              let cgFont = CGFont(dataProvider) else {
            print("❌ Failed to load font from bundle")
            return
        }
        
        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(cgFont, &error) {
            print("✅ Font registered manually")
        } else {
            print("❌ Font registration failed: \(error?.takeUnretainedValue().localizedDescription ?? "Unknown error")")
        }
    }
}

// MARK: - Loading Indicator
struct TornyLoadingView: View {
    @State private var isPulsing = false
    @State private var shimmerOffset: CGFloat = -200
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            // Base logo with grey tint
            Image("torny_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .colorMultiply(Color.gray.opacity(0.3))

            // Shimmer overlay
            Image("torny_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.3),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: size * 2)
                    .offset(x: shimmerOffset)
                )
                .colorMultiply(Color.gray.opacity(0.6))
        }
        .opacity(isPulsing ? 0.6 : 1.0)
        .onAppear {
            // Pulsing animation
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isPulsing = true
            }

            // Shimmer animation
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmerOffset = size * 2
            }
        }
    }
}

// MARK: - Button Loading Spinner
struct TornyButtonSpinner: View {
    @State private var isAnimating = false
    var color: Color = .white

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(color, lineWidth: 2)
            .frame(width: 20, height: 20)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Facebook-Style Navigation Bar
struct TornyNavBar: View {
    @Binding var showSidebar: Bool

    var body: some View {
        HStack {
            Spacer()

            // Center - Torny logo
            Image("torny_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 35)

            Spacer()

            // Right side - Hamburger menu
            Button(action: {
                showSidebar.toggle()
            }) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.tornyTextPrimary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - Sidebar Component
struct TornySidebar: View {
    @ObservedObject private var apiService = APIService.shared
    @Binding var isPresented: Bool
    let onNavigate: ((DashboardNavigationType) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with user info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // User avatar
                    if let avatarUrlString = apiService.userAvatarUrl,
                       let avatarUrl = URL(string: avatarUrlString) {
                        AsyncImage(url: avatarUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure(_):
                            Circle()
                                .fill(Color.tornyBlue.opacity(0.2))
                                .overlay(
                                    Text(String(apiService.userFirstName.prefix(1)))
                                        .font(TornyFonts.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.tornyBlue)
                                )
                        case .empty:
                            Circle()
                                .fill(Color.tornyBlue.opacity(0.2))
                                .overlay(
                                    Text(String(apiService.userFirstName.prefix(1)))
                                        .font(TornyFonts.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.tornyBlue)
                                )
                        @unknown default:
                            Circle()
                                .fill(Color.tornyBlue.opacity(0.2))
                                .overlay(
                                    Text(String(apiService.userFirstName.prefix(1)))
                                        .font(TornyFonts.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.tornyBlue)
                                )
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.tornyBlue, lineWidth: 3)
                    )
                    } else {
                        Circle()
                            .fill(Color.tornyBlue.opacity(0.2))
                            .overlay(
                                Text(String(apiService.userFirstName.prefix(1)))
                                    .font(TornyFonts.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.tornyBlue)
                            )
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle()
                                    .stroke(Color.tornyBlue, lineWidth: 3)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(apiService.userDisplayName)
                            .font(TornyFonts.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.tornyTextPrimary)
                        
                        Text("Player")
                            .font(TornyFonts.body)
                            .foregroundColor(.tornyTextSecondary)
                    }
                    
                    Spacer()
                }
                .padding()
                
                Divider()
            }
            
            // Navigation links
            ScrollView {
                VStack(spacing: 0) {
                    SidebarLink(icon: "house", title: "Home", notification: nil) {
                        // Home action
                        isPresented = false
                    }
                    
                    SidebarLink(icon: "target", title: "Training Sessions", notification: nil) {
                        // Training action
                        isPresented = false
                    }
                    
                    SidebarLink(icon: "chart.bar", title: "Analytics", notification: nil) {
                        onNavigate?(.analytics)
                        isPresented = false
                    }
                    
                    SidebarLink(icon: "clock", title: "Session History", notification: nil) {
                        onNavigate?(.history)
                        isPresented = false
                    }
                    
                    SidebarLink(icon: "person.crop.circle", title: "Profile Settings", notification: nil) {
                        onNavigate?(.settings)
                        isPresented = false
                    }
                    
                    Divider()
                        .padding(.vertical, 16)

                    SidebarLink(icon: "square.and.arrow.up", title: "Share Torny", notification: nil) {
                        // Share app action
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            ShareService.shared.shareApp(from: window.rootViewController!, isPersonalInvite: true)
                        }
                        isPresented = false
                    }

                    SidebarLink(icon: "arrow.right.square", title: "Logout", notification: nil) {
                        // Logout action
                        apiService.logout()
                        isPresented = false
                    }
                }
            }
            
            Spacer()
        }
        .frame(width: 280)
        .background(Color.white)
        .shadow(radius: 10)
    }
}

// MARK: - Sidebar Link Component
struct SidebarLink: View {
    let icon: String
    let title: String
    let notification: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.tornyBlue)
                    .frame(width: 24)
                
                Text(title)
                    .font(TornyFonts.body)
                    .foregroundColor(.tornyTextPrimary)
                
                Spacer()
                
                if let notification = notification {
                    Text(notification)
                        .font(TornyFonts.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Bottom Navigation Footer
struct TornyBottomNavigation: View {
    @Binding var selectedTab: Int
    @ObservedObject private var apiService = APIService.shared
    var onHomeTap: (() -> Void)? = nil
    var onTrainingTap: (() -> Void)? = nil
    var onAnalyticsTap: (() -> Void)? = nil
    var onProfileTap: (() -> Void)? = nil
    
    init(selectedTab: Binding<Int> = .constant(0), onHomeTap: (() -> Void)? = nil, onTrainingTap: (() -> Void)? = nil, onAnalyticsTap: (() -> Void)? = nil, onProfileTap: (() -> Void)? = nil) {
        self._selectedTab = selectedTab
        self.onHomeTap = onHomeTap
        self.onTrainingTap = onTrainingTap
        self.onAnalyticsTap = onAnalyticsTap
        self.onProfileTap = onProfileTap
    }
    
    var body: some View {
        HStack {
            // Home
            BottomNavItem(
                icon: selectedTab == 0 ? "house.fill" : "house",
                title: "Home",
                isSelected: selectedTab == 0,
                notification: nil
            ) {
                selectedTab = 0
                onHomeTap?()
            }
            
            // Training
            BottomNavItem(
                icon: selectedTab == 1 ? "target" : "target",
                title: "Training",
                isSelected: selectedTab == 1,
                notification: nil
            ) {
                selectedTab = 1
                onTrainingTap?()
            }
            
            // Analytics
            BottomNavItem(
                icon: selectedTab == 2 ? "chart.bar.fill" : "chart.bar",
                title: "Analytics",
                isSelected: selectedTab == 2,
                notification: nil
            ) {
                selectedTab = 2
                onAnalyticsTap?()
            }
            
            // Profile with Avatar
            BottomNavProfileItem(
                title: "Profile",
                isSelected: selectedTab == 3,
                notification: nil
            ) {
                selectedTab = 3
                onProfileTap?()
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -2)
        )
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 0.5),
            alignment: .top
        )
    }
}

// MARK: - Bottom Navigation Item
struct BottomNavItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let notification: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .tornyBlue : .tornyTextSecondary)
                    
                    // Notification badge
                    if let notification = notification {
                        Text(notification)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 12, y: -12)
                    }
                }
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .tornyBlue : .tornyTextSecondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Standard Back Button
/// A reusable back button component with consistent Torny styling
/// Usage:
/// - TornyBackButton { /* action */ } - Just back arrow
/// - TornyBackButton(title: "Back") { /* action */ } - Back arrow with title
struct TornyBackButton: View {
    let action: () -> Void
    let title: String?

    init(title: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.tornyBlue)

                if let title = title {
                    Text(title)
                        .font(TornyFonts.body)
                        .foregroundColor(.tornyBlue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Bottom Navigation Profile Item with Avatar
struct BottomNavProfileItem: View {
    @ObservedObject private var apiService = APIService.shared
    let title: String
    let isSelected: Bool
    let notification: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // User avatar or initials
                    if let currentUser = apiService.currentUser,
                       let avatarUrlString = currentUser.avatarUrl,
                       !avatarUrlString.isEmpty,
                       let avatarUrl = URL(string: avatarUrlString) {
                        AsyncImage(url: avatarUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure(_):
                            Circle()
                                .fill(Color.tornyBlue.opacity(0.2))
                                .overlay(
                                    Text(String(apiService.userFirstName.prefix(1)))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.tornyBlue)
                                )
                        case .empty:
                            Circle()
                                .fill(Color.tornyBlue.opacity(0.2))
                                .overlay(
                                    Text(String(apiService.userFirstName.prefix(1)))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.tornyBlue)
                                )
                        @unknown default:
                            Circle()
                                .fill(Color.tornyBlue.opacity(0.2))
                                .overlay(
                                    Text(String(apiService.userFirstName.prefix(1)))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.tornyBlue)
                                )
                        }
                    }
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.tornyBlue, lineWidth: 2)
                    )
                    .id(apiService.currentUser?.id ?? 0)
                    } else {
                        Circle()
                            .fill(Color.tornyBlue.opacity(0.2))
                            .overlay(
                                Text(String(apiService.userFirstName.prefix(1)))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.tornyBlue)
                            )
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color.tornyBlue, lineWidth: 2)
                            )
                    }
                    
                    // Notification badge
                    if let notification = notification {
                        Text(notification)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 12, y: -12)
                    }
                }
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .tornyBlue : .tornyTextSecondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }
}