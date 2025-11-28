import SwiftUI

struct StartView: View {
    private let sample = SampleData()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    header
                    weatherCard
                    primaryActions
                    secondaryActions
                }
                .padding(DesignSystem.Spacing.md)
            }
            .navigationTitle("Trail Guardian Lite")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: DesignSystem.Icons.trail)
                .font(.system(size: 50))
                .foregroundColor(.accentColor)
                .padding(.bottom, DesignSystem.Spacing.sm)

            Text("Trail Guardian")
                .font(.largeTitle.bold())

            Text("Lightweight demo build")
                .font(.title3)
                .foregroundColor(.secondary)

            Text("Optimized for first Xcode launch")
                .font(.caption.bold())
                .foregroundColor(DesignSystem.Colors.suttonScore)
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }

    private var weatherCard: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: DesignSystem.Icons.weather)
                .font(.title2)
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text("Sample Conditions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(sample.currentWeather)
                    .font(.headline)
            }

            Spacer()
        }
        .card()
    }

    private var primaryActions: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            NavigationLink(destination: TrackView(sampleTrip: sample.featuredTrip)) {
                HStack {
                    Image(systemName: DesignSystem.Icons.trail)
                        .font(.title3)
                    Text("Explore Demo Trail")
                        .font(.title3.bold())
                }
            }
            .buttonStyle(PrimaryButtonStyle(color: DesignSystem.Colors.startTrail))

            NavigationLink(destination: CampingView(sampleCamps: sample.campSites)) {
                HStack {
                    Image(systemName: DesignSystem.Icons.camp)
                        .font(.title3)
                    Text("Preview Camp Mode")
                        .font(.title3.bold())
                }
            }
            .buttonStyle(PrimaryButtonStyle(color: DesignSystem.Colors.startCamping))
        }
    }

    private var secondaryActions: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            NavigationLink(destination: HistoryView(trips: sample.trips)) {
                HStack {
                    Image(systemName: DesignSystem.Icons.history)
                    Text("View Sample History")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(SecondaryButtonStyle(color: .blue))

            NavigationLink(destination: CampSiteListView(campSites: sample.campSites)) {
                HStack {
                    Image(systemName: DesignSystem.Icons.camp)
                    Text("Browse Camp Sites")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(SecondaryButtonStyle(color: DesignSystem.Colors.campSite))
        }
    }
}