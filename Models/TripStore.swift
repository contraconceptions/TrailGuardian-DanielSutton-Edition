import Foundation

class TripStore: ObservableObject {
    static let shared = TripStore()
    @Published var trips: [Trip] = []
    @Published var lastError: String?

    private let saveURL: URL
    private let tempSaveURL: URL

    private init() {
        let fm = FileManager.default
        let docsDir = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        saveURL = docsDir.appendingPathComponent("trips.json")
        tempSaveURL = docsDir.appendingPathComponent(Constants.AutoSave.tempTripFilename)
        load()
    }

    func add(_ trip: Trip) {
        trips.insert(trip, at: 0)
        save()
    }

    func delete(_ trip: Trip) {
        trips.removeAll { $0.id == trip.id }
        save()
    }

    func delete(at offsets: IndexSet) {
        trips.remove(atOffsets: offsets)
        save()
    }

    /// Save temporary trip data during active tracking
    func saveTempTrip(_ trip: Trip) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(trip)
            try data.write(to: tempSaveURL, options: [.atomic])
        } catch {
            print("Failed to save temp trip: \(error.localizedDescription)")
        }
    }

    /// Load temporary trip data after crash recovery
    func loadTempTrip() -> Trip? {
        guard FileManager.default.fileExists(atPath: tempSaveURL.path) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let data = try Data(contentsOf: tempSaveURL)
            return try decoder.decode(Trip.self, from: data)
        } catch {
            print("Failed to load temp trip: \(error.localizedDescription)")
            return nil
        }
    }

    /// Clear temporary trip data after successful save
    func clearTempTrip() {
        try? FileManager.default.removeItem(at: tempSaveURL)
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(trips)
            try data.write(to: saveURL, options: [.atomic])
            lastError = nil
        } catch {
            lastError = "Failed to save trips: \(error.localizedDescription)"
            print(lastError ?? "")
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
            lastError = nil
        } catch {
            lastError = "Failed to load trips: \(error.localizedDescription)"
            print(lastError ?? "")
            trips = []
        }
    }
}