import SwiftUI

struct RouteMapView: View {
    let trip: SampleTrip

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: DesignSystem.Icons.map)
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            Text("Map preview not included in the lightweight demo.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Text("Trip: \(trip.title)")
                .font(.headline)
        }
        .padding(DesignSystem.Spacing.md)
    }
}
