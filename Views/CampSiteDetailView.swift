import SwiftUI
import MapKit

struct CampSiteDetailView: View {
    @ObservedObject var store = CampSiteStore.shared
    @State var campSite: CampSite
    @State private var isEditing = false
    @State private var shareSheetPresented = false
    @State private var shareItems: [Any] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Photos
                if !campSite.photos.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(campSite.photos, id: \.self) { photoPath in
                                if let image = loadImage(from: photoPath) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                
                // Map
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: campSite.location,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )), annotationItems: [campSite]) { site in
                    MapAnnotation(coordinate: site.location) {
                        Image(systemName: "tent.fill")
                            .foregroundColor(.orange)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                .frame(height: 200)
                .cornerRadius(12)
                
                // Basic Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(campSite.name)
                        .font(.title2.bold())
                    
                    HStack {
                        ForEach(0..<campSite.starRating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    if let desc = campSite.description {
                        Text(desc)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(campSite.timestamp.formatted(date: .long, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Features
                VStack(alignment: .leading, spacing: 8) {
                    Text("Features")
                        .font(.headline)
                    
                    if campSite.hasFireRing {
                        Label("Fire Ring", systemImage: "flame.fill")
                    }
                    
                    if let water = campSite.waterSource {
                        VStack(alignment: .leading) {
                            Label("Water Source: \(water.type.rawValue)", systemImage: "drop.fill")
                            Text("\(Int(water.distance))m away")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if water.isPotable {
                                Text("Potable")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    if !campSite.wildlifeSightings.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Wildlife:")
                            ForEach(campSite.wildlifeSightings, id: \.self) { wildlife in
                                Text("• \(wildlife)")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Ratings
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ratings")
                        .font(.headline)
                    Text("Accessibility: \(campSite.accessibilityRating)/5")
                    Text("Difficulty to Reach: \(campSite.difficultyToReach)/5")
                    Text("Privacy: \(campSite.privacyLevel)/5")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Gear
                if !campSite.requiredGear.isEmpty || !campSite.recommendedGear.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gear")
                            .font(.headline)
                        if !campSite.requiredGear.isEmpty {
                            Text("Required:")
                                .font(.subheadline.bold())
                            ForEach(campSite.requiredGear, id: \.self) { gear in
                                Text("• \(gear)")
                            }
                        }
                        if !campSite.recommendedGear.isEmpty {
                            Text("Recommended:")
                                .font(.subheadline.bold())
                            ForEach(campSite.recommendedGear, id: \.self) { gear in
                                Text("• \(gear)")
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Safety
                VStack(alignment: .leading, spacing: 8) {
                    Text("Safety Info")
                        .font(.headline)
                    if let cellService = campSite.cellService {
                        Text("Cell Service: \(cellService ? "Yes" : "No")")
                    }
                    if let road = campSite.nearestRoad {
                        Text("Nearest Road: \(road)")
                    }
                    if let notes = campSite.emergencyAccessNotes {
                        Text("Emergency Access: \(notes)")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Camp Site")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Share Location") {
                        shareLocation()
                    }
                    Button("Get Directions") {
                        openDirections()
                    }
                    Button("Edit") {
                        isEditing = true
                    }
                    Button("Delete", role: .destructive) {
                        store.delete(campSite)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            CampSiteCaptureView()
        }
        .sheet(isPresented: $shareSheetPresented) {
            ShareSheet(items: shareItems)
        }
    }
    
    private func loadImage(from path: String) -> UIImage? {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photoPath = documentsPath.appendingPathComponent("CampSitePhotos").appendingPathComponent(path)
        return UIImage(contentsOfFile: photoPath.path)
    }
    
    private func shareLocation() {
        let coordinateString = "\(campSite.latitude),\(campSite.longitude)"
        let message = "Camp Site: \(campSite.name)\nCoordinates: \(coordinateString)\nGoogle Maps: https://www.google.com/maps?q=\(coordinateString)"
        shareItems = [message]
        shareSheetPresented = true
    }
    
    private func openDirections() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: campSite.location))
        mapItem.name = campSite.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}
