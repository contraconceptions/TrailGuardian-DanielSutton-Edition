import Foundation
import CoreLocation

struct TripPoint: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let lat: Double
    let lng: Double
    let fusedAlt: Double // Fused GPS + baro
    let speed: Double
    let heading: Double
    let roughness: Double
    let pitch: Double
    let roll: Double
    let gForce: Double
    let gradePercent: Double

    init(
        id: UUID = UUID(),
        timestamp: Date,
        lat: Double,
        lng: Double,
        fusedAlt: Double,
        speed: Double,
        heading: Double,
        roughness: Double = 0,
        pitch: Double = 0,
        roll: Double = 0,
        gForce: Double = 0,
        gradePercent: Double = 0
    ) {
        self.id = id
        self.timestamp = timestamp
        self.lat = lat
        self.lng = lng
        self.fusedAlt = fusedAlt
        self.speed = speed
        self.heading = heading
        self.roughness = roughness
        self.pitch = pitch
        self.roll = roll
        self.gForce = gForce
        self.gradePercent = gradePercent
    }

    // MARK: - Validation

    /// Check if coordinates are valid (finite and within Earth's bounds)
    var isValidCoordinate: Bool {
        return lat.isFinite &&
               lng.isFinite &&
               lat >= -90 && lat <= 90 &&
               lng >= -180 && lng <= 180
    }

    /// Check if altitude is reasonable
    var isValidAltitude: Bool {
        return fusedAlt.isFinite && fusedAlt > -500 && fusedAlt < 9000
    }

    /// Check if all numeric values are finite (no NaN or infinity)
    var hasFiniteValues: Bool {
        return lat.isFinite &&
               lng.isFinite &&
               fusedAlt.isFinite &&
               speed.isFinite &&
               heading.isFinite &&
               roughness.isFinite &&
               pitch.isFinite &&
               roll.isFinite &&
               gForce.isFinite &&
               gradePercent.isFinite
    }

    /// Check if point is fully valid for mapping and calculations
    var isValid: Bool {
        return isValidCoordinate && isValidAltitude && hasFiniteValues
    }

    /// Convert to CLLocationCoordinate2D for MapKit
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}