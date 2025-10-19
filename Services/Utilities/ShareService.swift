import SwiftUI
import MessageUI
import UIKit

/// Service for sharing the Torny app via Messages, social media, and other channels
class ShareService: NSObject, ObservableObject {

    static let shared = ShareService()

    // MARK: - App Store Information
    private let appStoreURL = "https://apps.apple.com/app/torny/YOUR_APP_ID" // Update when app is live
    private let testFlightURL = "https://testflight.apple.com/join/YOUR_BETA_CODE" // Update with actual TestFlight link

    // MARK: - Share Messages

    var shareMessage: String {
        """
        I've been using Torny to improve my lawn bowls game!

        ✅ Track every shot with accuracy analysis
        ✅ See progress with detailed charts
        ✅ Compare sessions to find patterns
        ✅ Works offline at any bowling green

        Perfect for bowlers of all skill levels! Give it a try:
        \(appStoreURL)
        """
    }

    var inviteMessage: String {
        """
        Hey! 🎳

        I built a lawn bowls training app called Torny that's been amazing for tracking my progress.

        Want to check it out?
        \(appStoreURL)

        Would love to hear what you think! 🏆
        """
    }

    // MARK: - Share Methods

    /// Share via iOS Messages app with pre-populated text
    /// - Parameter presentingViewController: The view controller to present from
    func shareViaMessages(from presentingViewController: UIViewController) {
        guard MFMessageComposeViewController.canSendText() else {
            print("❌ Device cannot send text messages")
            showErrorAlert(from: presentingViewController, message: "Your device cannot send text messages.")
            return
        }

        let messageComposer = MFMessageComposeViewController()
        messageComposer.messageComposeDelegate = self
        messageComposer.body = shareMessage

        // Optional: Pre-populate with specific recipients
        // messageComposer.recipients = ["contact@example.com"]

        presentingViewController.present(messageComposer, animated: true)
    }

    /// Share via native iOS share sheet (supports Messages, Mail, Social Media, etc.)
    /// - Parameter presentingViewController: The view controller to present from
    func shareViaShareSheet(from presentingViewController: UIViewController) {
        let activityViewController = UIActivityViewController(
            activityItems: [shareMessage],
            applicationActivities: nil
        )

        // Exclude certain activity types if desired
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .saveToCameraRoll
        ]

        // For iPad compatibility
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = presentingViewController.view
            popoverController.sourceRect = CGRect(
                x: presentingViewController.view.bounds.midX,
                y: presentingViewController.view.bounds.midY,
                width: 0,
                height: 0
            )
        }

        presentingViewController.present(activityViewController, animated: true)
    }

    /// Share with custom message for personal invites
    /// - Parameters:
    ///   - presentingViewController: The view controller to present from
    ///   - isPersonalInvite: Whether this is a personal invite (uses friendlier message)
    func shareApp(from presentingViewController: UIViewController, isPersonalInvite: Bool = false) {
        let message = isPersonalInvite ? inviteMessage : shareMessage

        let activityViewController = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )

        // For iPad compatibility
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = presentingViewController.view
            popoverController.sourceRect = CGRect(
                x: presentingViewController.view.bounds.midX,
                y: presentingViewController.view.bounds.midY,
                width: 0,
                height: 0
            )
        }

        presentingViewController.present(activityViewController, animated: true)
    }

    /// Generate dynamic share message with user's stats
    /// - Parameter userStats: Optional user statistics to include
    /// - Returns: Personalized share message
    func generatePersonalizedShareMessage(userStats: UserStats? = nil) -> String {
        var message = "I've been using Torny to improve my lawn bowls game!\n\n"

        if let stats = userStats {
            message += "My progress so far:\n"
            if stats.totalSessions > 0 {
                message += "📊 \(stats.totalSessions) training sessions completed\n"
            }
            if stats.averageAccuracy > 0 {
                message += "🎯 \(String(format: "%.1f", stats.averageAccuracy))% average accuracy\n"
            }
            if stats.bestSession > 0 {
                message += "🏆 Best session: \(String(format: "%.1f", stats.bestSession))% accuracy\n"
            }
            message += "\n"
        }

        message += """
        Perfect for bowlers wanting to:
        ✅ Track shot accuracy & performance
        ✅ Analyze progress with detailed charts
        ✅ Compare sessions to identify patterns
        ✅ Train offline at any bowling green

        Download Torny: \(appStoreURL)
        """

        return message
    }

    // MARK: - Helper Methods

    private func showErrorAlert(from viewController: UIViewController, message: String) {
        let alert = UIAlertController(
            title: "Unable to Share",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
}

// MARK: - MFMessageComposeViewControllerDelegate

extension ShareService: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) {
            switch result {
            case .cancelled:
                print("📱 Message sharing cancelled")
            case .sent:
                print("📱 Message sent successfully")
            case .failed:
                print("❌ Message sending failed")
            @unknown default:
                print("📱 Unknown message result")
            }
        }
    }
}

// MARK: - Supporting Data Models

struct UserStats {
    let totalSessions: Int
    let averageAccuracy: Double
    let bestSession: Double
    let totalShots: Int

    init(totalSessions: Int = 0, averageAccuracy: Double = 0, bestSession: Double = 0, totalShots: Int = 0) {
        self.totalSessions = totalSessions
        self.averageAccuracy = averageAccuracy
        self.bestSession = bestSession
        self.totalShots = totalShots
    }
}

// MARK: - SwiftUI Integration Helper

struct ShareButton: View {
    let style: ShareButtonStyle
    let isPersonalInvite: Bool
    let userStats: UserStats?

    @State private var showingShareSheet = false

    init(style: ShareButtonStyle = .standard, isPersonalInvite: Bool = false, userStats: UserStats? = nil) {
        self.style = style
        self.isPersonalInvite = isPersonalInvite
        self.userStats = userStats
    }

    var body: some View {
        Button(action: {
            showingShareSheet = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: style.iconSize))

                if style != .iconOnly {
                    Text(style.title)
                        .font(.system(size: style.fontSize, weight: .medium))
                }
            }
            .foregroundColor(style.foregroundColor)
            .padding(style.padding)
            .background(style.backgroundColor)
            .cornerRadius(style.cornerRadius)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheetView(
                message: userStats != nil
                    ? ShareService.shared.generatePersonalizedShareMessage(userStats: userStats)
                    : (isPersonalInvite ? ShareService.shared.inviteMessage : ShareService.shared.shareMessage)
            )
        }
    }
}

enum ShareButtonStyle {
    case standard
    case compact
    case iconOnly
    case prominent

    var title: String {
        switch self {
        case .standard, .compact: return "Share App"
        case .prominent: return "Invite Friends"
        case .iconOnly: return ""
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .standard: return 16
        case .compact, .iconOnly: return 14
        case .prominent: return 18
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .standard: return 16
        case .compact: return 14
        case .prominent: return 18
        case .iconOnly: return 0
        }
    }

    var padding: EdgeInsets {
        switch self {
        case .standard: return EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        case .compact: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        case .iconOnly: return EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        case .prominent: return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .standard, .compact: return Color.tornyBlue
        case .iconOnly: return Color.gray.opacity(0.2)
        case .prominent: return Color.tornyPurple
        }
    }

    var foregroundColor: Color {
        switch self {
        case .standard, .compact, .prominent: return .white
        case .iconOnly: return .primary
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .standard, .compact, .prominent: return 8
        case .iconOnly: return 6
        }
    }
}

// MARK: - UIKit ShareSheet Wrapper for SwiftUI

struct ShareSheetView: UIViewControllerRepresentable {
    let message: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )

        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .saveToCameraRoll
        ]

        return activityViewController
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}