import Foundation

struct Moment: Identifiable, Codable {
    let id = UUID()
    let type: String // "photo", "stop", "scenic", "airtime"
    let timestamp: Date
    let lat: Double
    let lng: Double
    let photoPath: String?
    var weather: WeatherSnapshot?
}