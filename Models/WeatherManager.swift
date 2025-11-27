import WeatherKit
import CoreLocation

class WeatherManager: ObservableObject {
    static let shared = WeatherManager()
    private let weatherService = WeatherService.shared
    
    @Published var currentWeather: WeatherSnapshot?
    @Published var weatherError: String?
    
    private var isAvailable: Bool {
        // WeatherKit requires iOS 16+ and proper entitlements
        if #available(iOS 16.0, *) {
            return true
        }
        return false
    }
    
    func fetchCurrent(at location: CLLocationCoordinate2D) async {
        guard isAvailable else {
            weatherError = "WeatherKit requires iOS 16.0 or later"
            print("WeatherKit not available on this iOS version")
            return
        }
        
        guard location.latitude != 0 && location.longitude != 0 else {
            weatherError = "Invalid location coordinates"
            return
        }
        
        do {
            let weather = try await weatherService.weather(for: location)
            await MainActor.run {
                // Convert WeatherCondition to string
                let conditionString: String
                switch weather.currentWeather.condition {
                case .clear:
                    conditionString = "Clear"
                case .cloudy:
                    conditionString = "Cloudy"
                case .haze:
                    conditionString = "Haze"
                case .mostlyClear:
                    conditionString = "Mostly Clear"
                case .mostlyCloudy:
                    conditionString = "Mostly Cloudy"
                case .partlyCloudy:
                    conditionString = "Partly Cloudy"
                case .smoky:
                    conditionString = "Smoky"
                case .breezy:
                    conditionString = "Breezy"
                case .windy:
                    conditionString = "Windy"
                case .frigid:
                    conditionString = "Frigid"
                case .hot:
                    conditionString = "Hot"
                case .freezingDrizzle:
                    conditionString = "Freezing Drizzle"
                case .freezingRain:
                    conditionString = "Freezing Rain"
                case .drizzle:
                    conditionString = "Drizzle"
                case .rain:
                    conditionString = "Rain"
                case .sleet:
                    conditionString = "Sleet"
                case .snow:
                    conditionString = "Snow"
                case .strongStorms:
                    conditionString = "Strong Storms"
                case .sunShowers:
                    conditionString = "Sun Showers"
                case .thunderstorms:
                    conditionString = "Thunderstorms"
                case .isolatedThunderstorms:
                    conditionString = "Isolated Thunderstorms"
                case .scatteredThunderstorms:
                    conditionString = "Scattered Thunderstorms"
                @unknown default:
                    conditionString = "Unknown"
                }
                
                // Convert precipitation from mm/hr to inches for consistency with Constants
                let precipMm = weather.currentWeather.precipitation?.intensity.convertedTo(unit: .millimetersPerHour).value ?? 0
                let precipInches = precipMm / 25.4 // 1 inch = 25.4 mm

                currentWeather = WeatherSnapshot(
                    timestamp: Date(),
                    temperature: weather.currentWeather.temperature.convertedTo(unit: .celsius).value,
                    condition: conditionString,
                    windSpeed: weather.currentWeather.wind.speed.convertedTo(unit: .kilometersPerHour).value,
                    precipitation: precipInches
                )
                weatherError = nil
            }
        } catch {
            await MainActor.run {
                weatherError = error.localizedDescription
                print("Weather fetch error: \(error.localizedDescription)")
            }
        }
    }
}