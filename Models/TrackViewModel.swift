import Foundation
import SwiftUI
import Combine
import CoreLocation

/// ViewModel for TrackView - handles business logic separate from UI
@MainActor
class TrackViewModel: ObservableObject {
    // MARK: - Published State

    @Published var trip: Trip
    @Published var isLoadingWeather = true
    @Published var isLoadingGPS = true
    @Published var showingEasterEgg = false
    @Published var lastMapUpdate: Date = .distantPast

    // MARK: - Dependencies

    private let gpsManager = GPSManager.shared
    private let motionManager = MotionManager.shared
    private let weatherManager = WeatherManager.shared
    private let altitudeFusion = AltitudeFusionEngine.shared
    private let tripStore = TripStore.shared
    private let campStore = CampSiteStore.shared

    // MARK: - Private State

    private var autoSaveTask: Task<Void, Never>?
    private var weatherTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Configuration

    private let autoSaveInterval: TimeInterval = Constants.AutoSave.intervalSeconds
    private let mapUpdateThrottle: TimeInterval = 1.0

    // MARK: - Initialization

    init() {
        // Check for crash recovery
        if let tempTrip = tripStore.loadTempTrip() {
            self.trip = tempTrip
            print("📦 Recovered trip from crash: \(tempTrip.title)")
        } else {
            self.trip = Trip.new()
        }
    }

    // MARK: - Lifecycle

    func onAppear() {
        startTracking()
        startAutoSave()
        fetchWeather()
    }

    func onDisappear() {
        stopTracking()
        stopAutoSave()
        weatherTask?.cancel()
    }

    // MARK: - Tracking Control

    private func startTracking() {
        // Reset altitude fusion engine
        altitudeFusion.reset()

        // Start sensors
        gpsManager.start(activeTracking: true)
        motionManager.start()
        BarometerManager.shared.start()

        print("🚀 Started tracking: \(trip.title)")
    }

    private func stopTracking() {
        gpsManager.stop()
        motionManager.stop()
        BarometerManager.shared.stop()
        motionManager.clearSnapshots()

        print("⏹️ Stopped tracking")
    }

    // MARK: - Auto-Save

    private func startAutoSave() {
        autoSaveTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(self?.autoSaveInterval ?? 60) * 1_000_000_000)

                guard !Task.isCancelled else { break }

                await self?.performAutoSave()
            }
        }
    }

    private func stopAutoSave() {
        autoSaveTask?.cancel()
        autoSaveTask = nil
    }

    private func performAutoSave() {
        let builtTrip = buildTrip()
        tripStore.saveTempTrip(builtTrip)
        print("💾 Auto-saved trip at \(Date().formatted(date: .omitted, time: .standard))")
    }

    // MARK: - Weather

    private func fetchWeather() {
        weatherTask = Task { [weak self] in
            guard let self = self else { return }

            // Wait for GPS lock with timeout
            var attempts = 0
            let maxAttempts = 20

            while self.gpsManager.currentLocation == nil && attempts < maxAttempts && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: Constants.Weather.gpsCheckInterval)
                attempts += 1
            }

            await MainActor.run {
                self.isLoadingGPS = false
            }

            guard !Task.isCancelled else { return }

            // Fetch weather if we have location
            if let location = self.gpsManager.currentLocation?.coordinate {
                await self.weatherManager.fetchCurrent(at: location)
            }

            await MainActor.run {
                self.isLoadingWeather = false
            }
        }
    }

    // MARK: - Trip Building

    func buildTrip() -> Trip {
        var t = trip
        t.endedAt = Date()

        // Calculate grade and attach motion data to each point
        var maxPitch: Double = 0
        var maxRoll: Double = 0
        var maxGForce: Double = 0

        t.points = gpsManager.trailPoints.enumerated().map { index, p in
            // Get motion snapshot nearest to this point's timestamp
            let motionSnapshot = motionManager.getSnapshot(nearestTo: p.timestamp) ?? MotionSnapshot(
                timestamp: p.timestamp,
                roughness: motionManager.roughness,
                pitch: motionManager.pitch,
                roll: motionManager.roll,
                gForce: motionManager.gForce,
                isAirborne: motionManager.isAirborne
            )

            // Calculate grade between consecutive points
            var gradePercent: Double = 0
            if index > 0 {
                let prevPoint = gpsManager.trailPoints[index - 1]
                let altitudeDiff = p.fusedAlt - prevPoint.fusedAlt
                let distance = sqrt(
                    pow((p.lat - prevPoint.lat) * Constants.Conversion.metersPerDegreeLat, 2) +
                    pow((p.lng - prevPoint.lng) * Constants.Conversion.metersPerDegreeLng * cos(p.lat * .pi / 180), 2)
                )
                if distance > 0 {
                    gradePercent = (altitudeDiff / distance) * 100
                }
            }

            // Track max values
            maxPitch = max(maxPitch, abs(motionSnapshot.pitch))
            maxRoll = max(maxRoll, abs(motionSnapshot.roll))
            maxGForce = max(maxGForce, motionSnapshot.gForce)

            return TripPoint(
                timestamp: p.timestamp,
                lat: p.lat,
                lng: p.lng,
                fusedAlt: p.fusedAlt,
                speed: p.speed,
                heading: p.heading,
                roughness: motionSnapshot.roughness,
                pitch: motionSnapshot.pitch,
                roll: motionSnapshot.roll,
                gForce: motionSnapshot.gForce,
                gradePercent: gradePercent
            )
        }

        // Store weather snapshot if available
        if let weather = weatherManager.currentWeather {
            t.weatherSnapshots.append(weather)
        }

        // Get camp sites associated with this trip
        t.campSites = campStore.getSitesForTrip(tripID: t.id)

        // Update telemetry stats
        t.telemetryStats.maxPitch = maxPitch
        t.telemetryStats.maxRoll = maxRoll
        t.telemetryStats.maxGForce = maxGForce

        // Calculate difficulty ratings
        t.difficultyRatings = DifficultyCalculator.calculate(for: t)

        // Check for "100 Club" achievement
        if t.difficultyRatings.suttonScore >= 100 {
            showingEasterEgg = true
            HapticManager.shared.success()
        }

        return t
    }

    // MARK: - Trip Completion

    func completeTrip() async -> Trip {
        let completedTrip = buildTrip()

        // Save to store
        tripStore.add(completedTrip)
        tripStore.clearTempTrip()

        // Haptic feedback
        HapticManager.shared.heavy()

        print("✅ Trip completed: \(completedTrip.title)")
        print("   - Distance: \(String(format: "%.2f", completedTrip.totalDistanceKm)) km")
        print("   - Duration: \(completedTrip.formattedDuration)")
        print("   - Sutton Score: \(completedTrip.difficultyRatings.suttonScore)/100")

        return completedTrip
    }

    // MARK: - Map Updates

    func shouldUpdateMap(lastUpdate: Date) -> Bool {
        return Date().timeIntervalSince(lastUpdate) >= mapUpdateThrottle
    }
}
