# Trail Guardian - Daniel Sutton Edition 🏔️🚙

**A Christmas 2025 Gift for Daniel Sutton**

An iOS app for off-roading and camping enthusiasts that tracks trails with professional-grade telemetry, calculates difficulty ratings, and manages camp sites.

---

## 🎁 About This App

Trail Guardian is a personalized iOS application built specifically for Daniel Sutton's off-roading and camping adventures. This app combines GPS tracking, motion telemetry, weather data, and vehicle integration to create comprehensive trail records with difficulty ratings inspired by skiing and Jeep trail systems.

**Built with production-grade architecture** following Apple's Human Interface Guidelines, featuring MVVM design patterns, comprehensive accessibility support, haptic feedback, and a professional design system. See [Recent Enhancements](#-recent-enhancements) for details.

### Key Features

#### 🛣️ Trail Tracking
- **High-accuracy GPS tracking** with background support
- **Real-time map visualization** with hybrid satellite view
- **Advanced telemetry system** measuring:
  - Pitch and roll (device attitude)
  - G-force via accelerometer
  - Terrain roughness (RMS acceleration)
  - Airborne detection
  - Speed and heading
- **Altitude fusion engine** combining GPS + barometric pressure
- **Auto-save** every 60 seconds to prevent data loss

#### 📊 Difficulty Rating System
- **Sutton Score** (0-100): Custom algorithm considering grade, roughness, G-force, pitch, weather, and vehicle configuration
- **Jeep Badge Rating** (1-10): Traditional Jeep trail difficulty
- **Wells Rating**: Ski slope style (Green Circle → Double Black Diamond)
- **USFS Trail Rating**: U.S. Forest Service standard
- **International Classification**: Blue/Red/Black system

#### 🚗 Vehicle Integration
Supports 10+ vehicle types with Ford Bronco-specific features:
- Terrain mode tracking (Normal, Eco, Sport, Slippery, Sand/Mud, Rock Crawl, Baja)
- Drive mode (2WD, 4WD Auto/High/Low)
- Differential locker status
- Trail Control & Trail Turn Assist
- Sway bar disconnect tracking
- Winch usage logging
- **Future integration**: FordPass API and OBD-II Bluetooth adapters

#### ⛺ Camp Site Management
- **Comprehensive camp site capture** with:
  - GPS coordinates and elevation
  - Photo gallery (up to 10 photos, automatically compressed)
  - Water source details (type, distance, potability)
  - Features (fire ring, wildlife sightings)
  - Ratings (accessibility, difficulty, privacy, overall)
  - Terrain and ground conditions
  - Required/recommended gear
  - Safety info (cell service, emergency access)
- **Search and filter** camp sites
- **Map and list views**
- **Export as GPX, KML, or GeoJSON**
- **Share location** via SMS/email

#### 🆘 Emergency Features
- Emergency contact management
- Quick location sharing (coordinates + Google Maps link)
- Emergency checklist
- Survival tips (water, shelter, fire, signaling, navigation)

#### 📄 Data Export
- **PDF trip summaries** with map, stats, and ratings
- **GPX/KML/GeoJSON** export for camp sites
- Compatible with mapping apps and GIS software

#### 📈 Trip Statistics
- Total distance (km and miles)
- Duration and average/max speed
- Elevation gain/loss and min/max elevation
- Detailed telemetry maximums
- Weather conditions
- Points recorded

---

## 🔧 Setup Instructions

### Quick "lite" build

If you simply want the project to open and run in Xcode without extra capabilities, use the new lightweight demo views. They rely on static sample data (no WeatherKit, CoreLocation, or motion permissions) so the app can compile cleanly before you wire up real services.


### Prerequisites
- **Mac** with Xcode 15.0 or later
- **iOS 16.0+** device (iPhone or iPad)
- **Apple Developer Account** (free or paid)
- **Apple ID** enrolled in WeatherKit (free tier available)

### Building the App

1. **Open the project**
   ```bash
   cd DSTrail
   open TrailGuardian.xcodeproj
   ```

2. **Configure Info.plist**

   Add the following privacy usage descriptions to your app's `Info.plist`:

   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>Trail Guardian tracks your off-road routes with high-precision GPS to record telemetry and difficulty ratings.</string>

   <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
   <string>Trail Guardian needs background location access to continue tracking your trail even when the app is in the background.</string>

   <key>NSMotionUsageDescription</key>
   <string>Trail Guardian uses motion sensors to measure pitch, roll, G-forces, and terrain roughness during your adventures.</string>

   <key>NSPhotoLibraryUsageDescription</key>
   <string>Trail Guardian needs access to save photos of your camp sites and trail moments.</string>

   <key>NSCameraUsageDescription</key>
   <string>Trail Guardian uses the camera to capture photos of camp sites and trail conditions.</string>

   <key>WeatherKit</key>
   <string></string>
   ```

3. **Enable Capabilities**

   In Xcode, select your target → Signing & Capabilities:
   - Add **Background Modes** capability
     - Check ☑️ **Location updates**
   - Add **WeatherKit** capability (requires Apple Developer enrollment)

4. **Configure Signing**
   - Select your Apple Developer team
   - Choose automatic or manual signing
   - Update the bundle identifier if needed

5. **Build and Run**
   - Select your target device
   - Press **⌘R** to build and run

### First Launch Setup

On first launch, the app will request permissions:
1. **Location Access**: Choose "Allow While Using App" or "Always Allow" (recommended for background tracking)
2. **Motion & Fitness**: Tap "Allow" to enable telemetry features
3. **Photos**: Grant access to save camp site photos

---

## 📱 How to Use

### Starting a Trail
1. Tap **"Start New Trail"** on the home screen
2. Wait for GPS lock (indicator will appear)
3. The map will show your live location with a trail polyline
4. Telemetry dashboard shows real-time data
5. Tap **"End Trail"** when finished

### Viewing Trip Summary
After ending a trail:
- View the **route map** with full trail visualization
- See **difficulty ratings** across all systems
- Review **elevation chart**
- Check **telemetry statistics**
- Export as **PDF** for sharing

### Marking a Camp Site
**During tracking:**
1. Tap **"Mark Camp Site"** button
2. Fill out camp site details (auto-filled GPS/elevation)
3. Add up to 10 photos
4. Rate accessibility, difficulty, privacy
5. Save to associate with current trip

**From camping mode:**
1. Tap **"Start Camping"** on home screen
2. Tap **"Mark This Location"**
3. Complete the same form

### Managing Camp Sites
1. Tap **"View Camp Sites"** on home screen
2. Use search bar or filters (rating, fire ring, water)
3. Toggle between **list** and **map** view
4. Tap a site to:
   - View full details and photos
   - Get directions in Apple Maps
   - Share location
   - Export as GPX/KML/GeoJSON
   - Edit or delete

### Viewing Trip History
1. Tap **"View Trip History"**
2. Swipe left on any trip → **Delete** to remove
3. Tap any trip to view full summary

---

## 🚀 Advanced Features

### Crash Recovery
If the app crashes during tracking, don't worry! The app auto-saves your progress every 60 seconds. On next launch, it will restore your active trip from the temp file.

### Background Tracking
With "Always Allow" location permission, the app continues tracking even when:
- Screen is locked
- App is in background
- Phone is in low power mode (reduced GPS accuracy)

### Battery Optimization
The app automatically adjusts GPS accuracy:
- **Active tracking**: Best accuracy (±5-10m)
- **Background mode**: Reduced accuracy (±10-100m) to save battery

### Photo Compression
All camp site photos are automatically:
- Resized to max 1920x1080 resolution
- Compressed to 80% JPEG quality
- This saves ~70-80% storage compared to full-res photos

---

## 🔌 Future API Integrations

The app includes **framework-ready stubs** for these external services. To activate them, you'll need to obtain API keys:

### FordPass API (Ford Bronco owners)
- **Requires**: Ford Developer Portal account + API key
- **Provides**: Real-time terrain mode, drive mode, locker status, fuel level
- **Status**: Stubbed with OAuth flow ready
- **File**: `Services/FordPassManager.swift`

### OBD-II Bluetooth Adapter
- **Requires**: ELM327 or similar Bluetooth OBD-II adapter (~$20)
- **Provides**: Engine RPM, throttle position, tire pressure, real-time diagnostics
- **Status**: CoreBluetooth framework implemented, PID reading defined
- **File**: `Services/OBDManager.swift`

### Recreation.gov (RIDB API)
- **Requires**: Free API key from https://ridb.recreation.gov/
- **Provides**: Public campground search, availability, reservations
- **Status**: Endpoints documented, rate limiting configured
- **File**: `Services/RIDBService.swift`

### National Weather Service
- **Requires**: None (free public API)
- **Provides**: Weather alerts, extended forecasts
- **Status**: Alert system framework in place
- **File**: `Services/NWSService.swift`

### OpenStreetMap Overpass
- **Requires**: None (free, rate-limited)
- **Provides**: Trail finding, water sources, campsite discovery
- **Status**: Query templates defined
- **File**: `Services/OSMService.swift`

To enable any service, open the corresponding file and look for `// TODO:` comments with implementation guides.

---

## 🏗️ Architecture

### Design Pattern
- **MVVM** (Model-View-ViewModel)
- **Singleton managers** for shared state
- **ObservableObject** for reactive UI updates
- **Codable** for JSON persistence

### Project Structure
```
DSTrail/
├── TrailGuardianApp.swift          # App entry point
├── Models/                          # Data models & business logic (20+ files)
│   ├── Trip.swift                   # Trip data with computed stats
│   ├── CampSite.swift              # Camp site data model
│   ├── TripStore.swift             # Trip persistence
│   ├── CampSiteStore.swift         # Camp site persistence
│   ├── DifficultyCalculator.swift  # Difficulty rating engine
│   ├── AltitudeFusionEngine.swift  # GPS + barometer fusion
│   ├── Constants.swift             # Centralized constants (zero magic numbers)
│   ├── PhotoHelper.swift           # Photo compression utilities
│   ├── DesignSystem.swift          # HIG-compliant design system (NEW)
│   ├── HapticManager.swift         # Haptic feedback system (NEW)
│   ├── TrackViewModel.swift        # MVVM for TrackView (NEW)
│   ├── CampSiteCaptureViewModel.swift  # MVVM for camp site capture (NEW)
│   └── ...
├── Views/                           # SwiftUI views (11 files)
│   ├── StartView.swift             # Home screen (HIG enhanced)
│   ├── TrackView.swift             # Active tracking (telemetry dashboard)
│   ├── EndSummaryView.swift        # Trip summary
│   ├── HistoryView.swift           # Trip history (empty states, badges)
│   ├── CampSiteCaptureView.swift   # Add camp site (icon labels, ratings)
│   ├── CampSiteListView.swift      # Browse camp sites (filters, search)
│   └── ...
└── Services/                        # External integrations (13 files)
    ├── GPSManager.swift            # Core Location wrapper
    ├── MotionManager.swift         # CoreMotion wrapper
    ├── WeatherManager.swift        # WeatherKit wrapper
    ├── FordPassManager.swift       # Ford API (stub)
    └── ...
```

### Data Flow
1. User starts tracking → `TrackView` initializes
2. `GPSManager` starts location updates → feeds `AltitudeFusionEngine`
3. `MotionManager` starts sensor updates → stores snapshots
4. Every 60s → auto-save via `TripStore.saveTempTrip()`
5. User ends trip → `buildTrip()` compiles all data
6. `DifficultyCalculator` runs scoring algorithm
7. Trip saved to `trips.json` → temp file cleared

---

## ✨ Recent Enhancements

Trail Guardian has undergone significant architectural and UX improvements to deliver a **premium, production-ready experience**:

### 🎨 Apple Human Interface Guidelines Implementation
Complete UI/UX overhaul following Apple's official design standards:

#### DesignSystem (`Models/DesignSystem.swift`)
- **8pt Grid Spacing System** - Consistent spacing throughout (xxs: 4pt → xxl: 48pt)
- **Semantic Colors** - Named colors instead of hardcoded values (`Colors.suttonScore`, `Colors.startTrail`, etc.)
- **SF Symbols Constants** - Centralized icon library (`Icons.trail`, `Icons.elevation`, etc.)
- **Button Styles** - PrimaryButtonStyle, SecondaryButtonStyle, TertiaryButtonStyle with 44pt minimum touch targets
- **Reusable Components** - MetricCard, StatusBadge, LoadingIndicator, EmptyStateView, CardModifier
- **Animation Curves** - Standardized timing (quick: 0.2s, standard: 0.3s, slow: 0.5s)

#### Enhanced Views
- **StartView** - Hero icon, weather card, loading states, clear visual hierarchy
- **TrackView** - 3-column MetricCard grid, motion telemetry dashboard, prominent airborne warnings
- **HistoryView** - Beautiful empty states, difficulty badges, SF Symbol stats, swipe-to-delete with haptics
- **CampSiteCaptureView** - Icon labels, visual star ratings, photo count badges, comprehensive accessibility
- **CampSiteListView** - Feature badges (fire/water), smart empty states for search results

#### Accessibility Features
- **VoiceOver Support** - Descriptive labels on all interactive elements
- **44pt Touch Targets** - Meets Apple's minimum size requirement throughout
- **Dynamic Type** - All text uses semantic fonts that scale with user preferences
- **Accessibility Hints** - Contextual hints for disabled states and complex interactions
- **Element Grouping** - Related elements combined for better screen reader navigation

### 🏗️ MVVM Architecture
Professional separation of concerns with dedicated ViewModels:

#### TrackViewModel (`Models/TrackViewModel.swift`)
- **@MainActor** - Ensures all UI updates happen on main thread
- **Auto-save with Cancellation** - Task-based auto-save that properly cancels on view disappear
- **GPS Lock Monitoring** - Published loading state for responsive UI
- **Weather Fetching** - Async weather with timeout handling
- **Crash Recovery** - Restores interrupted trips from temp storage
- **Trip Building** - Compiles GPS points, motion data, difficulty ratings
- **Haptic Integration** - Success feedback on major events (trip completion, 100 Club achievement)

#### CampSiteCaptureViewModel (`Models/CampSiteCaptureViewModel.swift`)
- **@MainActor** - Thread-safe state management
- **Async Photo Processing** - Non-blocking photo loading with progress state
- **Validation with Errors** - Published error messages for UI alerts
- **Compressed Photo Saving** - Automatic compression (saves 70-80% storage)
- **Weather Snapshot** - Captures current conditions at camp site
- **Haptic Feedback** - Success/error feedback on save operations

### 📳 HapticManager
Premium tactile feedback throughout the app:
- **7 Feedback Types** - Light, Medium, Heavy, Success, Warning, Error, Selection
- **Strategic Integration** - Saves, deletions, list edits, achievements, validation errors
- **Consistent Feel** - Unified haptic language across all features
- **File**: `Models/HapticManager.swift`

### 🎯 Interaction Patterns
Following iOS best practices:
- **Loading States** - Consistent indicators for GPS, weather, photos, saving
- **Empty States** - Beautiful, actionable empty states with icons and CTAs
- **Smooth Animations** - Button press (scale to 98%), opacity changes, standard iOS transitions
- **Error Reporting** - User-friendly messages, published errors for UI alerts
- **Haptic Feedback** - Premium tactile responses throughout

### 📊 Enhanced Data Integrity
Comprehensive validation and safety:
- **TripPoint Validation** - `isValidCoordinate`, `isValidAltitude`, `hasFiniteValues`, `isValid`
- **CampSite Validation** - Coordinate, elevation, ratings, photo count checks
- **Pre-save Validation** - Stores refuse invalid data with error messages
- **Load-time Filtering** - Automatically skips corrupted entries
- **NaN/Infinity Protection** - All numeric inputs validated with `.isFinite`
- **Photo Cleanup** - Automatic deletion of orphaned photo files

### 🔒 Thread Safety & Memory Management
Production-grade reliability:
- **@MainActor ViewModels** - All UI updates guaranteed on main thread
- **Task Cancellation** - Proper cleanup on view disappear (auto-save, weather fetching)
- **Weak Self Captures** - Prevents retain cycles in async closures
- **Buffer Limits** - Motion snapshots capped at 7,200 (prevents memory exhaustion)
- **Resource Cleanup** - GPS/motion sensors stopped, timers invalidated, temp files cleared

### 📚 Documentation
Comprehensive guides for development and deployment:
- **HIG_IMPROVEMENTS.md** - Complete design system and UI/UX documentation
- **PRODUCTION_READINESS.md** - Production checklist with testing guide
- **IMPROVEMENTS.md** - Technical hardening and validation details
- **Constants.swift** - Zero magic numbers, all configuration centralized

**For detailed information on the design system and UI improvements, see `HIG_IMPROVEMENTS.md`.**

---

## 🧪 Testing Recommendations

### Core Functionality
- ✅ GPS tracking accuracy (compare to known routes)
- ✅ Motion sensor readings (test on actual trails)
- ✅ Altitude fusion (compare to known elevations)
- ✅ Difficulty scoring (verify with real trail conditions)
- ✅ Auto-save and crash recovery
- ✅ Photo compression (check file sizes)

### Edge Cases
- Low/no GPS signal
- Low battery mode
- App backgrounding/foregrounding
- Device rotation during tracking
- Very long trips (4+ hours)
- Maximum camp site photos (10)

### Unit Tests Needed
Currently no unit tests exist. Priority areas:
- `DifficultyCalculator.calculate()` - scoring edge cases
- `AltitudeFusionEngine.update()` - fusion accuracy
- `Trip` distance/elevation calculations
- `TripStore` save/load operations

---

## ⚙️ Configuration

### Customizing Constants
Edit `Models/Constants.swift` to adjust:
- GPS accuracy thresholds
- Difficulty scoring weights
- Auto-save interval
- Photo compression quality
- Map default location
- And more...

### Changing Personalization
To make the app less personalized:
1. Edit `Models/Constants.swift` → `App.edition`
2. Search project for "Daniel Sutton" and replace
3. Update PDF export footer in `PDFExporter.swift`

### Adding New Vehicle Types
1. Edit `Models/VehicleData.swift` → `VehicleType` enum
2. Add vehicle-specific terrain modes if needed
3. Update `DifficultyCalculator.swift` for vehicle-specific bonuses

---

## 📝 Known Limitations

### iOS 16+ Required
- WeatherKit requires iOS 16.0+
- MapKit features (iOS 17+ get better APIs)

### No Cloud Sync
- All data stored locally on device
- No iCloud sync (future enhancement)

### Limited Vehicle Integration
- FordPass and OBD-II APIs are stubbed
- Manual entry only until API keys added

### Photo Storage
- Photos stored in app's Documents directory
- Deleted app = deleted photos (consider Photo Library integration)

### No Apple Watch App
- SwiftUI code is 80% reusable for watchOS
- Consider as future enhancement

---

## 🎯 Roadmap

### Planned Enhancements
- [ ] iCloud sync for trips and camp sites
- [ ] Apple Watch companion app
- [ ] Offline map tile caching
- [ ] Social features (share trips publicly)
- [ ] Trail library (save favorite routes)
- [ ] Achievement system
- [ ] Yearly stats dashboard
- [ ] Vehicle OBD-II integration
- [ ] FordPass API integration
- [ ] Public campground discovery (Recreation.gov)
- [ ] Weather alerts (NWS API)

---

## 🐛 Troubleshooting

### GPS Not Working
- Check Settings → Privacy → Location Services
- Ensure "Trail Guardian" is set to "Always" or "While Using"
- Try airplane mode off/on to reset GPS

### Weather Not Loading
- Requires active internet connection
- Check Settings → Privacy → Location Services (needed for weather)
- WeatherKit requires Apple ID signed in

### Photos Not Saving
- Check Settings → Privacy → Photos
- Ensure "Trail Guardian" has access

### App Crashes on Launch
- Check that Info.plist has all required privacy keys
- Try deleting and reinstalling

### Auto-Save Not Working
- Check Console for errors
- Temp file location: Documents/temp_active_trip.json
- Timer should fire every 60 seconds

---

## 📄 License & Credits

**Created by**: [Your Name]
**Gift for**: Daniel Sutton
**Christmas**: 2025

This app uses:
- **SwiftUI** - Apple's declarative UI framework
- **MapKit** - Apple's mapping framework
- **CoreLocation** - GPS and location services
- **CoreMotion** - Accelerometer, gyroscope, barometer
- **WeatherKit** - Apple's weather data service
- **PDFKit** - PDF generation
- **PhotosUI** - Photo picker

Inspired by:
- Jeep Trail Rating System
- Wells Trail Rating System (ski slopes)
- U.S. Forest Service Trail Classification

---

## 🙏 Acknowledgments

Special thanks to the off-roading and camping community for trail rating systems and the inspiration behind this app.

Built with ❤️ for trail adventures and wilderness exploration.

---

## 📧 Support

For questions or issues:
1. Check this README first
2. Review the `// TODO:` comments in source files
3. Search for error messages in Console.app
4. Check the Issues section of this repository

---

**Happy Trails! 🏔️🚙🏕️**
