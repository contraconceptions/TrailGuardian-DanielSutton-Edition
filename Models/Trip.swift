import Foundation
import CoreLocation

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

    // MARK: - Computed Properties

    /// Total distance traveled in meters
    var totalDistanceMeters: Double {
        guard points.count >= 2 else { return 0 }

        var distance: Double = 0
        for i in 1..<points.count {
            let prev = points[i - 1]
            let curr = points[i]

            let loc1 = CLLocation(latitude: prev.lat, longitude: prev.lng)
            let loc2 = CLLocation(latitude: curr.lat, longitude: curr.lng)
            distance += loc2.distance(from: loc1)
        }
        return distance
    }

    /// Total distance in kilometers
    var totalDistanceKm: Double {
        totalDistanceMeters / 1000.0
    }

    /// Total distance in miles
    var totalDistanceMiles: Double {
        totalDistanceMeters / 1609.34
    }

    /// Trip duration in seconds
    var durationSeconds: TimeInterval? {
        guard let ended = endedAt else { return nil }
        return ended.timeIntervalSince(startedAt)
    }

    /// Formatted duration string (e.g., "2h 34m")
    var formattedDuration: String {
        guard let duration = durationSeconds else { return "Ongoing" }

        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    /// Average speed in km/h (excluding stopped time)
    var averageSpeedKmh: Double {
        guard let duration = durationSeconds, duration > 0 else { return 0 }
        return (totalDistanceKm / duration) * 3600
    }

    /// Maximum speed recorded in km/h
    var maxSpeedKmh: Double {
        points.map { $0.speed * Constants.Conversion.metersPerSecToKmPerHour }.max() ?? 0
    }

    /// Total elevation gain in meters
    var elevationGainMeters: Double {
        guard points.count >= 2 else { return 0 }

        var gain: Double = 0
        for i in 1..<points.count {
            let diff = points[i].fusedAlt - points[i - 1].fusedAlt
            if diff > 0 {
                gain += diff
            }
        }
        return gain
    }

    /// Total elevation loss in meters
    var elevationLossMeters: Double {
        guard points.count >= 2 else { return 0 }

        var loss: Double = 0
        for i in 1..<points.count {
            let diff = points[i].fusedAlt - points[i - 1].fusedAlt
            if diff < 0 {
                loss += abs(diff)
            }
        }
        return loss
    }

    /// Minimum elevation in meters
    var minElevation: Double {
        points.map { $0.fusedAlt }.min() ?? 0
    }

    /// Maximum elevation in meters
    var maxElevation: Double {
        points.map { $0.fusedAlt }.max() ?? 0
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