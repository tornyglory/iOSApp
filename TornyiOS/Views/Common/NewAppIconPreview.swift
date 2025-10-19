import SwiftUI

struct NewAppIconPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("New App Icon Design")
                .font(.title)
                .fontWeight(.bold)

            // App icon preview
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.0, green: 1.0, blue: 1.0), // Aqua
                        Color(red: 0.0, green: 0.8, blue: 0.4)  // Green
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Trophy emoji
                Text("🏆")
                    .font(.system(size: 80))
            }
            .frame(width: 120, height: 120)
            .cornerRadius(24) // iOS app icon corner radius
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

            Text("Trophy icon with aqua-green gradient")
                .font(.caption)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("To implement this icon:")
                    .font(.headline)

                Text("1. Create icon images at required sizes:")
                Text("   • 1024x1024 (App Store)")
                Text("   • 180x180 (iPhone @3x)")
                Text("   • 120x120 (iPhone @2x)")
                Text("   • 87x87 (Settings @3x)")
                Text("   • 58x58 (Settings @2x)")
                Text("   • And other required sizes...")

                Text("2. Replace files in AppIcon.appiconset")
                Text("3. Use design tools like Figma, Sketch, or Canva")
            }
            .font(.caption)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
    }
}

struct NewAppIconPreview_Previews: PreviewProvider {
    static var previews: some View {
        NewAppIconPreview()
    }
}