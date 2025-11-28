import SwiftUI

struct EndSummaryView: View {
    let trip: SampleTrip

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Trip Summary")
                .font(.largeTitle.bold())
            Text(trip.summary)
                .font(.body)
            Text("Distance: \(trip.distance)")
            Text("Duration: \(trip.duration)")
            Text("Difficulty: \(trip.difficulty)")
            Spacer()
        }
        .padding(DesignSystem.Spacing.md)
    }
}
