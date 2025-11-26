import SwiftUI
import MapKit

struct TrackView: View {
    @ObservedObject var gps = GPSManager.shared
    @ObservedObject var motion = MotionManager.shared
    @ObservedObject var mapMgr = TrailMapManager.shared
    @StateObject private var fordPass = FordPassManager.shared
    @StateObject private var obd = OBDManager.shared
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: Constants.Map.defaultLatitude, longitude: Constants.Map.defaultLongitude),
        span: MKCoordinateSpan(latitudeDelta: Constants.Map.detailLatitudeDelta, longitudeDelta: Constants.Map.detailLongitudeDelta)
    )
    @State private var trip = Trip.new()
    @State private var showingEasterEgg = false
    @State private var showingBroncoControls = false
    @State private var showingCampSiteCapture = false
    @State private var isLoadingWeather = true
    @State private var isLoadingGPS = true
    @State private var autoSaveTimer: Timer?
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
                    region = MKCoordinateRegion(
                        center: loc.coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: Constants.Map.detailLatitudeDelta,
                            longitudeDelta: Constants.Map.detailLongitudeDelta
                        )
                    )
                }
            }
            
            // Telemetry Dashboard
            VStack {
                if isLoadingGPS {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Acquiring GPS...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("True Elevation: \(AltitudeFusionEngine.shared.fusedAltitude, specifier: "%.0f") m")
                    Text("Speed: \( (gps.currentLocation?.speed ?? 0) * Constants.Conversion.metersPerSecToKmPerHour , specifier: "%.1f") km/h")
                    Text("Pitch/Roll: \(motion.pitch, specifier: "%.0f")° / \(motion.roll, specifier: "%.0f")°")
                    Text("G-Force: \(motion.gForce, specifier: "%.2f")")
                    Text("Roughness: \(motion.roughness, specifier: "%.3f")")
                    if motion.isAirborne {
                        Text("AIRBORNE!").foregroundColor(.red)
                    }
                }

                if isLoadingWeather {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.6)
                        Text("Loading weather...")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
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
            // Check for temp trip from crash recovery
            if let tempTrip = TripStore.shared.loadTempTrip() {
                trip = tempTrip
            } else {
                trip = Trip.new()
            }

            AltitudeFusionEngine.shared.reset()
            gps.start(activeTracking: true)
            motion.start()
            BarometerManager.shared.start()

            // Sync vehicle data from connected sources
            if fordPass.isAuthenticated {
                fordPass.syncVehicleData(to: &trip.vehicleData)
            }
            if obd.isConnected {
                obd.syncVehicleData(to: &trip.vehicleData)
            }

            // Start auto-save timer (every 60 seconds)
            autoSaveTimer = Timer.scheduledTimer(withTimeInterval: Constants.AutoSave.intervalSeconds, repeats: true) { _ in
                TripStore.shared.saveTempTrip(buildTrip())
            }

            // Monitor GPS lock
            Task {
                var attempts = 0
                while gps.currentLocation == nil && attempts < 20 {
                    try? await Task.sleep(nanoseconds: Constants.Weather.gpsCheckInterval)
                    attempts += 1
                }
                isLoadingGPS = false

                // Fetch weather with extended timeout
                if let location = gps.currentLocation?.coordinate {
                    await WeatherManager.shared.fetchCurrent(at: location)
                    isLoadingWeather = false
                } else {
                    // No GPS, still stop loading indicator
                    isLoadingWeather = false
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
            autoSaveTimer?.invalidate()
            autoSaveTimer = nil
            gps.stop()
            motion.stop()
            BarometerManager.shared.stop()
            motion.clearSnapshots()
        }
        .alert("\(Constants.App.name) – Certified Trail Legend!", isPresented: $showingEasterEgg) {
            Button("Awesome!") { }
        } message: {
            Text("You've unlocked the 100 Club! Daniel Sutton would be proud.")
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
                    pow((p.lat - prevPoint.lat) * Constants.Conversion.metersPerDegreeLat, 2) +
                    pow((p.lng - prevPoint.lng) * Constants.Conversion.metersPerDegreeLng * cos(p.lat * .pi / 180), 2)
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

        // Check for "100 Club" achievement
        if t.difficultyRatings.suttonScore >= 100 {
            showingEasterEgg = true
        }

        return t
    }
}