import Foundation
import CoreLocation

class CampSiteStore: ObservableObject {
    static let shared = CampSiteStore()
    @Published var campSites: [CampSite] = []
    @Published var lastError: String?

    private let saveURL: URL

    private init() {
        let fm = FileManager.default
        saveURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("campsites.json")
        load()
    }

    /// Add a new camp site (validates before saving)
    func add(_ campSite: CampSite) {
        guard campSite.isValid else {
            lastError = "Cannot save invalid camp site"
            print("⚠️ Attempted to save invalid camp site: \(campSite.name)")
            return
        }

        campSites.insert(campSite, at: 0)
        save()
    }

    /// Update an existing camp site (validates before saving)
    func update(_ campSite: CampSite) {
        guard campSite.isValid else {
            lastError = "Cannot update invalid camp site"
            print("⚠️ Attempted to update invalid camp site: \(campSite.name)")
            return
        }

        if let index = campSites.firstIndex(where: { $0.id == campSite.id }) {
            campSites[index] = campSite
            save()
        }
    }

    /// Delete a camp site and its associated photos
    func delete(_ campSite: CampSite) {
        // Delete associated photos
        for photoFilename in campSite.photos {
            PhotoHelper.deletePhoto(filename: photoFilename)
        }

        campSites.removeAll { $0.id == campSite.id }
        save()
    }
    
    func searchNearby(center: CLLocationCoordinate2D, radiusMeters: Double) -> [CampSite] {
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        return campSites.filter { site in
            let siteLocation = CLLocation(latitude: site.latitude, longitude: site.longitude)
            return centerLocation.distance(from: siteLocation) <= radiusMeters
        }
    }
    
    func searchByDateRange(start: Date, end: Date) -> [CampSite] {
        return campSites.filter { $0.timestamp >= start && $0.timestamp <= end }
    }
    
    func searchByRating(minRating: Int) -> [CampSite] {
        return campSites.filter { $0.starRating >= minRating }
    }
    
    func searchByFeature(hasFireRing: Bool? = nil, hasWaterSource: Bool? = nil) -> [CampSite] {
        return campSites.filter { site in
            if let fireRing = hasFireRing, site.hasFireRing != fireRing {
                return false
            }
            if let water = hasWaterSource, (water && site.waterSource == nil) || (!water && site.waterSource != nil) {
                return false
            }
            return true
        }
    }
    
    func getSitesForTrip(tripID: UUID) -> [CampSite] {
        return campSites.filter { $0.associatedTripID == tripID }
    }
    
    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(campSites)
            try data.write(to: saveURL, options: [.atomic])
            lastError = nil
        } catch {
            lastError = "Failed to save camp sites: \(error.localizedDescription)"
            print(lastError ?? "")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: saveURL.path) else {
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let data = try Data(contentsOf: saveURL)
            let loadedSites = try decoder.decode([CampSite].self, from: data)

            // Filter out invalid camp sites
            campSites = loadedSites.filter { site in
                if !site.isValid {
                    print("⚠️ Skipping invalid camp site during load: \(site.name)")
                    return false
                }
                return true
            }

            lastError = nil
        } catch {
            lastError = "Failed to load camp sites: \(error.localizedDescription)"
            print(lastError ?? "")
            campSites = []
        }
    }
}

