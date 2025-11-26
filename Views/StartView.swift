import SwiftUI

struct StartView: View {
    @StateObject private var weather = WeatherManager.shared
    @StateObject private var gps = GPSManager.shared
    @State private var currentTemp: String = ""
    @State private var isLoadingWeather = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Header
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: DesignSystem.Icons.trail)
                            .font(.system(size: 50))
                            .foregroundColor(.accentColor)
                            .padding(.bottom, DesignSystem.Spacing.sm)

                        Text("Trail Guardian")
                            .font(.largeTitle.bold())

                        Text("Built for Daniel Sutton")
                            .font(.title3)
                            .foregroundColor(.secondary)

                        Text("Christmas 2025")
                            .font(.caption.bold())
                            .foregroundColor(DesignSystem.Colors.suttonScore)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Trail Guardian, Built for Daniel Sutton, Christmas 2025")
                    .padding(.top, DesignSystem.Spacing.lg)

                    // Weather Card
                    if isLoadingWeather {
                        LoadingIndicator("weather")
                            .card()
                    } else if !currentTemp.isEmpty {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: DesignSystem.Icons.weather)
                                .font(.title2)
                                .foregroundColor(.orange)

                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                                Text("Current Conditions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(currentTemp)
                                    .font(.headline)
                            }

                            Spacer()

                            if let loc = gps.currentLocation {
                                Image(systemName: DesignSystem.Icons.location)
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        .card()
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Weather: \(currentTemp)")
                    }

                    // Primary Actions
                    VStack(spacing: DesignSystem.Spacing.md) {
                        NavigationLink(destination: TrackView()) {
                            HStack {
                                Image(systemName: DesignSystem.Icons.trail)
                                    .font(.title3)
                                Text("Start New Trail")
                                    .font(.title3.bold())
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle(color: DesignSystem.Colors.startTrail))
                        .accessibilityLabel("Start new trail tracking")

                        NavigationLink(destination: CampingView()) {
                            HStack {
                                Image(systemName: DesignSystem.Icons.camp)
                                    .font(.title3)
                                Text("Start Camping")
                                    .font(.title3.bold())
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle(color: DesignSystem.Colors.startCamping))
                        .accessibilityLabel("Start camping session")
                    }

                    // Secondary Actions
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        NavigationLink(destination: HistoryView()) {
                            HStack {
                                Image(systemName: DesignSystem.Icons.history)
                                Text("View Trip History")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle(color: .blue))
                        .accessibilityLabel("View trip history")

                        NavigationLink(destination: CampSiteListView()) {
                            HStack {
                                Image(systemName: DesignSystem.Icons.camp)
                                Text("View Camp Sites")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle(color: DesignSystem.Colors.campSite))
                        .accessibilityLabel("View saved camp sites")
                    }

                    Spacer()
                }
                .padding(DesignSystem.Spacing.md)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    // Wait a bit for GPS to get location
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    if let loc = GPSManager.shared.currentLocation?.coordinate {
                        await weather.fetchCurrent(at: loc)
                        if let weatherData = weather.currentWeather {
                            currentTemp = "\(Int(weatherData.temperature))°C \(weatherData.condition)"
                        } else {
                            currentTemp = "Weather unavailable"
                        }
                    } else {
                        currentTemp = "Waiting for location..."
                    }
                    isLoadingWeather = false
                }
            }
        }
    }
}