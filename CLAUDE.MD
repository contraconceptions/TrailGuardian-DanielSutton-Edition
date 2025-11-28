# CLAUDE.MD - AI Assistant Guide for Trail Guardian

This file provides context and guidance for AI assistants (like Claude Code) working on the Trail Guardian iOS app.

## Project Overview

**Trail Guardian** is a personalized iOS application for off-roading and camping enthusiasts. It tracks trails with professional-grade telemetry, calculates difficulty ratings using multiple systems, and manages camp sites with comprehensive data capture.

**Target User**: Daniel Sutton (Christmas 2025 gift)
**Platform**: iOS 16.0+
**Language**: Swift + SwiftUI
**Architecture**: MVVM with singleton managers

## Key Technical Concepts

### 1. Difficulty Rating System
The app uses a sophisticated multi-factor algorithm (`DifficultyCalculator.swift`) that produces multiple rating outputs:
- **Sutton Score** (0-100): Custom algorithm factoring grade, roughness, G-force, pitch, weather, and vehicle config
- **Jeep Badge Rating** (1-10): Traditional Jeep trail difficulty
- **Wells Rating**: Ski slope style (Green Circle → Double Black Diamond)
- **USFS Trail Rating**: U.S. Forest Service standard
- **International Classification**: Blue/Red/Black system

### 2. Altitude Fusion Engine
`AltitudeFusionEngine.swift` combines two data sources for accurate elevation:
- GPS altitude (accurate outdoors, but noisy)
- Barometric pressure (smooth, but drifts)
- Kalman-like filter produces fused altitude with confidence estimates

### 3. Auto-Save Architecture
Crash recovery system (`TripStore.swift`):
- Every 60 seconds during tracking → saves to `temp_active_trip.json`
- On app restart → checks for temp file and offers recovery
- On successful trip end → temp file deleted, final trip saved to `trips.json`

### 4. Vehicle Integration Framework
`VehicleData.swift` supports 10+ vehicle types with Ford Bronco-specific features:
- Terrain modes (Normal, Eco, Sport, Slippery, Sand/Mud, Rock Crawl, Baja)
- Drive modes (2WD, 4WD Auto/High/Low)
- Locker status, sway bar disconnect, winch usage
- Framework ready for FordPass API and OBD-II integration

## Project Structure

```
.
├── TrailGuardianApp.swift          # App entry point
├── Models/                          # 23 files - Data models & business logic
│   ├── Trip.swift                   # Core trip model with computed properties
│   ├── TripPoint.swift              # Single GPS point with telemetry
│   ├── TripStore.swift              # Persistence layer for trips
│   ├── CampSite.swift              # Camp site data model
│   ├── CampSiteStore.swift         # Persistence layer for camp sites
│   ├── DifficultyCalculator.swift  # Multi-system difficulty rating engine
│   ├── AltitudeFusionEngine.swift  # GPS + barometer fusion
│   ├── Constants.swift             # Centralized configuration
│   ├── VehicleData.swift           # Vehicle types and configurations
│   ├── WeatherSnapshot.swift       # Weather data structure
│   ├── WeatherManager.swift        # WeatherKit wrapper
│   ├── BarometerManager.swift      # CoreMotion barometer wrapper
│   ├── PhotoHelper.swift           # Image compression utilities
│   ├── PDFExporter.swift           # Trip summary PDF generation
│   ├── TrailMapManager.swift       # Map utilities
│   ├── Moment.swift                # Point-in-time snapshot
│   └── EmergencyKit.swift          # Emergency contact/info
├── Views/                           # 12 files - SwiftUI interface
│   ├── StartView.swift             # Home screen
│   ├── TrackView.swift             # Active tracking interface
│   ├── EndSummaryView.swift        # Post-trip summary
│   ├── HistoryView.swift           # Trip history browser
│   ├── CampSiteCaptureView.swift   # Add/edit camp site form
│   ├── CampSiteListView.swift      # Browse/search camp sites
│   ├── CampSiteDetailView.swift    # Single camp site details
│   ├── CampingView.swift           # Camping mode interface
│   ├── EmergencyView.swift         # Emergency features
│   ├── BroncoControlView.swift     # Ford Bronco controls
│   └── RouteMapView.swift          # Map visualization
└── Services/                        # 12 files - External integrations
    ├── GPSManager.swift            # CoreLocation wrapper (ACTIVE)
    ├── MotionManager.swift         # CoreMotion wrapper (ACTIVE)
    ├── FordPassManager.swift       # Ford API (STUB - needs API key)
    ├── OBDManager.swift            # OBD-II Bluetooth (STUB - needs adapter)
    ├── RIDBService.swift           # Recreation.gov (STUB - needs API key)
    ├── NWSService.swift            # National Weather Service (STUB)
    ├── OSMService.swift            # OpenStreetMap Overpass (STUB)
    ├── PublicLandsService.swift    # Public lands data (STUB)
    ├── USGSService.swift           # USGS data (STUB)
    ├── CampflareService.swift      # Campflare integration (STUB)
    ├── CampSiteSharing.swift       # Share functionality (ACTIVE)
    └── APIManager.swift            # Shared API utilities
```

## Data Flow During Tracking

1. User taps "Start New Trail" → `TrackView` appears
2. `GPSManager.shared.startTracking()` initiates location updates
3. Every location update:
   - Stored in `trackPoints[]` array
   - Fed to `AltitudeFusionEngine.update()`
   - Weather fetched if conditions change significantly
4. Simultaneously, `MotionManager.shared.startTracking()`:
   - Captures device attitude (pitch/roll)
   - Measures G-forces via accelerometer
   - Stores snapshots in `motionSnapshots[]`
5. Every 60 seconds:
   - `autoSaveTimer` fires
   - `TripStore.shared.saveTempTrip()` writes to Documents/temp_active_trip.json
6. User taps "End Trail":
   - `buildTrip()` compiles all data into `Trip` object
   - `DifficultyCalculator.calculate()` generates all ratings
   - Trip saved to `trips.json` via `TripStore`
   - Temp file deleted
   - Navigate to `EndSummaryView`

## Critical Files for Common Tasks

### Adding New Telemetry Metrics
1. **Capture**: `MotionManager.swift` - add sensor reading
2. **Store**: `Moment.swift` - add property to data structure
3. **Display**: `TrackView.swift` - add to telemetry dashboard
4. **Calculate**: `DifficultyCalculator.swift` - incorporate into scoring

### Adding New Difficulty Rating Systems
1. **Algorithm**: `DifficultyCalculator.swift` - add calculation method
2. **Display**: `EndSummaryView.swift` - add rating badge
3. **Constants**: `Constants.swift` - add configuration if needed

### Modifying Camp Site Fields
1. **Model**: `CampSite.swift` - add property (must be Codable)
2. **Form**: `CampSiteCaptureView.swift` - add input field
3. **Display**: `CampSiteDetailView.swift` - show new field
4. **Search**: `CampSiteListView.swift` - add filter if needed

### Integrating External APIs
1. **Service File**: Check `Services/` for existing stub
2. **Add API Key**: Store securely (not in source control)
3. **Implement Methods**: Replace `// TODO:` with actual API calls
4. **Error Handling**: Add proper error states
5. **UI Integration**: Update relevant views to display data

## Important Patterns & Conventions

### State Management
- **Singleton managers** for GPS, Motion, Weather (shared global state)
- **@Published properties** for reactive SwiftUI updates
- **@StateObject** in views for lifecycle management
- **@EnvironmentObject** for passing stores through view hierarchy

### Persistence
- **JSON files** in Documents directory
- **Codable protocol** for all persisted models
- **Atomic writes** using temporary files then rename
- **Error handling** with Result types where appropriate

### Location Permissions
- **"When In Use"**: Minimum for basic tracking
- **"Always"**: Required for background tracking
- Handle permission changes gracefully in `GPSManager`

### Photo Management
- **Compression**: `PhotoHelper.compressImage()` - max 1920x1080, 80% quality
- **Storage**: Documents directory, not Photo Library
- **Limit**: 10 photos per camp site
- **Format**: JPEG for consistency

## Configuration & Constants

`Models/Constants.swift` centralizes all configurable values:
```swift
GPS.minAccuracy = 50.0              // Reject points worse than 50m
GPS.significantDistanceFilter = 5.0  // Meters between updates
Difficulty.gradeWeight = 0.25        // Scoring factor weights
AutoSave.intervalSeconds = 60.0      // Auto-save frequency
Photo.maxDimension = 1920            // Max photo size
Photo.compressionQuality = 0.8       // JPEG quality
```

Modify these to tune app behavior without touching business logic.

## Privacy & Permissions

Required Info.plist keys (critical for App Store):
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `NSMotionUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSCameraUsageDescription`

Required Capabilities:
- Background Modes → Location updates (for background tracking)
- WeatherKit (requires Apple Developer enrollment)

## Testing Considerations

### Areas Needing Unit Tests
- [ ] `DifficultyCalculator.calculate()` - edge cases (flat terrain, extreme grades)
- [ ] `AltitudeFusionEngine.update()` - fusion accuracy with mock data
- [ ] `Trip.totalDistance` - distance calculation accuracy
- [ ] `Trip.elevationGain/Loss` - elevation math
- [ ] `TripStore.save/load` - persistence integrity
- [ ] `PhotoHelper.compressImage()` - compression quality/size

### Manual Testing Checklist
- GPS accuracy on real trails vs known distances
- Battery drain during 4+ hour tracking sessions
- Background tracking with screen locked
- Low/no signal scenarios (airplane mode)
- Auto-save and crash recovery (force quit app mid-track)
- Photo compression (verify file sizes)
- Max camp site photos (exactly 10)

## Known Limitations & Future Work

### Current Limitations
- **No cloud sync**: All data local only, no iCloud integration
- **No offline maps**: Requires internet for map tiles
- **Stubbed APIs**: FordPass, OBD-II, Recreation.gov not implemented
- **No Apple Watch**: SwiftUI code is reusable, but not implemented
- **Photo storage**: Stored in app Documents, deleted if app deleted

### Enhancement Roadmap (Priority Order)
1. iCloud sync for trips and camp sites
2. FordPass API integration (real vehicle data)
3. OBD-II Bluetooth integration (engine metrics)
4. Offline map tile caching
5. Apple Watch companion app
6. Recreation.gov campground discovery
7. Social features (share trips publicly)
8. Achievement/badge system

## Common Issues & Solutions

### "GPS Not Working"
- Check: Settings → Privacy → Location Services → Trail Guardian
- Should be "Always" or "While Using App"
- Try airplane mode toggle to reset GPS chip

### "Weather Not Loading"
- Requires internet connection
- Requires location permission
- WeatherKit requires signed-in Apple ID
- Check Xcode WeatherKit capability is enabled

### "Crash on Launch"
- Verify all Info.plist privacy keys present
- Check Console.app for errors
- Look for corrupted temp_active_trip.json

### "Auto-Save Not Working"
- Check Documents/temp_active_trip.json exists during tracking
- Timer should fire every 60s (check logs)
- Verify disk space available

## Development Setup

### Prerequisites
- macOS with Xcode 15.0+
- iOS 16.0+ device (simulator has limited GPS/motion)
- Apple Developer Account (free tier OK for development)
- Apple ID enrolled in WeatherKit (free tier: 500K calls/month)

### Quick Start
```bash
cd TrailGuardian-DanielSutton-Edition
open TrailGuardian.xcodeproj
# Configure signing & capabilities
# Build and run (⌘R)
```

### Testing on Device vs Simulator
- **Simulator**: Good for UI work, limited GPS simulation, NO motion sensors
- **Physical Device**: Required for realistic GPS, motion, barometer testing
- **Field Testing**: Essential for validating difficulty calculations

## Code Style & Best Practices

### Swift Style
- Use `struct` for data models, `class` for managers with shared state
- Mark classes as `@Observable` or `ObservableObject` for SwiftUI
- Use `// MARK: - Section Name` for organization
- Prefer `let` over `var` where possible
- Use `guard` for early returns, not nested `if`

### SwiftUI Conventions
- Extract complex views into separate files
- Use `@StateObject` for ownership, `@ObservedObject` for passing
- Prefer `@EnvironmentObject` over passing multiple parameters
- Keep view bodies under 50 lines (extract subviews)

### Comments
- Document complex algorithms with `///` doc comments
- Use `// TODO:` for stubbed features needing implementation
- Use `// FIXME:` for known bugs needing attention
- Use `// MARK: -` to organize code sections

## API Integration Guide

### Adding a New External API

1. **Create Service File** (if not exists):
   ```swift
   // Services/MyService.swift
   import Foundation

   class MyService {
       static let shared = MyService()
       private init() {}

       func fetchData() async throws -> MyData {
           // Implementation
       }
   }
   ```

2. **Add API Key Storage** (use Keychain or env vars, NOT source code):
   ```swift
   private let apiKey = ProcessInfo.processInfo.environment["MY_API_KEY"] ?? ""
   ```

3. **Add Models** (in Models/ directory):
   ```swift
   struct MyData: Codable {
       let property: String
   }
   ```

4. **Integrate in Views**:
   ```swift
   @State private var data: MyData?

   .task {
       data = try? await MyService.shared.fetchData()
   }
   ```

5. **Add Error Handling**:
   ```swift
   @State private var errorMessage: String?
   ```

## Personalization & Customization

To make the app less personalized (remove "Daniel Sutton" branding):
1. `Constants.swift` → Change `App.edition`
2. Search project for "Daniel Sutton" and replace with generic text
3. `PDFExporter.swift` → Update footer text
4. `README.md` → Update title and descriptions

To add new vehicle types:
1. `VehicleData.swift` → Add to `VehicleType` enum
2. Add vehicle-specific terrain modes if needed
3. `DifficultyCalculator.swift` → Add vehicle-specific scoring bonuses

## Git Workflow Notes

**Current Branch**: `frosty-satoshi` (worktree)
**Main Branch**: `main`
**Repository**: E:\My Apps\DSTrail

When making changes:
- Stay on current branch unless instructed otherwise
- Commit messages should follow existing style (imperative mood)
- Don't commit API keys or sensitive data
- Test on device before committing major features

## Resources & References

### Apple Documentation
- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [CoreLocation](https://developer.apple.com/documentation/corelocation)
- [CoreMotion](https://developer.apple.com/documentation/coremotion)
- [WeatherKit](https://developer.apple.com/documentation/weatherkit)
- [MapKit](https://developer.apple.com/documentation/mapkit)

### Trail Rating Systems
- [Jeep Badge Ratings](https://www.jeep.com/badge-of-honor.html)
- Wells Rating: Ski slope difficulty analog
- [USFS Trail Class System](https://www.fs.fed.us/td/pubs/htmlpubs/htm99232806/)

### External APIs (Stubbed)
- [FordPass API](https://developer.ford.com) - Vehicle data
- [Recreation.gov RIDB](https://ridb.recreation.gov/) - Campground data
- [National Weather Service API](https://www.weather.gov/documentation/services-web-api)
- [OpenStreetMap Overpass](https://wiki.openstreetmap.org/wiki/Overpass_API)

## Questions to Ask When Uncertain

Before making significant changes, consider:
1. **Impact**: Does this change affect difficulty calculations? (needs testing)
2. **Persistence**: Does this change the data model? (migration needed)
3. **Performance**: Will this impact battery or GPS accuracy?
4. **Privacy**: Does this require new permissions?
5. **Testing**: Can this be tested in simulator or needs device?

## Summary for Quick Context

**What is this?** iOS trail tracking app with advanced telemetry and difficulty ratings
**Who is it for?** Daniel Sutton (off-roading enthusiast)
**What's the core flow?** Start tracking → GPS + motion sensors → auto-save → end tracking → difficulty calculation → PDF export
**What's ready?** Full tracking, difficulty ratings, camp sites, crash recovery
**What's stubbed?** FordPass, OBD-II, Recreation.gov, NWS, OSM APIs
**What's the priority?** Stability, accuracy, battery efficiency

---

**Last Updated**: 2025-11-27
**For**: Claude Code and future AI assistants
**Maintainer**: Check git log for recent contributors
