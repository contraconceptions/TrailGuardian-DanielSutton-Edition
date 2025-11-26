import Foundation
import CoreLocation

struct CampSite: Identifiable, Codable {
    let id: UUID
    var name: String
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    var elevation: Double
    var photos: [String] // Photo file paths
    var description: String?
    var waterSource: WaterSource?
    var hasFireRing: Bool
    var wildlifeSightings: [String]
    var accessibilityRating: Int // 1-5
    var starRating: Int // 1-5
    var difficultyToReach: Int // 1-5
    var privacyLevel: Int // 1-5
    var weather: WeatherSnapshot?
    var terrainType: String
    var groundConditions: String
    var requiredGear: [String]
    var recommendedGear: [String]
    var cellService: Bool?
    var nearestRoad: String?
    var emergencyAccessNotes: String?
    var associatedTripID: UUID? // If part of a trail trip
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: - Validation

    /// Check if coordinates are valid
    var isValidCoordinate: Bool {
        return latitude.isFinite &&
               longitude.isFinite &&
               latitude >= -90 && latitude <= 90 &&
               longitude >= -180 && longitude <= 180
    }

    /// Check if elevation is reasonable
    var isValidElevation: Bool {
        return elevation.isFinite && elevation > -500 && elevation < 9000
    }

    /// Check if ratings are in valid range (1-5)
    var hasValidRatings: Bool {
        return (1...5).contains(accessibilityRating) &&
               (1...5).contains(starRating) &&
               (1...5).contains(difficultyToReach) &&
               (1...5).contains(privacyLevel)
    }

    /// Check if photo count is within limit
    var hasValidPhotoCount: Bool {
        return photos.count <= Constants.Photo.maxPhotosPerSite
    }

    /// Check if camp site data is valid
    var isValid: Bool {
        return !name.isEmpty &&
               isValidCoordinate &&
               isValidElevation &&
               hasValidRatings &&
               hasValidPhotoCount
    }

    init(
        id: UUID = UUID(),
        name: String,
        timestamp: Date = Date(),
        latitude: Double,
        longitude: Double,
        elevation: Double = 0,
        photos: [String] = [],
        description: String? = nil,
        waterSource: WaterSource? = nil,
        hasFireRing: Bool = false,
        wildlifeSightings: [String] = [],
        accessibilityRating: Int = 3,
        starRating: Int = 3,
        difficultyToReach: Int = 3,
        privacyLevel: Int = 3,
        weather: WeatherSnapshot? = nil,
        terrainType: String = "",
        groundConditions: String = "",
        requiredGear: [String] = [],
        recommendedGear: [String] = [],
        cellService: Bool? = nil,
        nearestRoad: String? = nil,
        emergencyAccessNotes: String? = nil,
        associatedTripID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.photos = photos
        self.description = description
        self.waterSource = waterSource
        self.hasFireRing = hasFireRing
        self.wildlifeSightings = wildlifeSightings
        self.accessibilityRating = accessibilityRating
        self.starRating = starRating
        self.difficultyToReach = difficultyToReach
        self.privacyLevel = privacyLevel
        self.weather = weather
        self.terrainType = terrainType
        self.groundConditions = groundConditions
        self.requiredGear = requiredGear
        self.recommendedGear = recommendedGear
        self.cellService = cellService
        self.nearestRoad = nearestRoad
        self.emergencyAccessNotes = emergencyAccessNotes
        self.associatedTripID = associatedTripID
    }
}

struct WaterSource: Codable {
    var distance: Double // Distance in meters
    var type: WaterSourceType
    var isPotable: Bool
    var notes: String?
    
    enum WaterSourceType: String, Codable, CaseIterable {
        case stream = "Stream"
        case river = "River"
        case lake = "Lake"
        case spring = "Spring"
        case well = "Well"
        case other = "Other"
    }
}

