import Foundation

struct TripPoint: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let lat: Double
    let lng: Double
    let fusedAlt: Double // Fused GPS + baro
    let speed: Double
    let heading: Double
    let roughness: Double = 0
    let pitch: Double = 0
    let roll: Double = 0
    let gForce: Double = 0
    let gradePercent: Double = 0
}