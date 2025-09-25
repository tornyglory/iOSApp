import SwiftUI

struct LaunchScreen: View {
    @State private var isAnimating = false
    @State private var opacity = 0.0

    var body: some View {
        ZStack {
            // Background gradient matching app theme
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.8, blue: 0.8),  // Aqua
                    Color(red: 0.5, green: 0.0, blue: 0.8)   // Purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Main logo section
                VStack(spacing: 20) {
                    // Large "T" logo with subtle animation
                    ZStack {
                        // Shadow circle
                        Circle()
                            .fill(Color.black.opacity(0.1))
                            .frame(width: 130, height: 130)
                            .offset(x: 3, y: 3)

                        // Main logo circle
                        Circle()
                            .fill(Color.white)
                            .frame(width: 120, height: 120)
                            .overlay(
                                Text("T")
                                    .font(.system(size: 60, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0.3, green: 0.0, blue: 0.6))
                            )
                    }
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                    // App name with custom font styling
                    VStack(spacing: 8) {
                        Text("TORNY")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(2)

                        Text("Lawn Bowls Training")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(1)
                    }
                    .opacity(opacity)
                    .animation(
                        Animation.easeIn(duration: 1.5).delay(0.5),
                        value: opacity
                    )
                }

                Spacer()
                Spacer()

                // Bottom section with version and branding
                VStack(spacing: 12) {
                    // Subtle loading indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 8, height: 8)
                                .scaleEffect(isAnimating ? 1.0 : 0.5)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    .padding(.bottom, 20)

                    // Version and branding
                    VStack(spacing: 4) {
                        Text("Version 1.0")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))

                        Text("© 2024 Torny Sports")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .opacity(opacity)
                .animation(
                    Animation.easeIn(duration: 1.0).delay(1.0),
                    value: opacity
                )
            }
            .padding(.vertical, 50)
        }
        .onAppear {
            isAnimating = true
            opacity = 1.0
        }
    }
}

// MARK: - Alternative Minimal Launch Screen
struct MinimalLaunchScreen: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.8, blue: 0.8),  // Aqua
                    Color(red: 0.5, green: 0.0, blue: 0.8)   // Purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Simple centered logo
            VStack(spacing: 16) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text("T")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.0, blue: 0.6))
                    )

                Text("TORNY")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(2)
            }
        }
    }
}

// MARK: - Preview
struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LaunchScreen()
                .previewDisplayName("Animated Launch Screen")

            MinimalLaunchScreen()
                .previewDisplayName("Minimal Launch Screen")
        }
    }
}