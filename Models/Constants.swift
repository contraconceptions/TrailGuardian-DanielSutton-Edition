import Foundation
import CoreLocation

/// Centralized constants for Trail Guardian
enum Constants {
    // MARK: - GPS & Location
    enum GPS {
        /// Maximum acceptable horizontal accuracy in meters
        static let maxAccuracyMeters: Double = 100

        /// High accuracy for active tracking
        static let activeAccuracy = kCLLocationAccuracyBest

        /// Reduced accuracy for background/battery saving
        static let backgroundAccuracy = kCLLocationAccuracyNearestTenMeters

        /// Minimum distance between points in meters (for filtering)
        static let minDistanceBetweenPoints: Double = 5
    }

    // MARK: - Speed & Distance
    enum Conversion {
        /// Meters per second to kilometers per hour
        static let metersPerSecToKmPerHour: Double = 3.6

        /// Approximate meters per degree latitude
        static let metersPerDegreeLat: Double = 111000

        /// Approximate meters per degree longitude at equator
        static let metersPerDegreeLng: Double = 111000
    }

    // MARK: - Difficulty Scoring
    enum Difficulty {
        /// Maximum points for grade in Sutton Score
        static let maxGradePoints: Double = 40

        /// Maximum points for roughness in Sutton Score
        static let maxRoughnessPoints: Double = 30

        /// Maximum points for G-force in Sutton Score
        static let maxGForcePoints: Double = 20

        /// Maximum points for pitch in Sutton Score
        static let maxPitchPoints: Double = 10

        /// Weather penalty for precipitation
        static let weatherPenalty: Int = 2

        /// Minimum roughness threshold to be considered off-roading
        static let minOffroadRoughness: Double = 0.05

        /// Grade divisor for scoring
        static let gradeDivisor: Double = 2.5

        /// Roughness multiplier for scoring
        static let roughnessMultiplier: Double = 100

        /// G-force multiplier for scoring
        static let gForceMultiplier: Double = 10

        /// Pitch divisor for scoring
        static let pitchDivisor: Double = 2
    }

    // MARK: - Bronco Adjustments
    enum Bronco {
        static let rockCrawlBonus: Double = 5
        static let bajaBonus: Double = 3
        static let sandMudBonus: Double = 2
        static let slipperyBonus: Double = 1
        static let lockerBonus: Double = 3
        static let fourWDLowBonus: Double = 2
        static let winchBonus: Double = 4
        static let trailControlBonus: Double = 1
    }

    // MARK: - Altitude Fusion
    enum Altitude {
        /// Weight for barometric altitude in fusion
        static let barometerWeight: Double = 0.7

        /// Weight for GPS altitude in fusion
        static let gpsWeight: Double = 0.3

        /// Moving average window size
        static let movingAverageWindow: Int = 10
    }

    // MARK: - Motion & Telemetry
    enum Motion {
        /// G-force threshold for airborne detection
        static let airborneThreshold: Double = 0.5

        /// Motion snapshot buffer size limit (prevent memory issues)
        static let maxSnapshotBufferSize: Int = 7200 // 2 hours at 1 Hz

        /// Motion update frequency in Hz
        static let updateFrequency: Double = 10.0
    }

    // MARK: - Weather
    enum Weather {
        /// Maximum time to wait for GPS lock before fetching weather (seconds)
        static let gpsWaitTimeout: UInt64 = 10_000_000_000 // 10 seconds in nanoseconds

        /// Interval between GPS lock attempts (seconds)
        static let gpsCheckInterval: UInt64 = 500_000_000 // 0.5 seconds in nanoseconds

        /// Precipitation threshold for weather penalty (inches)
        static let precipitationThreshold: Double = 0.1
    }

    // MARK: - Auto-save
    enum AutoSave {
        /// Interval for auto-saving trip progress (seconds)
        static let intervalSeconds: Double = 60

        /// Filename for temporary trip data
        static let tempTripFilename = "temp_active_trip.json"
    }

    // MARK: - Photo Storage
    enum Photo {
        /// Maximum photo width for compression
        static let maxWidth: CGFloat = 1920

        /// Maximum photo height for compression
        static let maxHeight: CGFloat = 1080

        /// JPEG compression quality (0.0 - 1.0)
        static let compressionQuality: CGFloat = 0.8

        /// Maximum photos per camp site
        static let maxPhotosPerSite: Int = 10
    }

    // MARK: - Map
    enum Map {
        /// Default map center (San Francisco)
        static let defaultLatitude: Double = 37.7749
        static let defaultLongitude: Double = -122.4194

        /// Default map span for zoomed view
        static let detailLatitudeDelta: Double = 0.01
        static let detailLongitudeDelta: Double = 0.01

        /// Default map span for overview
        static let overviewLatitudeDelta: Double = 0.5
        static let overviewLongitudeDelta: Double = 0.5
    }

    // MARK: - PDF Export
    enum PDF {
        /// Standard US Letter size
        static let pageWidth: CGFloat = 612
        static let pageHeight: CGFloat = 792

        /// Margins
        static let marginLeft: CGFloat = 40
        static let marginTop: CGFloat = 40

        /// Font sizes
        static let titleFontSize: CGFloat = 24
        static let sectionTitleFontSize: CGFloat = 18
        static let bodyFontSize: CGFloat = 16
        static let captionFontSize: CGFloat = 12
    }

    // MARK: - App Info
    enum App {
        static let name = "Trail Guardian"
        static let edition = "Daniel Sutton Edition"
        static let fullName = "\(name) – \(edition)"
    }
}
