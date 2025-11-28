import SwiftUI

struct BroncoControlView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: DesignSystem.Icons.vehicle)
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            Text("Vehicle controls are disabled in this lightweight demo build.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(DesignSystem.Spacing.md)
    }
}
