import SwiftUI

struct EmergencyView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Emergency quick tips")
                .font(.largeTitle.bold())
            Text("This lightweight build focuses on easy compilation. Add your own local emergency contacts once you move back to the full project.")
                .foregroundColor(.secondary)
            List {
                Label("Share your location before you leave signal", systemImage: "exclamationmark.triangle")
                Label("Pack extra water and layers", systemImage: "drop.fill")
                Label("Keep a paper map in the glovebox", systemImage: "map")
            }
        }
        .padding(DesignSystem.Spacing.md)
    }
}
