import SwiftUI

struct HistoryView: View {
    @ObservedObject var store = TripStore.shared
    @State private var showingDeleteAlert = false
    @State private var tripToDelete: Trip?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Group {
            if store.trips.isEmpty {
                EmptyStateView(
                    icon: DesignSystem.Icons.history,
                    title: "No Trails Yet",
                    message: "Start your first trail to see it appear here. Your adventure awaits!",
                    actionTitle: "Start New Trail",
                    action: { dismiss() }
                )
            } else {
                List {
                    ForEach(store.trips) { trip in
                        NavigationLink(destination: EndSummaryView(trip: trip)) {
                            TripRowView(trip: trip)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                HapticManager.shared.warning()
                                tripToDelete = trip
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: DesignSystem.Icons.delete)
                            }
                        }
                        .accessibilityLabel("Trip: \(trip.title), Sutton Score: \(trip.difficultyRatings.suttonScore)")
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("\(Constants.App.edition) Trails")
        .alert("Delete Trip?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                tripToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let trip = tripToDelete {
                    HapticManager.shared.success()
                    store.delete(trip)
                    // Clean up temp trip if it matches
                    if let tempTrip = store.loadTempTrip(), tempTrip.id == trip.id {
                        store.clearTempTrip()
                    }
                }
                tripToDelete = nil
            }
        } message: {
            if let trip = tripToDelete {
                Text("Are you sure you want to delete '\(trip.title)'? This cannot be undone.")
            }
        }
    }
}

/// Trip row component with improved visual hierarchy
struct TripRowView: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            // Title
            Text(trip.title)
                .font(.headline)

            // Difficulty badges
            HStack(spacing: DesignSystem.Spacing.xs) {
                StatusBadge(
                    "Sutton \(trip.difficultyRatings.suttonScore)/100",
                    color: DesignSystem.Colors.suttonScore,
                    icon: DesignSystem.Icons.difficulty
                )

                StatusBadge(
                    trip.difficultyRatings.wellsRating,
                    color: .blue
                )

                Spacer()
            }

            // Stats
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Label(trip.formattedDuration, systemImage: "clock")
                    .font(.caption)

                Text("•")
                    .font(.caption)

                Label(String(format: "%.1f km", trip.totalDistanceKm), systemImage: "arrow.triangle.turn.up.right.diamond")
                    .font(.caption)

                if trip.points.count > 0 {
                    Text("•")
                        .font(.caption)
                    Text("\(trip.points.count) pts")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)

            // Date
            Text(trip.startedAt.formatted(date: .abbreviated, time: .short))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, DesignSystem.Spacing.xxs)
    }
}
