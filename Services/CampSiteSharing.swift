import Foundation
import CoreLocation

class CampSiteSharing {
    static func generateGPX(for campSite: CampSite) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="Trail Guardian">
            <wpt lat="\(campSite.latitude)" lon="\(campSite.longitude)">
                <ele>\(campSite.elevation)</ele>
                <name>\(campSite.name)</name>
                <desc>\(campSite.description ?? "")</desc>
                <time>\(dateFormatter.string(from: campSite.timestamp))</time>
            </wpt>
        </gpx>
        """
    }
    
    static func generateKML(for campSite: CampSite) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
            <Placemark>
                <name>\(campSite.name)</name>
                <description>\(campSite.description ?? "")</description>
                <Point>
                    <coordinates>\(campSite.longitude),\(campSite.latitude),\(campSite.elevation)</coordinates>
                </Point>
                <TimeStamp>
                    <when>\(dateFormatter.string(from: campSite.timestamp))</when>
                </TimeStamp>
            </Placemark>
        </kml>
        """
    }
    
    static func generateGeoJSON(for campSite: CampSite) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let geoJSON: [String: Any] = [
            "type": "Feature",
            "geometry": [
                "type": "Point",
                "coordinates": [campSite.longitude, campSite.latitude, campSite.elevation]
            ],
            "properties": [
                "name": campSite.name,
                "description": campSite.description ?? "",
                "timestamp": dateFormatter.string(from: campSite.timestamp),
                "elevation": campSite.elevation,
                "starRating": campSite.starRating,
                "hasFireRing": campSite.hasFireRing,
                "waterSource": campSite.waterSource != nil
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: geoJSON, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "{}"
    }
    
    static func shareLocation(campSite: CampSite) -> String {
        let coordinateString = "\(campSite.latitude),\(campSite.longitude)"
        return """
        Camp Site: \(campSite.name)
        Coordinates: \(coordinateString)
        Elevation: \(Int(campSite.elevation))m
        Google Maps: https://www.google.com/maps?q=\(coordinateString)
        Apple Maps: http://maps.apple.com/?ll=\(coordinateString)
        """
    }
}

