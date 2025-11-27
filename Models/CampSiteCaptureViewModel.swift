import Foundation
import SwiftUI
import CoreLocation
import PhotosUI

/// ViewModel for CampSiteCaptureView - handles camp site creation logic
@MainActor
class CampSiteCaptureViewModel: ObservableObject {
    // MARK: - Published State

    @Published var name: String = ""
    @Published var description: String = ""
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var elevation: Double = 0

    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var photoData: [Data] = []

    @Published var waterSource: WaterSource?
    @Published var hasFireRing: Bool = false
    @Published var wildlifeSightings: [String] = []
    @Published var accessibilityRating: Int = 3
    @Published var starRating: Int = 3
    @Published var difficultyToReach: Int = 3
    @Published var privacyLevel: Int = 3

    @Published var terrainType: String = ""
    @Published var groundConditions: String = ""
    @Published var requiredGear: [String] = []
    @Published var recommendedGear: [String] = []

    @Published var cellService: Bool? = nil
    @Published var nearestRoad: String?
    @Published var emergencyAccessNotes: String?

    @Published var isProcessingPhotos = false
    @Published var isSaving = false
    @Published var saveError: String?

    // MARK: - Dependencies

    private let campStore = CampSiteStore.shared
    private let weatherManager = WeatherManager.shared
    private let gpsManager = GPSManager.shared

    // MARK: - Configuration

    let associatedTripID: UUID?

    // MARK: - Initialization

    init(associatedTripID: UUID? = nil) {
        self.associatedTripID = associatedTripID
    }

    // MARK: - Lifecycle

    func onAppear() {
        updateLocation()
    }

    // MARK: - Location

    private func updateLocation() {
        if let location = gpsManager.currentLocation {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            elevation = AltitudeFusionEngine.shared.fusedAltitude
        }
    }

    // MARK: - Photo Processing

    func processPhotos(from items: [PhotosPickerItem]) async {
        await MainActor.run {
            isProcessingPhotos = true
            photoData = []
        }

        var loadedData: [Data] = []

        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                continue
            }
            loadedData.append(data)
        }

        await MainActor.run {
            photoData = loadedData
            isProcessingPhotos = false
        }

        print("📸 Loaded \(loadedData.count) photos")
    }

    // MARK: - Validation

    var isValid: Bool {
        return !name.isEmpty &&
               latitude.isFinite &&
               longitude.isFinite &&
               latitude >= -90 && latitude <= 90 &&
               longitude >= -180 && longitude <= 180 &&
               (1...5).contains(accessibilityRating) &&
               (1...5).contains(starRating) &&
               (1...5).contains(difficultyToReach) &&
               (1...5).contains(privacyLevel) &&
               photoData.count <= Constants.Photo.maxPhotosPerSite
    }

    var validationErrors: [String] {
        var errors: [String] = []

        if name.isEmpty {
            errors.append("Name is required")
        }

        if !latitude.isFinite || !longitude.isFinite {
            errors.append("Invalid coordinates")
        }

        if latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180 {
            errors.append("Coordinates out of range")
        }

        if ![1, 2, 3, 4, 5].contains(accessibilityRating) ||
           ![1, 2, 3, 4, 5].contains(starRating) ||
           ![1, 2, 3, 4, 5].contains(difficultyToReach) ||
           ![1, 2, 3, 4, 5].contains(privacyLevel) {
            errors.append("Ratings must be 1-5")
        }

        if photoData.count > Constants.Photo.maxPhotosPerSite {
            errors.append("Too many photos (max \(Constants.Photo.maxPhotosPerSite))")
        }

        return errors
    }

    // MARK: - Saving

    func save() async -> Bool {
        await MainActor.run {
            isSaving = true
            saveError = nil
        }

        // Validate
        guard isValid else {
            await MainActor.run {
                saveError = validationErrors.joined(separator: ", ")
                isSaving = false
            }
            HapticManager.shared.error()
            return false
        }

        // Process and save photos
        var photoPaths: [String] = []

        for data in photoData {
            // Compress photo before saving
            if let compressedData = PhotoHelper.compressPhoto(data),
               let filename = PhotoHelper.savePhoto(compressedData) {
                photoPaths.append(filename)
            }
        }

        // Get current weather
        var weatherSnapshot: WeatherSnapshot? = nil
        if let currentWeather = weatherManager.currentWeather {
            weatherSnapshot = currentWeather
        }

        // Create camp site
        let campSite = CampSite(
            name: name,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude,
            elevation: elevation,
            photos: photoPaths,
            description: description.isEmpty ? nil : description,
            waterSource: waterSource,
            hasFireRing: hasFireRing,
            wildlifeSightings: wildlifeSightings,
            accessibilityRating: accessibilityRating,
            starRating: starRating,
            difficultyToReach: difficultyToReach,
            privacyLevel: privacyLevel,
            weather: weatherSnapshot,
            terrainType: terrainType,
            groundConditions: groundConditions,
            requiredGear: requiredGear,
            recommendedGear: recommendedGear,
            cellService: cellService,
            nearestRoad: nearestRoad,
            emergencyAccessNotes: emergencyAccessNotes,
            associatedTripID: associatedTripID
        )

        // Save to store
        campStore.add(campSite)

        await MainActor.run {
            isSaving = false
        }

        // Check for errors
        if let error = campStore.lastError {
            await MainActor.run {
                saveError = error
            }
            HapticManager.shared.error()
            return false
        }

        // Success!
        HapticManager.shared.success()
        print("✅ Saved camp site: \(campSite.name)")
        return true
    }

    // MARK: - Helpers

    func addWildlifeSighting(_ sighting: String) {
        guard !sighting.isEmpty else { return }
        wildlifeSightings.append(sighting)
        HapticManager.shared.light()
    }

    func removeWildlifeSighting(at index: Int) {
        guard wildlifeSightings.indices.contains(index) else { return }
        wildlifeSightings.remove(at: index)
        HapticManager.shared.light()
    }

    func addRequiredGear(_ gear: String) {
        guard !gear.isEmpty else { return }
        requiredGear.append(gear)
        HapticManager.shared.light()
    }

    func removeRequiredGear(at index: Int) {
        guard requiredGear.indices.contains(index) else { return }
        requiredGear.remove(at: index)
        HapticManager.shared.light()
    }

    func addRecommendedGear(_ gear: String) {
        guard !gear.isEmpty else { return }
        recommendedGear.append(gear)
        HapticManager.shared.light()
    }

    func removeRecommendedGear(at index: Int) {
        guard recommendedGear.indices.contains(index) else { return }
        recommendedGear.remove(at: index)
        HapticManager.shared.light()
    }
}
