import Foundation
import CoreLocation

class CampSiteStore: ObservableObject {
    static let shared = CampSiteStore()
    @Published var campSites: [CampSite] = []
    
    private let saveURL: URL
    
    private init() {
        let fm = FileManager.default
        saveURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("campsites.json")
        load()
    }
    
    func add(_ campSite: CampSite) {
        campSites.insert(campSite, at: 0)
        save()
    }
    
    func update(_ campSite: CampSite) {
        if let index = campSites.firstIndex(where: { $0.id == campSite.id }) {
            campSites[index] = campSite
            save()
        }
    }
    
    func delete(_ campSite: CampSite) {
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
        } catch {
            print("Failed to save camp sites: \(error.localizedDescription)")
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
            campSites = try decoder.decode([CampSite].self, from: data)
        } catch {
            print("Failed to load camp sites: \(error.localizedDescription)")
            campSites = []
        }
    }
}

