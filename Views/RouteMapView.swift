import SwiftUI
import MapKit

struct RouteMapView: View {
    let points: [TripPoint]
    
    var body: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: points.first?.lat ?? 37.7749, longitude: points.first?.lng ?? -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))) {
            ForEach(points) { point in
                Annotation("Point", coordinate: CLLocationCoordinate2D(latitude: point.lat, longitude: point.lng)) {
                    Image(systemName: "location.circle.fill").foregroundColor(.orange)
                }
            }
        }
        .mapStyle(.hybridFlyover)
    }
}