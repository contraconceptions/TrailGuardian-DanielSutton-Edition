import CoreMotion

class BarometerManager: ObservableObject {
    static let shared = BarometerManager()
    private let motion = CMMotionManager()
    
    @Published var baroAltitude: Double = 0
    
    func start() {
        motion.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main) { data, _ in
            self.baroAltitude = data?.altitude ?? 0
            AltitudeFusionEngine.shared.update(with: 0, baroAlt: self.baroAltitude) // GPS from elsewhere
        }
    }
    
    func stop() {
        motion.stopDeviceMotionUpdates()
    }
}