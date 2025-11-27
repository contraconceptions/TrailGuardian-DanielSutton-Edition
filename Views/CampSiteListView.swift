import SwiftUI
import MapKit

struct CampSiteListView: View {
    @ObservedObject var store = CampSiteStore.shared
    @State private var searchText: String = ""
    @State private var showingMap = false
    @State private var minRating: Int = 0
    @State private var hasFireRing: Bool?
    @State private var hasWater: Bool?
    
    var filteredSites: [CampSite] {
        var sites = store.campSites
        
        if !searchText.isEmpty {
            sites = sites.filter { $0.name.localizedCaseInsensitiveContains(searchText) || ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false) }
        }
        
        if minRating > 0 {
            sites = sites.filter { $0.starRating >= minRating }
        }
        
        if let fireRing = hasFireRing {
            sites = sites.filter { $0.hasFireRing == fireRing }
        }
        
        if let water = hasWater {
            sites = sites.filter { (water && $0.waterSource != nil) || (!water && $0.waterSource == nil) }
        }
        
        return sites
    }
    
    var body: some View {
        VStack {
            if showingMap {
                MapView(campSites: filteredSites)
                    .edgesIgnoringSafeArea(.all)
            } else if filteredSites.isEmpty {
} else if filteredSites.isEmpty {
    if store.campSites.isEmpty {
        EmptyStateView(
            icon: DesignSystem.Icons.camp,
            title: "No Camp Sites",
            message: "Mark your first camp site while tracking a trail to see it appear here."
        )
    } else {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results",
            message: "Try adjusting your search or filters."
        )
    }
} else {
            } else {
                List(filteredSites) { site in
                    NavigationLink(destination: CampSiteDetailView(campSite: site)) {
                        CampSiteRowView(site: site)
                    }
                    .accessibilityLabel("Camp site: \(site.name), \(site.starRating) stars")
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText, prompt: "Search camp sites")
            }
        }
        .navigationTitle("Camp Sites")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    HapticManager.shared.light()
                    showingMap.toggle()
                } label: {
                    Image(systemName: showingMap ? "list.bullet" : DesignSystem.Icons.map)
                }
                .accessibilityLabel(showingMap ? "Show list view" : "Show map view")
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Section {
                        Stepper("Min Rating: \(minRating)", value: $minRating, in: 0...5)
                    }
                    Section {
                        Picker("Fire Ring", selection: $hasFireRing) {
                            Text("Any").tag(nil as Bool?)
                            Text("Yes").tag(true as Bool?)
                            Text("No").tag(false as Bool?)
                        }
                        Picker("Water Source", selection: $hasWater) {
                            Text("Any").tag(nil as Bool?)
                            Text("Yes").tag(true as Bool?)
                            Text("No").tag(false as Bool?)
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                .accessibilityLabel("Filter camp sites")
            }
        }
    }
}

/// Camp site row component with improved styling
struct CampSiteRowView: View {
    let site: CampSite

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(site.name)
                .font(.headline)

            HStack(spacing: DesignSystem.Spacing.xxs) {
                // Star rating
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= site.starRating ? "star.fill" : "star")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }

                Spacer()

                // Features
                HStack(spacing: DesignSystem.Spacing.xs) {
                    if site.hasFireRing {
                        StatusBadge("Fire", color: .orange, icon: "flame")
                    }
                    if site.waterSource != nil {
                        StatusBadge("Water", color: .blue, icon: "drop.fill")
                    }
                }
            }

            if let desc = site.description {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Text(site.timestamp.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, DesignSystem.Spacing.xxs)
    }
}

struct MapView: View {
    let campSites: [CampSite]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                Map {
                    ForEach(campSites) { site in
                        Annotation(site.name, coordinate: site.location) {
                            VStack {
                                Image(systemName: "tent.fill")
                                    .foregroundColor(.orange)
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                Text(site.name)
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                .mapStyle(.hybrid)
            } else {
                Map(coordinateRegion: $region, annotationItems: campSites) { site in
                    MapAnnotation(coordinate: site.location) {
                        VStack {
                            Image(systemName: "tent.fill")
                                .foregroundColor(.orange)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                            Text(site.name)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .onAppear {
            if let firstSite = campSites.first {
                region = MKCoordinateRegion(
                    center: firstSite.location,
                    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                )
            }
        }
    }
}

