import CoreMotion
import Combine

class AltitudeFusionEngine: ObservableObject {
    static let shared = AltitudeFusionEngine()
    private let queue = DispatchQueue(label: "com.trailguardian.altitude", qos: .userInitiated)
    private var gpsAltitudes: [Double] = []
    private var baroAltitudes: [Double] = []
    private var baseBaroAltitude: Double = 0 // Reference point for relative altitude
    
    @Published var fusedAltitude: Double = 0
    
    private init() {
        // Initialize with a default value
        fusedAltitude = 0
    }
    
    func update(with gpsAlt: Double, baroAlt: Double) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // Handle first barometric reading as baseline
            if self.baseBaroAltitude == 0 && baroAlt != 0 {
                self.baseBaroAltitude = baroAlt
            }
            
            // Only use valid altitude values (> -500m, < 9000m)
            let validGPS = gpsAlt > -500 && gpsAlt < 9000 ? gpsAlt : nil
            let validBaro = baroAlt != 0 ? (self.baseBaroAltitude + baroAlt) : nil
            
            if let gps = validGPS {
                self.gpsAltitudes.append(gps)
                if self.gpsAltitudes.count > 10 {
                    self.gpsAltitudes.removeFirst()
                }
            }
            
            if let baro = validBaro {
                self.baroAltitudes.append(baro)
                if self.baroAltitudes.count > 10 {
                    self.baroAltitudes.removeFirst()
                }
            }
            
            // Calculate fused altitude
            var newFused: Double = 0
            
            if !self.gpsAltitudes.isEmpty && !self.baroAltitudes.isEmpty {
                // Both available: weighted average (favor baro for precision)
                let gpsMean = self.gpsAltitudes.reduce(0, +) / Double(self.gpsAltitudes.count)
                let baroMean = self.baroAltitudes.reduce(0, +) / Double(self.baroAltitudes.count)
                newFused = (gpsMean * 0.3) + (baroMean * 0.7)
            } else if !self.gpsAltitudes.isEmpty {
                // Only GPS available
                newFused = self.gpsAltitudes.reduce(0, +) / Double(self.gpsAltitudes.count)
            } else if !self.baroAltitudes.isEmpty {
                // Only baro available
                newFused = self.baroAltitudes.reduce(0, +) / Double(self.baroAltitudes.count)
            } else {
                // Fallback to GPS if provided
                newFused = validGPS ?? self.fusedAltitude
            }
            
            DispatchQueue.main.async {
                self.fusedAltitude = newFused
            }
        }
    }
    
    func reset() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.gpsAltitudes.removeAll()
            self.baroAltitudes.removeAll()
            self.baseBaroAltitude = 0
            DispatchQueue.main.async {
                self.fusedAltitude = 0
            }
        }
    }
}