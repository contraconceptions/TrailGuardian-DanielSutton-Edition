import SwiftUI

struct HistoryView: View {
    @ObservedObject var store = TripStore.shared
    
    var body: some View {
        List(store.trips) { trip in
            NavigationLink(destination: EndSummaryView(trip: trip)) {
                VStack(alignment: .leading) {
                    Text(trip.title)
                        .font(.headline)
                    Text("Score: \(trip.difficultyRatings.suttonScore)/100")
                        .foregroundColor(.secondary)
                    Text(trip.startedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Daniel's Epic Trails")
    }
}