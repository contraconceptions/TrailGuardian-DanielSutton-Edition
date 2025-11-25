import Foundation

struct Moment: Identifiable, Codable {
    let id: UUID
    let type: String // "photo", "stop", "scenic", "airtime"
    let timestamp: Date
    let lat: Double
    let lng: Double
    let photoPath: String?
    var weather: WeatherSnapshot?
    
    init(id: UUID = UUID(), type: String, timestamp: Date, lat: Double, lng: Double, photoPath: String? = nil, weather: WeatherSnapshot? = nil) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.lat = lat
        self.lng = lng
        self.photoPath = photoPath
        self.weather = weather
    }
}