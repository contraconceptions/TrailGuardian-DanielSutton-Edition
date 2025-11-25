import Foundation

struct WeatherSnapshot: Codable {
    let timestamp: Date
    let temperature: Double
    let condition: String // "sunny", "rain", etc.
    let windSpeed: Double
    let precipitation: Double
}