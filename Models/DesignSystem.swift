import SwiftUI

/// Design system following Apple Human Interface Guidelines
/// Provides consistent spacing, typography, colors, and layout constants
enum DesignSystem {

    // MARK: - Spacing (8pt grid system)
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }

    // MARK: - Layout
    enum Layout {
        static let minTouchTarget: CGFloat = 44  // Apple HIG minimum
        static let cardPadding: CGFloat = Spacing.md
        static let sectionSpacing: CGFloat = Spacing.lg
    }

    // MARK: - Semantic Colors
    enum Colors {
        // Primary actions
        static let startTrail = Color.green
        static let startCamping = Color.orange
        static let danger = Color.red

        // Semantic backgrounds
        static let cardBackground = Color(.systemGray6)
        static let overlayBackground = Color.black.opacity(0.3)

        // Status colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue

        // Feature colors
        static let campSite = Color.purple
        static let bronco = Color.blue
        static let suttonScore = Color.orange
    }

    // MARK: - Shadow
    enum Shadow {
        static let sm = (radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
        static let md = (radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let lg = (radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
    }

    // MARK: - Icons
    enum Icons {
        static let trail = "figure.hiking"
        static let camp = "tent.fill"
        static let history = "clock.arrow.circlepath"
        static let map = "map.fill"
        static let location = "location.fill"
        static let weather = "cloud.sun.fill"
        static let temperature = "thermometer.medium"
        static let vehicle = "car.fill"
        static let elevation = "mountain.2.fill"
        static let speed = "speedometer"
        static let difficulty = "gauge.with.needle.fill"
        static let delete = "trash.fill"
        static let save = "checkmark.circle.fill"
        static let photo = "photo.on.rectangle.angled"
        static let warning = "exclamationmark.triangle.fill"
        static let success = "checkmark.circle.fill"
        static let lock = "lock.fill"
        static let settings = "gearshape.fill"
    }

    // MARK: - Animation
    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
    }
}

// MARK: - View Modifiers

/// Card-style container with HIG-compliant styling
struct CardModifier: ViewModifier {
    var backgroundColor: Color = DesignSystem.Colors.cardBackground
    var cornerRadius: CGFloat = DesignSystem.CornerRadius.md

    func body(content: Content) -> some View {
        content
            .padding(DesignSystem.Layout.cardPadding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(
                radius: DesignSystem.Shadow.sm.radius,
                x: DesignSystem.Shadow.sm.x,
                y: DesignSystem.Shadow.sm.y
            )
    }
}

/// Primary button style following HIG
struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = .accentColor
    var isDestructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: DesignSystem.Layout.minTouchTarget)
            .background(isDestructive ? DesignSystem.Colors.danger : color)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }
}

/// Secondary button style (outlined)
struct SecondaryButtonStyle: ButtonStyle {
    var color: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(minHeight: DesignSystem.Layout.minTouchTarget)
            .background(color.opacity(0.1))
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(color, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }
}

/// Tertiary button style (minimal)
struct TertiaryButtonStyle: ButtonStyle {
    var color: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .foregroundColor(color)
            .frame(minHeight: DesignSystem.Layout.minTouchTarget)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply card styling
    func card(backgroundColor: Color = DesignSystem.Colors.cardBackground, cornerRadius: CGFloat = DesignSystem.CornerRadius.md) -> some View {
        modifier(CardModifier(backgroundColor: backgroundColor, cornerRadius: cornerRadius))
    }

    /// Apply section spacing
    func sectionSpacing() -> some View {
        padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Reusable Components

/// Loading indicator with text
struct LoadingIndicator: View {
    let text: String
    let size: CGFloat

    init(_ text: String, size: CGFloat = 1.0) {
        self.text = text
        self.size = size
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ProgressView()
                .scaleEffect(size)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading \(text)")
    }
}

/// Empty state view
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(.title2.bold())

                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }
        }
        .padding(DesignSystem.Spacing.xl)
    }
}

/// Status badge
struct StatusBadge: View {
    let text: String
    let color: Color
    let icon: String?

    init(_ text: String, color: Color, icon: String? = nil) {
        self.text = text
        self.color = color
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
            }
            Text(text)
                .font(.caption.bold())
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .cornerRadius(DesignSystem.CornerRadius.sm)
    }
}

/// Metric display card
struct MetricCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3.bold())

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}
