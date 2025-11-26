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
                
                Section {
                    TextField("Camp Site Name", text: $name)
                        .accessibilityLabel("Camp site name")
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                        .accessibilityLabel("Camp site description")
                } header: {
                    Label("Basic Info", systemImage: "info.circle")
                }

                Section {
                    PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 10, matching: .images) {
                        HStack {
                            Image(systemName: DesignSystem.Icons.photo)
                                .foregroundColor(.blue)
                            Text("Add Photos")
                            Spacer()
                            if !photoData.isEmpty {
                                StatusBadge("\(photoData.count)", color: .blue)
                            }
                        }
                    }
                    .onChange(of: selectedPhotos) { items in
                        Task {
                            photoData = []
                            for item in items {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    photoData.append(data)
                                }
                            }
                            HapticManager.shared.success()
                        }
                    }
                    .accessibilityLabel("Add photos, \(photoData.count) selected")

                    if !photoData.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                ForEach(Array(photoData.enumerated()), id: \.offset) { index, data in
                                    if let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(DesignSystem.CornerRadius.sm)
                                            .clipped()
                                            .overlay(
                                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                            )
                                            .accessibilityLabel("Photo \(index + 1)")
                                    }
                                }
                            }
                            .padding(.vertical, DesignSystem.Spacing.xxs)
                        }
                    }
                } header: {
                    Label("Photos (Optional)", systemImage: DesignSystem.Icons.photo)
                } footer: {
                    if !photoData.isEmpty {
                        Text("Photos will be compressed to save storage space")
                            .font(.caption2)
                    }
                }
                
                Section {
                    Toggle(isOn: $hasFireRing) {
                        Label("Has Fire Ring", systemImage: "flame")
                    }
                    .accessibilityLabel("Toggle fire ring availability")

                    Button {
                        HapticManager.shared.light()
                        showingWaterSource = true
                    } label: {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            Text("Add Water Source")
                            Spacer()
                        }
                    }

                    if let water = waterSource {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(water.type.rawValue)
                                    .font(.body)
                                Text("\(Int(water.distance))m away")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button {
                                waterSource = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .accessibilityLabel("Water source: \(water.type.rawValue), \(Int(water.distance)) meters away")
                    }

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Label("Wildlife Sightings", systemImage: "pawprint.fill")
                            .font(.headline)
                            .foregroundColor(.primary)

                        HStack {
                            TextField("e.g., Deer, Bear", text: $newWildlife)
                            Button {
                                if !newWildlife.isEmpty {
                                    wildlifeSightings.append(newWildlife)
                                    newWildlife = ""
                                    HapticManager.shared.light()
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .disabled(newWildlife.isEmpty)
                        }

                        ForEach(wildlifeSightings, id: \.self) { wildlife in
                            HStack {
                                Image(systemName: "pawprint")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(wildlife)
                                Spacer()
                                Button {
                                    wildlifeSightings.removeAll { $0 == wildlife }
                                    HapticManager.shared.light()
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }

                    Stepper(value: $accessibilityRating, in: 1...5) {
                        HStack {
                            Label("Accessibility", systemImage: "car.fill")
                            Spacer()
                            Text("\(accessibilityRating)/5")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Label("Features", systemImage: "star.fill")
                }
                
                Section {
                    TextField("e.g., Rocky, Sandy, Forest", text: $terrainType)
                        .accessibilityLabel("Terrain type")
                    TextField("e.g., Level, Soft, Muddy", text: $groundConditions)
                        .accessibilityLabel("Ground conditions")
                } header: {
                    Label("Conditions", systemImage: "leaf.fill")
                }

                Section {
                    Stepper(value: $starRating, in: 1...5) {
                        HStack {
                            Label("Overall Rating", systemImage: "star.fill")
                            Spacer()
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { index in
                                    Image(systemName: index <= starRating ? "star.fill" : "star")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .accessibilityLabel("Overall rating: \(starRating) out of 5 stars")

                    Stepper(value: $difficultyToReach, in: 1...5) {
                        HStack {
                            Label("Difficulty", systemImage: DesignSystem.Icons.difficulty)
                            Spacer()
                            Text("\(difficultyToReach)/5")
                                .foregroundColor(.secondary)
                        }
                    }

                    Stepper(value: $privacyLevel, in: 1...5) {
                        HStack {
                            Label("Privacy", systemImage: "eye.slash.fill")
                            Spacer()
                            Text("\(privacyLevel)/5")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Label("Ratings", systemImage: "star.fill")
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
                        HapticManager.shared.light()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.success()
                        saveCampSite()
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.xxs) {
                            Image(systemName: DesignSystem.Icons.save)
                            Text("Save")
                        }
                        .fontWeight(.semibold)
                    }
                    .disabled(name.isEmpty)
                    .accessibilityLabel("Save camp site")
                    .accessibilityHint(name.isEmpty ? "Enter a name to save" : "")
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
        // Save photos to documents directory with compression
        var photoPaths: [String] = []

        for data in photoData {
            // Compress photo before saving
            if let compressedData = PhotoHelper.compressPhoto(data),
               let filename = PhotoHelper.savePhoto(compressedData) {
                photoPaths.append(filename)
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

