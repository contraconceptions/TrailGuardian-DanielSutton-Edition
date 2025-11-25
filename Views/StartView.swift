import SwiftUI

struct StartView: View {
    @StateObject private var weather = WeatherManager.shared
    @State private var currentTemp: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                VStack {
                    Text("Trail Guardian")
                        .font(.largeTitle.bold())
                    Text("Built for Daniel Sutton")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Christmas 2025")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                // Weather chip
                HStack {
                    Image(systemName: "cloud.sun")
                    Text(currentTemp)
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                NavigationLink(destination: TrackView()) {
                    Text("Start New Trail")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                NavigationLink(destination: HistoryView()) {
                    Text("View Trip History")
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(12)
                }
                
                NavigationLink(destination: CampingView()) {
                    Text("Start Camping")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                NavigationLink(destination: CampSiteListView()) {
                    Text("View Camp Sites")
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(12)
                }
            }
            .padding()
            .onAppear {
                Task {
                    // Wait a bit for GPS to get location
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    if let loc = GPSManager.shared.currentLocation?.coordinate {
                        await weather.fetchCurrent(at: loc)
                        if let weatherData = weather.currentWeather {
                            currentTemp = "\(Int(weatherData.temperature))°C \(weatherData.condition)"
                        } else if let error = weather.weatherError {
                            currentTemp = "Weather unavailable"
                        }
                    } else {
                        currentTemp = "Waiting for location..."
                    }
                }
            }
        }
    }
}