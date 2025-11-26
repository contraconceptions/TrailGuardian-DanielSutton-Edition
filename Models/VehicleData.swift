import Foundation

struct VehicleData: Codable {
    var vehicleType: VehicleType = .bronco
    var terrainMode: BroncoTerrainMode?
    var driveMode: DriveMode?
    var frontLockerEngaged: Bool = false
    var rearLockerEngaged: Bool = false
    var swayBarDisconnected: Bool = false
    var trailControlActive: Bool = false
    var trailTurnAssistActive: Bool = false
    var winchUsed: Bool = false
    var tirePressure: [Double]? // Front left, front right, rear left, rear right (PSI)
    var fuelLevel: Double? // Percentage 0-100
    var engineRPM: Double? // From OBD-II or FordPass (future)
    var throttlePosition: Double? // From OBD-II (future)
    
    // Integration source tracking
    var dataSource: DataSource = .manual
    
    enum DataSource: String, Codable {
        case manual = "Manual Entry"
        case fordPass = "FordPass API"
        case obd2 = "OBD-II Adapter"
    }
}

enum VehicleType: String, Codable, CaseIterable {
    case bronco = "Ford Bronco"
    case jeepWrangler = "Jeep Wrangler"
    case jeepGladiator = "Jeep Gladiator"
    case toyota4Runner = "Toyota 4Runner"
    case toyotaTacoma = "Toyota Tacoma"
    case chevyColorado = "Chevy Colorado/ZR2"
    case fordRanger = "Ford Ranger"
    case nissanFrontier = "Nissan Frontier"
    case ram1500 = "Ram 1500 TRX/Rebel"
    case landRoverDefender = "Land Rover Defender"
    case other = "Other"
}

enum BroncoTerrainMode: String, Codable, CaseIterable {
    case normal = "Normal"
    case eco = "Eco"
    case sport = "Sport"
    case slippery = "Slippery"
    case sandMud = "Sand/Mud"
    case rockCrawl = "Rock Crawl"
    case baja = "Baja"
}

enum DriveMode: String, Codable, CaseIterable {
    case twoWD = "2WD"
    case fourWDAuto = "4WD Auto"
    case fourWDHigh = "4WD High"
    case fourWDLow = "4WD Low"
}

