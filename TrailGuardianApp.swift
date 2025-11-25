import SwiftUI

@main
struct TrailGuardianApp: App {
    var body: some Scene {
        WindowGroup {
            StartView()
                .preferredColorScheme(.automatic)
        }
    }
}