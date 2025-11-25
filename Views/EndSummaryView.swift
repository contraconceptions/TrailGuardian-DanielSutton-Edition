import SwiftUI
import Charts

struct EndSummaryView: View {
    @ObservedObject var store = TripStore.shared
    let trip: Trip
    @State private var mapSnapshot: UIImage?
    @State private var pdfData: Data?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Trail Complete!")
                    .font(.largeTitle)
                
                RouteMapView(points: trip.points)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .onAppear {
                        // Snapshot map for PDF (simplified)
                        mapSnapshot = UIImage(systemName: "map")?.withTintColor(.orange, renderingMode: .alwaysOriginal)
                    }
                
                // Difficulty Badges
                VStack(alignment: .leading) {
                    Text("Ratings")
                        .font(.headline)
                    Text("Sutton Score: \(trip.difficultyRatings.suttonScore)/100")
                    Text("Jeep Badge: \(trip.difficultyRatings.jeepBadge)/10")
                    Text("Wells: \(trip.difficultyRatings.wellsRating)")
                    Text("USFS: \(trip.difficultyRatings.usfsRating)")
                    Text("International: \(trip.difficultyRatings.international)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
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
                    store.add(trip)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Export PDF") {
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
                }
                .buttonStyle(.bordered)
                
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
    }
}