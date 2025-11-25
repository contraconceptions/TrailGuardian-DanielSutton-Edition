import Foundation
import Contacts

struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    var name: String
    var phoneNumber: String
    var relationship: String
    var isPrimary: Bool
    
    init(id: UUID = UUID(), name: String, phoneNumber: String, relationship: String = "", isPrimary: Bool = false) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.isPrimary = isPrimary
    }
}

struct EmergencyKit: Codable {
    var contacts: [EmergencyContact] = []
    var personalInfo: PersonalInfo?
    var medicalInfo: MedicalInfo?
    
    struct PersonalInfo: Codable {
        var name: String
        var dateOfBirth: Date?
        var bloodType: String?
        var allergies: [String] = []
        var medications: [String] = []
    }
    
    struct MedicalInfo: Codable {
        var conditions: [String] = []
        var doctorName: String?
        var doctorPhone: String?
        var insuranceInfo: String?
    }
}

class EmergencyKitStore: ObservableObject {
    static let shared = EmergencyKitStore()
    @Published var kit: EmergencyKit = EmergencyKit()
    
    private let saveURL: URL
    
    private init() {
        let fm = FileManager.default
        saveURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("emergencykit.json")
        load()
    }
    
    func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(kit)
            try data.write(to: saveURL, options: [.atomic])
        } catch {
            print("Failed to save emergency kit: \(error.localizedDescription)")
        }
    }
    
    private func load() {
        guard FileManager.default.fileExists(atPath: saveURL.path) else {
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let data = try Data(contentsOf: saveURL)
            kit = try decoder.decode(EmergencyKit.self, from: data)
        } catch {
            print("Failed to load emergency kit: \(error.localizedDescription)")
        }
    }
}

