import Foundation
import CoreLocation

struct SampleTrip: Identifiable {
    let id = UUID()
    let title: String
    let distance: String
    let duration: String
    let difficulty: String
    let summary: String
}

struct SampleCampSite: Identifiable {
    let id = UUID()
    let name: String
    let notes: String
    let location: CLLocationCoordinate2D
}

struct SampleData {
    let currentWeather = "12°C · Partly Cloudy"

    let trips: [SampleTrip] = [
        SampleTrip(
            title: "Flagstaff Ridge",
            distance: "14.2 mi",
            duration: "2h 45m",
            difficulty: "Moderate",
            summary: "Flowy forest trail with great overlooks and a mellow rock garden."
        ),
        SampleTrip(
            title: "Red Rock Loop",
            distance: "9.8 mi",
            duration: "1h 55m",
            difficulty: "Easy",
            summary: "Beginner-friendly loop through red sandstone and juniper."
        ),
        SampleTrip(
            title: "Cinder Hills",
            distance: "22.4 mi",
            duration: "4h 10m",
            difficulty: "Advanced",
            summary: "Sand, whoops, and lava rock climbs with plenty of open views."
        )
    ]

    var featuredTrip: SampleTrip { trips.first ?? SampleTrip(title: "Sample", distance: "0 mi", duration: "--", difficulty: "Easy", summary: "Demo trip") }

    let campSites: [SampleCampSite] = [
        SampleCampSite(
            name: "Walnut Canyon Rim",
            notes: "Shaded pines, established fire ring, strong LTE.",
            location: CLLocationCoordinate2D(latitude: 35.2002, longitude: -111.4867)
        ),
        SampleCampSite(
            name: "Aspen Meadow",
            notes: "Flat tent pads with nearby creek and morning sun.",
            location: CLLocationCoordinate2D(latitude: 35.2688, longitude: -111.5861)
        ),
        SampleCampSite(
            name: "Lava Flow Flats",
            notes: "Open sky for stargazing, windy in the afternoon.",
            location: CLLocationCoordinate2D(latitude: 35.3152, longitude: -111.6013)
        )
    ]
}
