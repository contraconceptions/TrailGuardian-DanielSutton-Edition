import CoreMotion

class BarometerManager: ObservableObject {
    static let shared = BarometerManager()
    private let altimeter = CMAltimeter()
    
    @Published var baroAltitude: Double = 0
    @Published var isAvailable: Bool = false
    
    private init() {
        isAvailable = CMAltimeter.isRelativeAltitudeAvailable()
    }
    
    func start() {
        guard isAvailable else {
            print("Barometer not available on this device")
            return
        }
        
        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            guard let self = self else { return }
            if let error = error {
                print("Barometer error: \(error.localizedDescription)")
                return
            }
            if let altitude = data?.relativeAltitude {
                self.baroAltitude = altitude.doubleValue
                // GPS altitude will be provided separately by GPSManager
            }
        }
    }
    
    func stop() {
        altimeter.stopRelativeAltitudeUpdates()
    }
}