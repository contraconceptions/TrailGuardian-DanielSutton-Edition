import SwiftUI

struct CampingView: View {
    let sampleCamps: [SampleCampSite]

    var body: some View {
        List(sampleCamps) { site in
            NavigationLink(destination: CampSiteDetailView(campSite: site)) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(site.name)
                        .font(.headline)
                    Text(site.notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, DesignSystem.Spacing.xs)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Camp Mode Demo")
    }
}
