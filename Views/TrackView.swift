import SwiftUI

struct TrackView: View {
    let sampleTrip: SampleTrip

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                hero
                stats
                checkpoints
            }
            .padding(DesignSystem.Spacing.md)
        }
        .navigationTitle(sampleTrip.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Demo Trail")
                .font(.headline)
                .foregroundColor(.secondary)
            Text(sampleTrip.summary)
                .font(.body)
            HStack(spacing: DesignSystem.Spacing.md) {
                Label(sampleTrip.distance, systemImage: DesignSystem.Icons.trail)
                Label(sampleTrip.duration, systemImage: DesignSystem.Icons.history)
                Label(sampleTrip.difficulty, systemImage: DesignSystem.Icons.difficulty)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .card()
    }

    private var stats: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Lightweight metrics")
                .font(.headline)
            Text("This build uses static demo data so you can open and run the project without enabling location, motion, or WeatherKit capabilities. Swap in the full managers later once Xcode is happy with signing and entitlements.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .card()
    }

    private var checkpoints: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Trail notes")
                .font(.headline)
            ForEach(samplePoints, id: \.self) { point in
                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.accentColor)
                    Text(point)
                        .font(.body)
                }
            }
        }
        .card()
    }

    private var samplePoints: [String] {
        [
            "Scenic overlook at mile 3.2 — great spot for photos.",
            "Shaded canyon section begins around mile 6.",
            "Rock garden bypass available near mile 8.",
            "Plenty of space to air down and stage at the trailhead."
        ]
    }
}
