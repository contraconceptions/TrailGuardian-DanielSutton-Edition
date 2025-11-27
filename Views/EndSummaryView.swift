import SwiftUI
import Charts

struct EndSummaryView: View {
    @ObservedObject var store = TripStore.shared
    let trip: Trip
    @State private var mapSnapshot: UIImage?
    @State private var pdfData: Data?
    @State private var editedTrip: Trip
    @State private var showingNameEditor = false
    @State private var isGeneratingPDF = false

    init(trip: Trip) {
        self.trip = trip
        _editedTrip = State(initialValue: trip)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Trail Complete!")
                    .font(.largeTitle)

                // Trip Name with Edit Button
                HStack {
                    Text(editedTrip.title)
                        .font(.title2.bold())
                    Button {
                        showingNameEditor = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)

                RouteMapView(points: trip.points)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .onAppear {
                        // Snapshot map for PDF (simplified)
                        mapSnapshot = UIImage(systemName: "map")?.withTintColor(.orange, renderingMode: .alwaysOriginal)
                    }
                
                // Difficulty Badges
                VStack(alignment: .leading, spacing: 12) {
                    Text("Difficulty Ratings")
                        .font(.headline)

                    // Sutton Score - Large Badge
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sutton Score")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(trip.difficultyRatings.suttonScore)")
                                    .font(.system(size: 42, weight: .bold))
                                    .foregroundColor(DifficultyColorHelper.colorForScore(trip.difficultyRatings.suttonScore))
                                Text("/100")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            Text(DifficultyColorHelper.descriptionForScore(trip.difficultyRatings.suttonScore))
                                .font(.subheadline.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(DifficultyColorHelper.backgroundColorForScore(trip.difficultyRatings.suttonScore))
                                .foregroundColor(DifficultyColorHelper.colorForScore(trip.difficultyRatings.suttonScore))
                                .cornerRadius(6)
                        }
                        Spacer()
                    }

                    Divider()

                    // Other Rating Systems
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Jeep Badge:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(trip.difficultyRatings.jeepBadge)/10")
                                .bold()
                        }
                        HStack {
                            Text("Wells Rating:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(trip.difficultyRatings.wellsRating)
                                .bold()
                        }
                        HStack {
                            Text("USFS Rating:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(trip.difficultyRatings.usfsRating)
                                .bold()
                        }
                        HStack {
                            Text("International:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(trip.difficultyRatings.international)
                                .bold()
                        }
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(DifficultyColorHelper.backgroundColorForScore(trip.difficultyRatings.suttonScore))
                .cornerRadius(12)
                
                // Bronco Configuration
                if trip.vehicleData.vehicleType == .bronco {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "car.fill")
                                .foregroundColor(.blue)
                            Text("Bronco Configuration")
                                .font(.headline)
                        }
                        
                        if let mode = trip.vehicleData.terrainMode {
                            HStack {
                                Text("Terrain Mode:")
                                Spacer()
                                Text(mode.rawValue)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let drive = trip.vehicleData.driveMode {
                            HStack {
                                Text("Drive Mode:")
                                Spacer()
                                Text(drive.rawValue)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if trip.vehicleData.frontLockerEngaged || trip.vehicleData.rearLockerEngaged {
                            HStack {
                                Text("Lockers:")
                                Spacer()
                                Text("\(trip.vehicleData.frontLockerEngaged ? "Front " : "")\(trip.vehicleData.rearLockerEngaged ? "Rear" : "")")
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        if trip.vehicleData.swayBarDisconnected {
                            HStack {
                                Text("Sway Bar:")
                                Spacer()
                                Text("Disconnected")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if trip.vehicleData.trailControlActive {
                            HStack {
                                Text("Trail Control:")
                                Spacer()
                                Text("Active")
                                    .foregroundColor(.green)
                            }
                        }
                        
                        if trip.vehicleData.winchUsed {
                            HStack {
                                Text("Winch:")
                                Spacer()
                                Text("Used")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        if let fuel = trip.vehicleData.fuelLevel {
                            HStack {
                                Text("Fuel Level:")
                                Spacer()
                                Text("\(Int(fuel))%")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("Data Source:")
                            Spacer()
                            Text(trip.vehicleData.dataSource.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Camp Sites
                if !trip.campSites.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Camp Sites")
                            .font(.headline)
                        ForEach(trip.campSites) { site in
                            NavigationLink(destination: CampSiteDetailView(campSite: site)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(site.name)
                                        .font(.subheadline.bold())
                                    HStack {
                                        ForEach(0..<site.starRating, id: \.self) { _ in
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                                .font(.caption)
                                        }
                                    }
                                    Text(site.timestamp.formatted(date: .omitted, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                }
                
                // Elevation Profile
                if !trip.points.isEmpty {
                    Chart {
                        ForEach(Array(trip.points.enumerated()), id: \.offset) { index, point in
                            LineMark(
                                x: .value("Time", index),
                                y: .value("Elevation", point.fusedAlt)
                            )
                        }
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                }
                
                Button("Save Trip") {
                    store.add(editedTrip)
                    // Clear temp trip file to prevent false crash recovery
                    store.clearTempTrip()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Export PDF") {
                    isGeneratingPDF = true
                    Task {
                        if let image = mapSnapshot, let pdf = PDFExporter.generatePDF(for: trip, mapSnapshot: image) {
                            pdfData = pdf
                        } else {
                            // Fallback: create a simple placeholder image if map snapshot failed
                            let placeholder = UIImage(systemName: "map")?.withTintColor(.orange, renderingMode: .alwaysOriginal) ?? UIImage()
                            if let fallbackPdf = PDFExporter.generatePDF(for: trip, mapSnapshot: placeholder) {
                                pdfData = fallbackPdf
                            } else {
                                // If PDF generation completely fails, show error or handle gracefully
                                print("PDF generation failed even with fallback image")
                            }
                        }
                        isGeneratingPDF = false
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isGeneratingPDF)

                if isGeneratingPDF {
                    HStack {
                        ProgressView()
                        Text("Generating PDF...")
                            .foregroundColor(.secondary)
                    }
                }
                
                if let data = pdfData {
                    ShareLink("Share PDF", item: data, preview: .init("Daniel's Trail Summary"))
                }
                
                // Easter egg for high score
                if trip.difficultyRatings.suttonScore > 95 {
                    Text("🎉 100 CLUB UNLOCKED! 🎉 Daniel Sutton – Only 7 Humans in History")
                        .font(.title)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
        .navigationTitle(trip.title)
        .sheet(isPresented: $showingNameEditor) {
            NavigationView {
                Form {
                    TextField("Trail Name", text: $editedTrip.title)
                }
                .navigationTitle("Edit Trail Name")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            editedTrip.title = trip.title
                            showingNameEditor = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingNameEditor = false
                        }
                        .disabled(editedTrip.title.isEmpty)
                    }
                }
            }
        }
    }
}