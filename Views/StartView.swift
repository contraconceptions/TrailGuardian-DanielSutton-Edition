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
            }
            .padding()
            .onAppear {
                Task {
                    if let loc = GPSManager.shared.currentLocation?.coordinate {
                        await weather.fetchCurrent(at: loc)
                        currentTemp = "\(Int(weather.currentWeather?.temperature ?? 0))°C \(weather.currentWeather?.condition ?? "")"
                    }
                }
            }
        }
    }
}