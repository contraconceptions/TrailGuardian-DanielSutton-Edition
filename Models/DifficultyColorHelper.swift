import SwiftUI

/// Helper for difficulty score color coding
enum DifficultyColorHelper {
    /// Get color for Sutton Score (0-100)
    static func colorForScore(_ score: Int) -> Color {
        switch score {
        case 0...30:
            return .green
        case 31...50:
            return .yellow
        case 51...70:
            return .orange
        case 71...100:
            return .red
        default:
            return .gray
        }
    }

    /// Get background color for Sutton Score (lighter shade)
    static func backgroundColorForScore(_ score: Int) -> Color {
        colorForScore(score).opacity(0.2)
    }

    /// Get text description for score range
    static func descriptionForScore(_ score: Int) -> String {
        switch score {
        case 0...30:
            return "Easy"
        case 31...50:
            return "Moderate"
        case 51...70:
            return "Difficult"
        case 71...100:
            return "Extreme"
        default:
            return "Unknown"
        }
    }
}
