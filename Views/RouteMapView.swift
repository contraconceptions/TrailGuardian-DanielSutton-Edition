import SwiftUI
import MapKit

struct RouteMapView: View {
    let points: [TripPoint]
    
    private var coordinates: [CLLocationCoordinate2D] {
        points.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng) }
    }
    
    private var center: CLLocationCoordinate2D {
        guard !points.isEmpty else {
            return CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // Default SF
        }
        let avgLat = points.reduce(0) { $0 + $1.lat } / Double(points.count)
        let avgLng = points.reduce(0) { $0 + $1.lng } / Double(points.count)
        return CLLocationCoordinate2D(latitude: avgLat, longitude: avgLng)
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            Map(initialPosition: .region(MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))) {
                if !coordinates.isEmpty {
                    MapPolyline(coordinates: coordinates)
                        .stroke(.orange, lineWidth: 4)
                    
                    // Start marker
                    if let start = coordinates.first {
                        Annotation("Start", coordinate: start) {
                            Image(systemName: "flag.fill")
                                .foregroundColor(.green)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                    
                    // End marker
                    if let end = coordinates.last, coordinates.count > 1 {
                        Annotation("End", coordinate: end) {
                            Image(systemName: "flag.checkered")
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .mapStyle(.hybrid)
        } else {
            // Fallback for iOS 16
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )), showsUserLocation: false, mapType: .hybrid)
        }
    }
}