import MapKit

class TrailMapManager: ObservableObject {
    static let shared = TrailMapManager()
    @Published var mapType: MKMapType = .hybridFlyover // Topo-like hybrid
    
    func getOfflineRegion(for points: [TripPoint]) -> MKCoordinateRegion? {
        // Logic to compute bounding box for offline caching
        guard let first = points.first, let last = points.last else { return nil }
        let center = CLLocationCoordinate2D(latitude: (first.lat + last.lat)/2, longitude: (first.lng + last.lng)/2)
        return MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    }
}