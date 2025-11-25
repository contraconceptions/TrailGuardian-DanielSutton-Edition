import Foundation
import CoreMotion

class MotionManager: ObservableObject {
    static let shared = MotionManager()
    private let motion = CMMotionManager()
    
    @Published var roughness: Double = 0
    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    @Published var gForce: Double = 0
    @Published var isAirborne = false
    
    private init() {
        motion.accelerometerUpdateInterval = 0.1
        motion.deviceMotionUpdateInterval = 0.1
    }
    
    func start() {
        motion.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: .main) { data, _ in
            guard let attitude = data?.attitude else { return }
            self.pitch = attitude.pitch * 180 / .pi
            self.roll = attitude.roll * 180 / .pi
            
            guard let accel = data?.userAcceleration else { return }
            let totalG = sqrt(accel.x*accel.x + accel.y*accel.y + accel.z*accel.z)
            self.gForce = totalG
            self.isAirborne = totalG < 0.3 // Airtime detection
        }
        
        motion.startAccelerometerUpdates(to: .main) { data, _ in
            guard let accel = data?.acceleration else { return }
            let rms = sqrt(accel.x*accel.x + accel.y*accel.y + accel.z*accel.z)
            self.roughness = rms
        }
    }
    
    func stop() {
        motion.stopDeviceMotionUpdates()
        motion.stopAccelerometerUpdates()
    }
}