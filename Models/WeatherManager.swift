import WeatherKit
import CoreLocation

class WeatherManager: ObservableObject {
    static let shared = WeatherManager()
    private let weatherService = WeatherService.shared
    
    @Published var currentWeather: WeatherSnapshot?
    
    func fetchCurrent(at location: CLLocationCoordinate2D) async {
        do {
            let weather = try await weatherService.weather(for: location)
            currentWeather = WeatherSnapshot(
                timestamp: Date(),
                temperature: weather.currentWeather.temperature.convertedTo(unit: .celsius).value,
                condition: weather.currentWeather.condition.rawValue,
                windSpeed: weather.currentWeather.wind.speed.convertedTo(unit: .kilometersPerHour).value,
                precipitation: weather.currentWeather.precipitation?.intensity ?? 0
            )
        } catch {
            print("Weather fetch error: \(error)")
        }
    }
}