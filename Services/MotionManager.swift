import Foundation
import CoreMotion

struct MotionSnapshot: Identifiable {
    let id = UUID()
    let timestamp: Date
    let roughness: Double
    let pitch: Double
    let roll: Double
    let gForce: Double
    let isAirborne: Bool
}

class MotionManager: ObservableObject {
    static let shared = MotionManager()
    private let motion = CMMotionManager()
    private let queue = DispatchQueue(label: "com.trailguardian.motion", qos: .userInitiated)
    
    @Published var roughness: Double = 0
    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    @Published var gForce: Double = 0
    @Published var isAirborne = false
    
    // Historical snapshots for trip reconstruction
    private(set) var snapshots: [MotionSnapshot] = []
    private let maxSnapshots = 10000 // Prevent unbounded growth
    
    private init() {
        motion.accelerometerUpdateInterval = 0.1
        motion.deviceMotionUpdateInterval = 0.1
    }
    
    func start() {
        motion.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: queue) { [weak self] data, _ in
            guard let self = self, let data = data else { return }
            
            let attitude = data.attitude
            let pitch = attitude.pitch * 180 / .pi
            let roll = attitude.roll * 180 / .pi
            
            let accel = data.userAcceleration
            let totalG = sqrt(accel.x*accel.x + accel.y*accel.y + accel.z*accel.z)
            let isAirborne = totalG < 0.3
            
            DispatchQueue.main.async {
                self.pitch = pitch
                self.roll = roll
                self.gForce = totalG
                self.isAirborne = isAirborne
            }
        }
        
        motion.startAccelerometerUpdates(to: queue) { [weak self] data, _ in
            guard let self = self, let accel = data?.acceleration else { return }
            let rms = sqrt(accel.x*accel.x + accel.y*accel.y + accel.z*accel.z)
            
            DispatchQueue.main.async {
                self.roughness = rms
                
                // Store snapshot for historical reconstruction
                let snapshot = MotionSnapshot(
                    timestamp: Date(),
                    roughness: rms,
                    pitch: self.pitch,
                    roll: self.roll,
                    gForce: self.gForce,
                    isAirborne: self.isAirborne
                )
                self.snapshots.append(snapshot)
                
                // Prevent unbounded growth
                if self.snapshots.count > self.maxSnapshots {
                    self.snapshots.removeFirst(self.snapshots.count - self.maxSnapshots)
                }
            }
        }
    }
    
    func stop() {
        motion.stopDeviceMotionUpdates()
        motion.stopAccelerometerUpdates()
    }
    
    func clearSnapshots() {
        snapshots.removeAll()
    }
    
    func getSnapshot(nearestTo timestamp: Date) -> MotionSnapshot? {
        return snapshots.min(by: { abs($0.timestamp.timeIntervalSince(timestamp)) < abs($1.timestamp.timeIntervalSince(timestamp)) })
    }
}