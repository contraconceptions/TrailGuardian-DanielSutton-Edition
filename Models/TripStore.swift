import Foundation

class TripStore: ObservableObject {
    static let shared = TripStore()
    @Published var trips: [Trip] = []
    
    private let saveURL: URL
    
    private init() {
        let fm = FileManager.default
        saveURL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("trips.json")
        load()
    }
    
    func add(_ trip: Trip) {
        trips.insert(trip, at: 0)
        save()
    }
    
    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(trips)
            try data.write(to: saveURL, options: [.atomic])
        } catch {
            print("Failed to save trips: \(error.localizedDescription)")
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
            trips = try decoder.decode([Trip].self, from: data)
        } catch {
            print("Failed to load trips: \(error.localizedDescription)")
            trips = []
        }
    }
}