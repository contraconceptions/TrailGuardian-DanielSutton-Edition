import SwiftUI
import MapKit

struct TrackView: View {
    @ObservedObject var gps = GPSManager.shared
    @ObservedObject var motion = MotionManager.shared
    @ObservedObject var mapMgr = TrailMapManager.shared
    @StateObject private var fordPass = FordPassManager.shared
    @StateObject private var obd = OBDManager.shared
    @State private var region = MKCoordinateRegion()
    @State private var trip = Trip.new()
    @State private var showingEasterEgg = false
    @State private var showingBroncoControls = false
    @State private var showingCampSiteCapture = false
    @ObservedObject var campStore = CampSiteStore.shared
    
    var body: some View {
        VStack {
            Group {
                if #available(iOS 17.0, *) {
                    Map {
                        if !gps.trailPoints.isEmpty {
                            let coords = gps.trailPoints.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng) }
                            MapPolyline(coordinates: coords)
                                .stroke(Color.orange, lineWidth: 4)
                        }
                        UserAnnotation()
                        
                        // Show camp sites for this trip
                        ForEach(campStore.getSitesForTrip(tripID: trip.id)) { site in
                            Annotation(site.name, coordinate: site.location) {
                                Image(systemName: "tent.fill")
                                    .foregroundColor(.purple)
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .mapStyle(.hybrid)
                    .onMapCameraChange { context in
                        region = context.region
                    }
                } else {
                    Map(coordinateRegion: $region, showsUserLocation: true, mapType: mapMgr.mapType)
                }
            }
            .onReceive(gps.$currentLocation) { loc in
                if let loc = loc {
                    region = MKCoordinateRegion(center: loc.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
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
                
                // Bronco status indicator
                if trip.vehicleData.vehicleType == .bronco {
                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundColor(.blue)
                        if let mode = trip.vehicleData.terrainMode {
                            Text(mode.rawValue)
                                .font(.caption)
                        }
                        if trip.vehicleData.frontLockerEngaged || trip.vehicleData.rearLockerEngaged {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            
            // Bronco Controls Button
            if trip.vehicleData.vehicleType == .bronco {
                Button {
                    showingBroncoControls = true
                } label: {
                    HStack {
                        Image(systemName: "car.fill")
                        Text("Bronco Settings")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
            }
            
            // Mark Camp Site Button
            Button {
                showingCampSiteCapture = true
            } label: {
                HStack {
                    Image(systemName: "tent.fill")
                    Text("Mark Camp Site")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.purple.opacity(0.2))
                .foregroundColor(.purple)
                .cornerRadius(12)
            }
            
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
            AltitudeFusionEngine.shared.reset()
            gps.start()
            motion.start()
            BarometerManager.shared.start()
            
            // Sync vehicle data from connected sources
            if fordPass.isAuthenticated {
                fordPass.syncVehicleData(to: &trip.vehicleData)
            }
            if obd.isConnected {
                obd.syncVehicleData(to: &trip.vehicleData)
            }
            
            Task { 
                // Wait for GPS location before fetching weather
                var attempts = 0
                while gps.currentLocation == nil && attempts < 10 {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    attempts += 1
                }
                if let location = gps.currentLocation?.coordinate {
                    await WeatherManager.shared.fetchCurrent(at: location)
                }
            }
        }
        .sheet(isPresented: $showingBroncoControls) {
            BroncoControlView(vehicleData: $trip.vehicleData)
        }
        .sheet(isPresented: $showingCampSiteCapture) {
            CampSiteCaptureView(associatedTripID: trip.id)
        }
        .onDisappear {
            gps.stop()
            motion.stop()
            BarometerManager.shared.stop()
            motion.clearSnapshots()
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
        
        // Calculate grade and attach motion data to each point
        var maxPitch: Double = 0
        var maxRoll: Double = 0
        var maxGForce: Double = 0
        
        t.points = gps.trailPoints.enumerated().map { index, p in
            // Get motion snapshot nearest to this point's timestamp
            let motionSnapshot = motion.getSnapshot(nearestTo: p.timestamp) ?? MotionSnapshot(
                timestamp: p.timestamp,
                roughness: motion.roughness,
                pitch: motion.pitch,
                roll: motion.roll,
                gForce: motion.gForce,
                isAirborne: motion.isAirborne
            )
            
            // Calculate grade between consecutive points
            var gradePercent: Double = 0
            if index > 0 {
                let prevPoint = gps.trailPoints[index - 1]
                let altitudeDiff = p.fusedAlt - prevPoint.fusedAlt
                let distance = sqrt(
                    pow((p.lat - prevPoint.lat) * 111000, 2) + // Approx meters per degree lat
                    pow((p.lng - prevPoint.lng) * 111000 * cos(p.lat * .pi / 180), 2) // Approx meters per degree lng
                )
                if distance > 0 {
                    gradePercent = (altitudeDiff / distance) * 100
                }
            }
            
            // Track max values
            maxPitch = max(maxPitch, abs(motionSnapshot.pitch))
            maxRoll = max(maxRoll, abs(motionSnapshot.roll))
            maxGForce = max(maxGForce, motionSnapshot.gForce)
            
            return TripPoint(
                timestamp: p.timestamp,
                lat: p.lat,
                lng: p.lng,
                fusedAlt: p.fusedAlt, // Use the point's own fused altitude
                speed: p.speed,
                heading: p.heading,
                roughness: motionSnapshot.roughness,
                pitch: motionSnapshot.pitch,
                roll: motionSnapshot.roll,
                gForce: motionSnapshot.gForce,
                gradePercent: gradePercent
            )
        }
        
        // Store weather snapshot if available
        if let weather = WeatherManager.shared.currentWeather {
            t.weatherSnapshots.append(weather)
        }
        
        // Final sync of vehicle data before saving
        if fordPass.isAuthenticated {
            fordPass.syncVehicleData(to: &t.vehicleData)
        }
        if obd.isConnected {
            obd.syncVehicleData(to: &t.vehicleData)
        }
        
        // Get camp sites associated with this trip
        t.campSites = campStore.getSitesForTrip(tripID: t.id)
        
        t.telemetryStats.maxPitch = maxPitch
        t.telemetryStats.maxRoll = maxRoll
        t.telemetryStats.maxGForce = maxGForce
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