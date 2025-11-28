import SwiftUI

struct CampSiteCaptureView: View {
    var onSave: ((SampleCampSite) -> Void)?

    @State private var name: String = ""
    @State private var notes: String = ""

    var body: some View {
        Form {
            Section(header: Text("Quick camp note")) {
                TextField("Name", text: $name)
                TextField("Notes", text: $notes)
            }
            Button("Save sample site") {
                let site = SampleCampSite(
                    name: name.isEmpty ? "New Camp" : name,
                    notes: notes.isEmpty ? "Remember to add details later." : notes,
                    location: SampleData().campSites.first!.location
                )
                onSave?(site)
            }
        }
        .navigationTitle("Capture Camp")
    }
}
