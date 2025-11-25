import Foundation
import CoreLocation

// Recreation Information Database API
// Documentation: https://www.recreation.gov/use-our-data
class RIDBService {
    static let shared = RIDBService()
    
    private let baseURL = "https://ridb.recreation.gov/api/v1"
    private let apiManager = APIManager.shared
    
    private init() {}
    
    // TODO: Get API key from Recreation.gov
    // Registration: https://ridb.recreation.gov/
    private var apiKey: String? {
        apiManager.getAPIKey(for: "ridb")
    }
    
    func searchRecreationAreas(near location: CLLocationCoordinate2D, radius: Double = 50000) async throws -> [RIDBRecreationArea] {
        // TODO: Implement RIDB API call
        // Endpoint: GET /recareas?limit=50&offset=0&latitude={lat}&longitude={lng}&radius={radius}
        // Requires: API key in header "apikey"
        
        guard let key = apiKey else {
            throw RIDBError.apiKeyMissing
        }
        
        guard apiManager.canMakeRequest(for: "ridb") else {
            throw RIDBError.rateLimitExceeded
        }
        
        // Stub implementation
        // When implemented:
        /*
        let urlString = "\(baseURL)/recareas?limit=50&latitude=\(location.latitude)&longitude=\(location.longitude)&radius=\(Int(radius))"
        guard let url = URL(string: urlString) else {
            throw RIDBError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(key, forHTTPHeaderField: "apikey")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        // Parse JSON response
        */
        
        throw RIDBError.notImplemented("RIDB API integration requires API key registration")
    }
    
    func getFacilities(for areaID: String) async throws -> [RIDBFacility] {
        // TODO: Implement facility lookup
        // Endpoint: GET /recareas/{areaID}/facilities
        throw RIDBError.notImplemented("Facility lookup not implemented")
    }
    
    func getActivities(for areaID: String) async throws -> [String] {
        // TODO: Implement activities lookup
        // Endpoint: GET /recareas/{areaID}/activities
        throw RIDBError.notImplemented("Activities lookup not implemented")
    }
}

enum RIDBError: LocalizedError {
    case notImplemented(String)
    case apiKeyMissing
    case rateLimitExceeded
    case invalidURL
    case networkError(Error)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .notImplemented(let message):
            return "RIDB API not implemented: \(message)"
        case .apiKeyMissing:
            return "RIDB API key not configured. Register at https://ridb.recreation.gov/"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .invalidURL:
            return "Invalid API URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from RIDB API"
        }
    }
}

struct RIDBRecreationArea: Codable {
    let recAreaID: String
    let recAreaName: String
    let recAreaDescription: String?
    let latitude: Double
    let longitude: Double
    let activities: [RIDBActivity]?
}

struct RIDBActivity: Codable {
    let activityID: String
    let activityName: String
}

struct RIDBFacility: Codable {
    let facilityID: String
    let facilityName: String
    let facilityDescription: String?
    let latitude: Double
    let longitude: Double
    let reservable: Bool
    let enabled: Bool
}

