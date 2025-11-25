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
            } else {
                List(filteredSites) { site in
                    NavigationLink(destination: CampSiteDetailView(campSite: site)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(site.name)
                                .font(.headline)
                            HStack {
                                ForEach(0..<site.starRating, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                }
                            }
                            Text(site.timestamp.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let desc = site.description {
                                Text(desc)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .searchable(text: $searchText)
            }
        }
        .navigationTitle("Camp Sites")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingMap.toggle()
                } label: {
                    Image(systemName: showingMap ? "list.bullet" : "map")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Stepper("Min Rating: \(minRating)", value: $minRating, in: 0...5)
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
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
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

