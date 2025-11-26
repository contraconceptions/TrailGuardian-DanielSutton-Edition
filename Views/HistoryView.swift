import SwiftUI

struct HistoryView: View {
    @ObservedObject var store = TripStore.shared
    @State private var showingDeleteAlert = false
    @State private var tripToDelete: Trip?

    var body: some View {
        List {
            ForEach(store.trips) { trip in
                NavigationLink(destination: EndSummaryView(trip: trip)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trip.title)
                            .font(.headline)
                        HStack {
                            Text("Sutton Score: \(trip.difficultyRatings.suttonScore)/100")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                            Spacer()
                            Text(trip.difficultyRatings.wellsRating)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("\(trip.formattedDuration)")
                                .font(.caption)
                            Text("•")
                                .font(.caption)
                            Text(String(format: "%.1f km", trip.totalDistanceKm))
                                .font(.caption)
                            if trip.points.count > 0 {
                                Text("•")
                                    .font(.caption)
                                Text("\(trip.points.count) pts")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(.secondary)
                        Text(trip.startedAt.formatted(date: .abbreviated, time: .short))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        tripToDelete = trip
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("\(Constants.App.edition) Trails")
        .alert("Delete Trip?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                tripToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let trip = tripToDelete {
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