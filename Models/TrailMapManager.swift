import MapKit

/// Manages map display settings and region calculations for trail visualization
class TrailMapManager: ObservableObject {
    static let shared = TrailMapManager()

    @Published var mapType: MKMapType = .hybridFlyover

    private init() {}

    /// Calculate the bounding region that encompasses all trail points
    /// - Parameter points: Array of trip points to bound
    /// - Returns: Map region that fits all points, or nil if no valid points
    func getOfflineRegion(for points: [TripPoint]) -> MKCoordinateRegion? {
        guard !points.isEmpty else { return nil }

        // Filter out invalid coordinates
        let validPoints = points.filter { $0.isValidCoordinate }
        guard !validPoints.isEmpty else { return nil }

        // Calculate bounding box
        let latitudes = validPoints.map { $0.lat }
        let longitudes = validPoints.map { $0.lng }

        guard let minLat = latitudes.min(),
              let maxLat = latitudes.max(),
              let minLng = longitudes.min(),
              let maxLng = longitudes.max() else {
            return nil
        }

        // Calculate center and span with padding
        let centerLat = (minLat + maxLat) / 2
        let centerLng = (minLng + maxLng) / 2
        let spanLat = (maxLat - minLat) * 1.2  // 20% padding
        let spanLng = (maxLng - minLng) * 1.2

        // Ensure minimum span (for very short trails)
        let finalSpanLat = max(spanLat, 0.01)
        let finalSpanLng = max(spanLng, 0.01)

        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng)
        let span = MKCoordinateSpan(latitudeDelta: finalSpanLat, longitudeDelta: finalSpanLng)

        return MKCoordinateRegion(center: center, span: span)
    }

    /// Generate a polyline overlay from trip points
    /// - Parameter points: Array of trip points
    /// - Returns: MKPolyline for map overlay, or nil if insufficient points
    func createPolyline(from points: [TripPoint]) -> MKPolyline? {
        let validPoints = points.filter { $0.isValidCoordinate }
        guard validPoints.count >= 2 else { return nil }

        let coordinates = validPoints.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng) }
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
}