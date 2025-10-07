import SwiftUI

struct LaunchScreen: View {
    @State private var isAnimating = false
    @State private var opacity = 0.0

    var body: some View {
        ZStack {
            // Blue gradient background with clouds
            TornyGradients.skyGradient
                .ignoresSafeArea()

            // Animated clouds
            TornyCloudView()

            VStack(spacing: 40) {
                Spacer()

                // Main logo section
                Image("torny_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .opacity(opacity)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                    .animation(
                        Animation.easeIn(duration: 1.5).delay(0.5),
                        value: opacity
                    )

                Spacer()

                // Version at bottom
                Text("Version 1.0")
                    .font(TornyFonts.caption)
                    .foregroundColor(.black)
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

            // Simple centered logo
            Image("torny_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
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