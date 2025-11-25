import CoreMotion
import Combine

class AltitudeFusionEngine: ObservableObject {
    static let shared = AltitudeFusionEngine()
    private var gpsAltitudes: [Double] = []
    private var baroAltitudes: [Double] = []
    
    @Published var fusedAltitude: Double = 0
    
    func update(with gpsAlt: Double, baroAlt: Double) {
        gpsAltitudes.append(gpsAlt)
        baroAltitudes.append(baroAlt)
        if gpsAltitudes.count > 10 { gpsAltitudes.removeFirst() }
        if baroAltitudes.count > 10 { baroAltitudes.removeFirst() }
        
        // Simple Kalman-like fusion: weighted average
        let gpsMean = gpsAltitudes.reduce(0, +) / Double(gpsAltitudes.count)
        let baroMean = baroAltitudes.reduce(0, +) / Double(baroAltitudes.count)
        fusedAltitude = (gpsMean * 0.3) + (baroMean * 0.7) // Favor baro for precision
    }
}