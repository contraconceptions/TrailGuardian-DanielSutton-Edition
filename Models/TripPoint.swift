import Foundation

struct TripPoint: Identifiable, Codable {
    let id: UUID
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
    
    init(id: UUID = UUID(), timestamp: Date, lat: Double, lng: Double, fusedAlt: Double, speed: Double, heading: Double, roughness: Double = 0, pitch: Double = 0, roll: Double = 0, gForce: Double = 0, gradePercent: Double = 0) {
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
}