import SwiftUI
import MapKit

struct TrackView: View {
    @ObservedObject var gps = GPSManager.shared
    @ObservedObject var motion = MotionManager.shared
    @ObservedObject var mapMgr = TrailMapManager.shared
    @State private var region = MKCoordinateRegion()
    @State private var trip = Trip.new()
    @State private var showingEasterEgg = false
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, showsUserLocation: true, mapType: mapMgr.mapType) {
                // Polyline for trail
                let coords = gps.trailPoints.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng) }
                if !coords.isEmpty {
                    MapPolyline(coordinates: coords)
                        .stroke(Color.orange, lineWidth: 4)
                }
            }
            .onReceive(gps.$currentLocation) { loc in
                if let loc = loc {
                    region = MKCoordinateRegion(center: loc.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    AltitudeFusionEngine.shared.update(with: loc.altitude, baroAlt: BarometerManager.shared.baroAltitude)
                }
            }
            
            // Telemetry Dashboard
            VStack {
                Text("True Elevation: \(AltitudeFusionEngine.shared.fusedAltitude, specifier: "%.0f") m")
                Text("Speed: \( (gps.currentLocation?.speed ?? 0) * 3.6 , specifier: "%.1f") km/h") // Convert m/s to km/h
                Text("Pitch/Roll: \(motion.pitch, specifier: "%.0f")° / \(motion.roll, specifier: "%.0f")°")
                Text("G-Force: \(motion.gForce, specifier: "%.2f")")
                Text("Roughness: \(motion.roughness, specifier: "%.3f")")
                if motion.isAirborne {
                    Text("AIRBORNE!").foregroundColor(.red)
                }
            }
            .padding()
            
            // End button
            NavigationLink(destination: EndSummaryView(trip: buildTrip())) {
                Text("End Trail")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .onAppear {
            trip = Trip.new()
            gps.start()
            motion.start()
            BarometerManager.shared.start()
            Task { 
                await WeatherManager.shared.fetchCurrent(at: gps.currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
            }
        }
        .onDisappear {
            gps.stop()
            motion.stop()
            BarometerManager.shared.stop()
        }
        .onShake { 
            showingEasterEgg = true
        }
        .alert("Rough Terrain Master!", isPresented: $showingEasterEgg) {
            Button("Legend") { }
        } message: {
            Text("Daniel Sutton – Certified Trail Legend")
        }
    }
    
    func buildTrip() -> Trip {
        var t = trip
        t.endedAt = Date()
        let firstAlt = gps.trailPoints.first?.fusedAlt ?? 0
        t.points = gps.trailPoints.enumerated().map { index, p in
            TripPoint(
                timestamp: p.timestamp,
                lat: p.lat,
                lng: p.lng,
                fusedAlt: AltitudeFusionEngine.shared.fusedAltitude,
                speed: p.speed,
                heading: p.heading,
                roughness: motion.roughness,
                pitch: motion.pitch,
                roll: motion.roll,
                gForce: motion.gForce,
                gradePercent: ((AltitudeFusionEngine.shared.fusedAltitude - firstAlt) / Double(index + 1)) * 100
            )
        }
        t.telemetryStats.maxPitch = motion.pitch
        t.telemetryStats.maxRoll = motion.roll
        t.telemetryStats.maxGForce = motion.gForce
        t.difficultyRatings = DifficultyCalculator.calculate(for: t)
        return t
    }
}

// Shake gesture (simplified - full impl in production would use CoreMotion)
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.onAppear {
            // Placeholder: In full app, hook to MotionManager for shake detection
            action() // Trigger on appear for demo
        }
    }
}