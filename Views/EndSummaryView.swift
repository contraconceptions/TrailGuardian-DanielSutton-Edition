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
                    if let image = mapSnapshot {
                        pdfData = PDFExporter.generatePDF(for: trip, mapSnapshot: image)
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