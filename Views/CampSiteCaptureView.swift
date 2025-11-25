import SwiftUI
import MapKit
import PhotosUI

struct CampSiteCaptureView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store = CampSiteStore.shared
    @ObservedObject var gps = GPSManager.shared
    @StateObject private var weather = WeatherManager.shared
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var latitude: Double = 0
    @State private var longitude: Double = 0
    @State private var elevation: Double = 0
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoData: [Data] = []
    @State private var waterSource: WaterSource?
    @State private var hasFireRing: Bool = false
    @State private var wildlifeSightings: [String] = []
    @State private var newWildlife: String = ""
    @State private var accessibilityRating: Int = 3
    @State private var starRating: Int = 3
    @State private var difficultyToReach: Int = 3
    @State private var privacyLevel: Int = 3
    @State private var terrainType: String = ""
    @State private var groundConditions: String = ""
    @State private var requiredGear: [String] = []
    @State private var newRequiredGear: String = ""
    @State private var recommendedGear: [String] = []
    @State private var newRecommendedGear: String = ""
    @State private var cellService: Bool?
    @State private var nearestRoad: String = ""
    @State private var emergencyAccessNotes: String = ""
    @State private var waterDistance: Double = 0
    @State private var waterType: WaterSource.WaterSourceType = .stream
    @State private var waterPotable: Bool = false
    @State private var waterNotes: String = ""
    @State private var showingWaterSource = false
    
    var associatedTripID: UUID?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Location") {
                    HStack {
                        Text("Latitude")
                        Spacer()
                        TextField("", value: $latitude, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Longitude")
                        Spacer()
                        TextField("", value: $longitude, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Elevation (m)")
                        Spacer()
                        TextField("", value: $elevation, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Button("Use Current Location") {
                        if let loc = gps.currentLocation {
                            latitude = loc.coordinate.latitude
                            longitude = loc.coordinate.longitude
                            elevation = AltitudeFusionEngine.shared.fusedAltitude
                        }
                    }
                }
                
                Section("Basic Info") {
                    TextField("Camp Site Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Photos") {
                    PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 10, matching: .images) {
                        Label("Add Photos", systemImage: "photo")
                    }
                    .onChange(of: selectedPhotos) { items in
                        Task {
                            photoData = []
                            for item in items {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    photoData.append(data)
                                }
                            }
                        }
                    }
                    
                    if !photoData.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(Array(photoData.enumerated()), id: \.offset) { index, data in
                                    if let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section("Features") {
                    Toggle("Has Fire Ring", isOn: $hasFireRing)
                    
                    Button("Add Water Source") {
                        showingWaterSource = true
                    }
                    
                    if let water = waterSource {
                        HStack {
                            Text("Water: \(water.type.rawValue)")
                            Spacer()
                            Text("\(Int(water.distance))m away")
                                .foregroundColor(.secondary)
                        }
                        Button("Remove Water Source") {
                            waterSource = nil
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Wildlife Sightings")
                        HStack {
                            TextField("Add wildlife", text: $newWildlife)
                            Button("Add") {
                                if !newWildlife.isEmpty {
                                    wildlifeSightings.append(newWildlife)
                                    newWildlife = ""
                                }
                            }
                        }
                        ForEach(wildlifeSightings, id: \.self) { wildlife in
                            HStack {
                                Text(wildlife)
                                Spacer()
                                Button("Remove") {
                                    wildlifeSightings.removeAll { $0 == wildlife }
                                }
                            }
                        }
                    }
                    
                    Stepper("Accessibility: \(accessibilityRating)/5", value: $accessibilityRating, in: 1...5)
                }
                
                Section("Conditions") {
                    TextField("Terrain Type", text: $terrainType)
                    TextField("Ground Conditions", text: $groundConditions)
                }
                
                Section("Ratings") {
                    Stepper("Star Rating: \(starRating)/5", value: $starRating, in: 1...5)
                    Stepper("Difficulty to Reach: \(difficultyToReach)/5", value: $difficultyToReach, in: 1...5)
                    Stepper("Privacy Level: \(privacyLevel)/5", value: $privacyLevel, in: 1...5)
                }
                
                Section("Gear") {
                    VStack(alignment: .leading) {
                        Text("Required Gear")
                        HStack {
                            TextField("Add gear", text: $newRequiredGear)
                            Button("Add") {
                                if !newRequiredGear.isEmpty {
                                    requiredGear.append(newRequiredGear)
                                    newRequiredGear = ""
                                }
                            }
                        }
                        ForEach(requiredGear, id: \.self) { gear in
                            HStack {
                                Text(gear)
                                Spacer()
                                Button("Remove") {
                                    requiredGear.removeAll { $0 == gear }
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Recommended Gear")
                        HStack {
                            TextField("Add gear", text: $newRecommendedGear)
                            Button("Add") {
                                if !newRecommendedGear.isEmpty {
                                    recommendedGear.append(newRecommendedGear)
                                    newRecommendedGear = ""
                                }
                            }
                        }
                        ForEach(recommendedGear, id: \.self) { gear in
                            HStack {
                                Text(gear)
                                Spacer()
                                Button("Remove") {
                                    recommendedGear.removeAll { $0 == gear }
                                }
                            }
                        }
                    }
                }
                
                Section("Safety") {
                    Picker("Cell Service", selection: $cellService) {
                        Text("Unknown").tag(nil as Bool?)
                        Text("Yes").tag(true as Bool?)
                        Text("No").tag(false as Bool?)
                    }
                    TextField("Nearest Road", text: $nearestRoad)
                    TextField("Emergency Access Notes", text: $emergencyAccessNotes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("New Camp Site")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCampSite()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingWaterSource) {
                WaterSourceView(waterSource: $waterSource, distance: $waterDistance, type: $waterType, potable: $waterPotable, notes: $waterNotes)
            }
            .onAppear {
                // Auto-fill location
                if let loc = gps.currentLocation {
                    latitude = loc.coordinate.latitude
                    longitude = loc.coordinate.longitude
                    elevation = AltitudeFusionEngine.shared.fusedAltitude
                }
                
                // Fetch weather
                Task {
                    if let loc = gps.currentLocation {
                        await weather.fetchCurrent(at: loc.coordinate)
                    }
                }
            }
        }
    }
    
    private func saveCampSite() {
        // Save photos to documents directory
        var photoPaths: [String] = []
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosDirectory = documentsPath.appendingPathComponent("CampSitePhotos")
        
        try? fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        
        for (index, data) in photoData.enumerated() {
            let photoPath = photosDirectory.appendingPathComponent("\(UUID().uuidString)_\(index).jpg")
            if let _ = try? data.write(to: photoPath) {
                photoPaths.append(photoPath.lastPathComponent)
            }
        }
        
        let campSite = CampSite(
            name: name,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude,
            elevation: elevation,
            photos: photoPaths,
            description: description.isEmpty ? nil : description,
            waterSource: waterSource,
            hasFireRing: hasFireRing,
            wildlifeSightings: wildlifeSightings,
            accessibilityRating: accessibilityRating,
            starRating: starRating,
            difficultyToReach: difficultyToReach,
            privacyLevel: privacyLevel,
            weather: weather.currentWeather,
            terrainType: terrainType,
            groundConditions: groundConditions,
            requiredGear: requiredGear,
            recommendedGear: recommendedGear,
            cellService: cellService,
            nearestRoad: nearestRoad.isEmpty ? nil : nearestRoad,
            emergencyAccessNotes: emergencyAccessNotes.isEmpty ? nil : emergencyAccessNotes,
            associatedTripID: associatedTripID
        )
        
        store.add(campSite)
        dismiss()
    }
}

struct WaterSourceView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var waterSource: WaterSource?
    @Binding var distance: Double
    @Binding var type: WaterSource.WaterSourceType
    @Binding var potable: Bool
    @Binding var notes: String
    
    var body: some View {
        NavigationView {
            Form {
                Section("Water Source") {
                    Picker("Type", selection: $type) {
                        ForEach(WaterSource.WaterSourceType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    HStack {
                        Text("Distance (meters)")
                        Spacer()
                        TextField("", value: $distance, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Toggle("Potable", isOn: $potable)
                    
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Water Source")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        waterSource = WaterSource(
                            distance: distance,
                            type: type,
                            isPotable: potable,
                            notes: notes.isEmpty ? nil : notes
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}

