import SwiftUI

struct HistoryView: View {
    let trips: [SampleTrip]

    var body: some View {
        List(trips) { trip in
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(trip.title)
                    .font(.headline)
                HStack(spacing: DesignSystem.Spacing.md) {
                    Label(trip.distance, systemImage: DesignSystem.Icons.trail)
                    Label(trip.duration, systemImage: DesignSystem.Icons.history)
                    Label(trip.difficulty, systemImage: DesignSystem.Icons.difficulty)
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                Text(trip.summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Trip History")
    }
}
