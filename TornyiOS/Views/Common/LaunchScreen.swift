import SwiftUI

struct LaunchScreen: View {
    @State private var isAnimating = false
    @State private var opacity = 0.0

    var body: some View {
        ZStack {
            // Clean white background
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Main logo section - trophy and text inline
                HStack(spacing: 6) {
                    // Trophy emoji on the left - smaller
                    Text("🏆")
                        .font(.system(size: 40))
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )

                    // Torny brand text on the right - custom font with extra space
                    Text("TORNY ")
                        .font(TornyFonts.brandTitle)
                        .foregroundColor(.tornyTextPrimary)
                        .background(
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 180, height: 50)
                        )
                        .clipped()
                }
                .frame(maxWidth: .infinity)
                .opacity(opacity)
                .animation(
                    Animation.easeIn(duration: 1.5).delay(0.5),
                    value: opacity
                )

                Spacer()

                // Version at bottom
                Text("Version 1.0")
                    .font(TornyFonts.caption)
                    .foregroundColor(.tornyTextSecondary)
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
            // Clean white background
            Color.white
                .ignoresSafeArea()

            // Simple centered logo - inline
            HStack(spacing: 6) {
                Text("🏆")
                    .font(.system(size: 35))

                Text("TORNY ")
                    .font(TornyFonts.brandMedium)
                    .foregroundColor(.tornyTextPrimary)
                    .background(
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 150, height: 40)
                    )
                    .clipped()
            }
            .frame(maxWidth: .infinity)
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