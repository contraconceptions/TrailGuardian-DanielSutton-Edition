import Foundation
import CoreLocation

class GPSManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = GPSManager()
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var trailPoints: [TripPoint] = []
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isActiveTracking: Bool = false

    override private init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = Constants.GPS.activeAccuracy
        manager.pausesLocationUpdatesAutomatically = false
        authorizationStatus = manager.authorizationStatus
    }
    
    func start(activeTracking: Bool = true) {
        isActiveTracking = activeTracking
        authorizationStatus = manager.authorizationStatus

        // Set accuracy based on tracking mode
        manager.desiredAccuracy = activeTracking ? Constants.GPS.activeAccuracy : Constants.GPS.backgroundAccuracy

        if authorizationStatus == .notDetermined {
            manager.requestAlwaysAuthorization()
        } else {
            configureBackgroundUpdates()
            if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }

    func setActiveTracking(_ active: Bool) {
        isActiveTracking = active
        manager.desiredAccuracy = active ? Constants.GPS.activeAccuracy : Constants.GPS.backgroundAccuracy
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

    func clearTrailPoints() {
        trailPoints.removeAll()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        // Filter out poor quality readings: horizontalAccuracy < 0 indicates invalid,
        // and we want readings better than our threshold for reliable tracking
        guard loc.horizontalAccuracy >= 0 && loc.horizontalAccuracy <= Constants.GPS.maxAccuracyMeters else { return }
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