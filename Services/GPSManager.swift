import Foundation
import CoreLocation

class GPSManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = GPSManager()
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var trailPoints: [TripPoint] = []
    
    override private init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }
    
    func start() {
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    func stop() {
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        currentLocation = loc
        
        let point = TripPoint(
            timestamp: Date(),
            lat: loc.coordinate.latitude,
            lng: loc.coordinate.longitude,
            fusedAlt: loc.altitude, // Will be fused in AltitudeFusion
            speed: loc.speed,
            heading: loc.course
        )
        trailPoints.append(point)
    }
}