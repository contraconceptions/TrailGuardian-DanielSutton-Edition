import SwiftUI

struct CampSiteListView: View {
    let campSites: [SampleCampSite]

    var body: some View {
        List(campSites) { site in
            NavigationLink(destination: CampSiteDetailView(campSite: site)) {
                VStack(alignment: .leading) {
                    Text(site.name)
                        .font(.headline)
                    Text(site.notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Saved Camp Sites")
    }
}
