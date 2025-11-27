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
    @State private var showingEndConfirmation = false
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
            VStack(spacing: DesignSystem.Spacing.md) {
                if isLoadingGPS {
                    LoadingIndicator("Acquiring GPS")
                        .card()
                } else {
                    // Primary metrics grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DesignSystem.Spacing.sm) {
                        MetricCard(
                            icon: DesignSystem.Icons.elevation,
                            label: "Elevation",
                            value: "\(Int(AltitudeFusionEngine.shared.fusedAltitude))m",
                            color: .orange
                        )

                        MetricCard(
                            icon: DesignSystem.Icons.speed,
                            label: "Speed",
                            value: String(format: "%.0f", (gps.currentLocation?.speed ?? 0) * Constants.Conversion.metersPerSecToKmPerHour),
                            color: .green
                        )

                        MetricCard(
                            icon: DesignSystem.Icons.difficulty,
                            label: "Roughness",
                            value: String(format: "%.2f", motion.roughness),
                            color: .red
                        )
                    }

                    // Motion telemetry
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        // Pitch/Roll
                        VStack(spacing: DesignSystem.Spacing.xxs) {
                            HStack(spacing: DesignSystem.Spacing.xxs) {
                                Image(systemName: "arrow.up.and.down")
                                    .font(.caption)
                                Text("Pitch: \(Int(motion.pitch))°")
                                    .font(.caption)
                            }
                            HStack(spacing: DesignSystem.Spacing.xxs) {
                                Image(systemName: "arrow.left.and.right")
                                    .font(.caption)
                                Text("Roll: \(Int(motion.roll))°")
                                    .font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(DesignSystem.Spacing.sm)
                        .background(DesignSystem.Colors.cardBackground)
                        .cornerRadius(DesignSystem.CornerRadius.sm)

                        // G-Force
                        VStack(spacing: DesignSystem.Spacing.xxs) {
                            Text(String(format: "%.2f", motion.gForce))
                                .font(.title3.bold())
                            Text("G-Force")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(DesignSystem.Spacing.sm)
                        .background(DesignSystem.Colors.cardBackground)
                        .cornerRadius(DesignSystem.CornerRadius.sm)
                    }

                    // Airborne indicator
                    if motion.isAirborne {
                        HStack {
                            Image(systemName: DesignSystem.Icons.warning)
                                .foregroundColor(.white)
                            Text("AIRBORNE!")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(DesignSystem.Spacing.sm)
                        .background(DesignSystem.Colors.danger)
                        .cornerRadius(DesignSystem.CornerRadius.md)
                        .shadow(
                            radius: DesignSystem.Shadow.md.radius,
                            x: DesignSystem.Shadow.md.x,
                            y: DesignSystem.Shadow.md.y
                        )
                        .accessibilityLabel("Warning: Vehicle is airborne")
                    }
                }

                if isLoadingWeather {
                    LoadingIndicator("weather", size: 0.7)
                }

                // Bronco status indicator
                if trip.vehicleData.vehicleType == .bronco {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: DesignSystem.Icons.vehicle)
                            .foregroundColor(DesignSystem.Colors.bronco)

                        if let mode = trip.vehicleData.terrainMode {
                            StatusBadge(mode.rawValue, color: DesignSystem.Colors.bronco)
                        }

                        if trip.vehicleData.frontLockerEngaged || trip.vehicleData.rearLockerEngaged {
                            StatusBadge("Locked", color: .orange, icon: DesignSystem.Icons.lock)
                        }

                        Spacer()
                    }
                    .card()
                }
            }
            .padding(DesignSystem.Spacing.md)
            
            // Action Buttons
            VStack(spacing: DesignSystem.Spacing.sm) {
                // Bronco Controls Button
                if trip.vehicleData.vehicleType == .bronco {
                    Button {
                        HapticManager.shared.light()
                        showingBroncoControls = true
                    } label: {
                        HStack {
                            Image(systemName: DesignSystem.Icons.settings)
                            Text("Bronco Settings")
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle(color: DesignSystem.Colors.bronco))
                    .accessibilityLabel("Open Bronco vehicle settings")
                }

                // Mark Camp Site Button
                Button {
                    HapticManager.shared.light()
                    showingCampSiteCapture = true
                } label: {
                    HStack {
                        Image(systemName: DesignSystem.Icons.camp)
                        Text("Mark Camp Site")
                    }
                }
                .buttonStyle(SecondaryButtonStyle(color: DesignSystem.Colors.campSite))
                .accessibilityLabel("Mark current location as camp site")

                // End button
                NavigationLink(destination: EndSummaryView(trip: buildTrip())) {
                    HStack {
                        Image(systemName: "stop.circle.fill")
                        Text("End Trail")
                    }
                }
// Mark Camp Site Button
                Button {
                    HapticManager.shared.light()
                    showingCampSiteCapture = true
                } label: {
                    HStack {
                        Image(systemName: DesignSystem.Icons.camp)
                        Text("Mark Camp Site")
                    }
                }
                .buttonStyle(SecondaryButtonStyle(color: DesignSystem.Colors.campSite))
                .accessibilityLabel("Mark current location as camp site")

                // End button
                Button {
                    HapticManager.shared.warning()
                    showingEndConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "stop.circle.fill")
                        Text("End Trail")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isDestructive: true))
                .accessibilityLabel("End trail and save trip")
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
        .onAppear {
            // Clear any leftover GPS points from previous trips
            gps.clearTrailPoints()

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
        .alert("End Trail?", isPresented: $showingEndConfirmation) {
            Button("Cancel", role: .cancel) { }
            NavigationLink("End Trail", destination: EndSummaryView(trip: buildTrip()))
        } message: {
            Text("Are you sure you want to end this trail? Your progress will be saved.")
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