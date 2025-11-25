import SwiftUI
import MapKit

struct CampingView: View {
    @ObservedObject var gps = GPSManager.shared
    @ObservedObject var store = CampSiteStore.shared
    @StateObject private var weather = WeatherManager.shared
    @State private var region = MKCoordinateRegion()
    @State private var showingCampSiteCapture = false
    @State private var showingEmergency = false
    @State private var sessionCampSites: [CampSite] = []
    
    var body: some View {
        VStack {
            // Map
            Group {
                if #available(iOS 17.0, *) {
                    Map {
                        if let loc = gps.currentLocation {
                            UserAnnotation()
                        }
                        ForEach(sessionCampSites) { site in
                            Annotation(site.name, coordinate: site.location) {
                                Image(systemName: "tent.fill")
                                    .foregroundColor(.orange)
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
                    Map(coordinateRegion: $region, showsUserLocation: true, mapType: .hybrid)
                }
            }
            .frame(height: 300)
            .onReceive(gps.$currentLocation) { loc in
                if let loc = loc {
                    region = MKCoordinateRegion(center: loc.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                }
            }
            
            // Weather Widget
            if let weatherData = weather.currentWeather {
                HStack {
                    Image(systemName: "cloud.sun")
                    Text("\(Int(weatherData.temperature))°C")
                    Text(weatherData.condition)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            // Camp Sites List
            if !sessionCampSites.isEmpty {
                VStack(alignment: .leading) {
                    Text("Camp Sites This Session")
                        .font(.headline)
                        .padding(.horizontal)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(sessionCampSites) { site in
                                NavigationLink(destination: CampSiteDetailView(campSite: site)) {
                                    VStack(alignment: .leading) {
                                        Text(site.name)
                                            .font(.headline)
                                        Text(site.timestamp.formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Action Buttons
            VStack(spacing: 12) {
                Button {
                    showingCampSiteCapture = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Mark Camp Site")
                    }
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button {
                    showingEmergency = true
                } label: {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Emergency")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Camping")
        .onAppear {
            // Fetch weather
            Task {
                if let loc = gps.currentLocation {
                    await weather.fetchCurrent(at: loc.coordinate)
                }
            }
        }
        .sheet(isPresented: $showingCampSiteCapture) {
            CampSiteCaptureView()
                .onDisappear {
                    // Refresh session sites
                    sessionCampSites = store.campSites.filter { $0.timestamp >= Date().addingTimeInterval(-86400) } // Last 24 hours
                }
        }
        .sheet(isPresented: $showingEmergency) {
            EmergencyView()
        }
    }
}

