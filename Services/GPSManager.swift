import Foundation
import CoreLocation

class GPSManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = GPSManager()
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var trailPoints: [TripPoint] = []
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override private init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.pausesLocationUpdatesAutomatically = false
        authorizationStatus = manager.authorizationStatus
    }
    
    func start() {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .notDetermined {
            manager.requestAlwaysAuthorization()
        } else {
            configureBackgroundUpdates()
            if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
    
    private func configureBackgroundUpdates() {
        // Only enable background updates if we have "Always" authorization
        if authorizationStatus == .authorizedAlways {
            manager.allowsBackgroundLocationUpdates = true
        } else {
            manager.allowsBackgroundLocationUpdates = false
        }
    }
    
    func stop() {
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last, loc.horizontalAccuracy >= 0 else { return }
        currentLocation = loc
        
        // Update altitude fusion engine with GPS altitude
        let baroAlt = BarometerManager.shared.baroAltitude
        AltitudeFusionEngine.shared.update(with: loc.altitude, baroAlt: baroAlt)
        
        // Use fused altitude for the point
        let point = TripPoint(
            timestamp: loc.timestamp,
            lat: loc.coordinate.latitude,
            lng: loc.coordinate.longitude,
            fusedAlt: AltitudeFusionEngine.shared.fusedAltitude,
            speed: max(0, loc.speed), // Ensure non-negative
            heading: loc.course >= 0 ? loc.course : 0
        )
        trailPoints.append(point)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("GPS error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        configureBackgroundUpdates()
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
}