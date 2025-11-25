import Foundation

struct Trip: Identifiable, Codable {
    let id: UUID
    var title: String
    var startedAt: Date
    var endedAt: Date?
    var points: [TripPoint]
    var moments: [Moment]
    var weatherSnapshots: [WeatherSnapshot] = []
    var telemetryStats: TelemetryStats = TelemetryStats()
    var difficultyRatings: DifficultyRatings = DifficultyRatings()
    var vehicleData: VehicleData = VehicleData()
    var campSites: [CampSite] = []
    
    static func new() -> Trip {
        Trip(
            id: UUID(),
            title: "Trail – \(Date().formatted(.dateTime.year().month().day()))",
            startedAt: Date(),
            endedAt: nil,
            points: [],
            moments: []
        )
    }
}

struct TelemetryStats: Codable {
    var maxPitch: Double = 0
    var maxRoll: Double = 0
    var maxGForce: Double = 0
    var totalAirtime: Double = 0
    var suttonScore: Int = 0
}

struct DifficultyRatings: Codable {
    var suttonScore: Int = 0 // 0-100
    var jeepBadge: Int = 0 // 1-10
    var wellsRating: String = "Green Circle"
    var usfsRating: String = "Easiest"
    var international: String = "Blue"
}