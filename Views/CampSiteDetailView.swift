import SwiftUI

struct CampSiteDetailView: View {
    let campSite: SampleCampSite

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(campSite.name)
                .font(.largeTitle.bold())
            Text(campSite.notes)
                .font(.body)
                .foregroundColor(.secondary)
            Text("Location: \(campSite.location.latitude, specifier: "%.4f"), \(campSite.location.longitude, specifier: "%.4f")")
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(DesignSystem.Spacing.md)
        .navigationTitle("Camp Site")
        .navigationBarTitleDisplayMode(.inline)
    }
}
