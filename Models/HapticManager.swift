import UIKit

/// Centralized haptic feedback manager for consistent tactile responses
class HapticManager {
    static let shared = HapticManager()

    private init() {}

    /// Light impact (for minor interactions like button taps)
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact (for significant actions like saving)
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact (for major events like completing a trail)
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Success notification (for successful saves, completions)
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning notification (for validation errors, warnings)
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error notification (for failures, critical errors)
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    /// Selection changed (for picker/segment changes)
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Prepared Generators (for reduced latency)

    /// Prepare a generator before expected use (reduces latency)
    /// Call this when you know a haptic event is imminent
    func prepare(for style: FeedbackStyle) {
        switch style {
        case .impact(let impactStyle):
            let generator = UIImpactFeedbackGenerator(style: impactStyle)
            generator.prepare()
        case .notification:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
        }
    }

    enum FeedbackStyle {
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        case notification
        case selection
    }
}

// MARK: - SwiftUI View Extension

import SwiftUI

extension View {
    /// Add haptic feedback to any view
    func hapticFeedback(_ feedback: HapticManager.FeedbackStyle, trigger: some Equatable) -> some View {
        self.onChange(of: trigger) { _ in
            HapticManager.shared.prepare(for: feedback)
        }
    }
}
