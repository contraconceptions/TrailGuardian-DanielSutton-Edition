import CoreMotion
import Combine

/// Fuses GPS and barometric altitude data for more accurate elevation tracking
/// Thread-safe singleton using serial dispatch queue
class AltitudeFusionEngine: ObservableObject {
    static let shared = AltitudeFusionEngine()
    private let queue = DispatchQueue(label: "com.trailguardian.altitude", qos: .userInitiated)

    // Moving average buffers
    private var gpsAltitudes: [Double] = []
    private var baroAltitudes: [Double] = []

    // Barometric baseline calibration
    private var baseBaroAltitude: Double = 0
    private var isBaseBaroInitialized: Bool = false

    @Published var fusedAltitude: Double = 0

    // Altitude validation bounds (meters)
    private let minValidAltitude: Double = -500  // Dead Sea is ~-430m
    private let maxValidAltitude: Double = 9000  // Everest is ~8850m

    private init() {
        fusedAltitude = 0
    }

    /// Update the fusion engine with new GPS and barometric readings
    /// - Parameters:
    ///   - gpsAlt: GPS altitude in meters
    ///   - baroAlt: Barometric altitude in meters (relative to sea level)
    func update(with gpsAlt: Double, baroAlt: Double) {
        queue.async { [weak self] in
            guard let self = self else { return }

            // Validate inputs are finite numbers
            guard gpsAlt.isFinite && baroAlt.isFinite else {
                print("⚠️ AltitudeFusion: Received non-finite altitude values")
                return
            }

            // Initialize barometric baseline on first valid reading
            if !self.isBaseBaroInitialized && baroAlt != 0 {
                self.baseBaroAltitude = baroAlt
                self.isBaseBaroInitialized = true
            }

            // Validate altitude ranges (filter out impossible values)
            let validGPS = self.isValidAltitude(gpsAlt) ? gpsAlt : nil
            let validBaro = baroAlt != 0 ? (self.baseBaroAltitude + baroAlt) : nil

            // Add to moving average buffers
            if let gps = validGPS {
                self.appendToBuffer(&self.gpsAltitudes, value: gps)
            }

            if let baro = validBaro, self.isValidAltitude(baro) {
                self.appendToBuffer(&self.baroAltitudes, value: baro)
            }

            // Calculate fused altitude with weighted average
            let newFused = self.calculateFusedAltitude(fallbackGPS: validGPS)

            // Update published value on main thread
            DispatchQueue.main.async {
                self.fusedAltitude = newFused
            }
        }
    }

    /// Reset the fusion engine (call when starting a new trip)
    func reset() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.gpsAltitudes.removeAll()
            self.baroAltitudes.removeAll()
            self.baseBaroAltitude = 0
            self.isBaseBaroInitialized = false

            DispatchQueue.main.async {
                self.fusedAltitude = 0
            }
        }
    }

    // MARK: - Private Helpers

    /// Validate altitude is within reasonable bounds
    private func isValidAltitude(_ altitude: Double) -> Bool {
        return altitude > minValidAltitude && altitude < maxValidAltitude && altitude.isFinite
    }

    /// Append value to buffer with size limit (moving average window)
    private func appendToBuffer(_ buffer: inout [Double], value: Double) {
        buffer.append(value)
        if buffer.count > Constants.Altitude.movingAverageWindow {
            buffer.removeFirst()
        }
    }

    /// Calculate weighted average of GPS and barometric data
    private func calculateFusedAltitude(fallbackGPS: Double?) -> Double {
        if !gpsAltitudes.isEmpty && !baroAltitudes.isEmpty {
            // Both available: weighted average (favor barometer for precision)
            let gpsMean = gpsAltitudes.reduce(0, +) / Double(gpsAltitudes.count)
            let baroMean = baroAltitudes.reduce(0, +) / Double(baroAltitudes.count)
            return (gpsMean * Constants.Altitude.gpsWeight) + (baroMean * Constants.Altitude.barometerWeight)

        } else if !gpsAltitudes.isEmpty {
            // Only GPS available
            return gpsAltitudes.reduce(0, +) / Double(gpsAltitudes.count)

        } else if !baroAltitudes.isEmpty {
            // Only barometer available
            return baroAltitudes.reduce(0, +) / Double(baroAltitudes.count)

        } else {
            // No data yet - use fallback or keep current
            return fallbackGPS ?? fusedAltitude
        }
    }
}