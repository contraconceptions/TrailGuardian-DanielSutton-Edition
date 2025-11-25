import SwiftUI
import MessageUI

struct EmergencyView: View {
    @ObservedObject var kitStore = EmergencyKitStore.shared
    @ObservedObject var gps = GPSManager.shared
    @State private var showingContactEditor = false
    @State private var showingLocationShare = false
    @State private var shareItems: [Any] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Emergency Contacts
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Emergency Contacts")
                                .font(.headline)
                            Spacer()
                            Button("Add") {
                                showingContactEditor = true
                            }
                        }
                        
                        if kitStore.kit.contacts.isEmpty {
                            Text("No emergency contacts added")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(kitStore.kit.contacts) { contact in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(contact.name)
                                            .font(.headline)
                                        if !contact.relationship.isEmpty {
                                            Text(contact.relationship)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Text(contact.phoneNumber)
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    Spacer()
                                    if let url = URL(string: "tel://\(contact.phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: ""))") {
                                        Link(destination: url) {
                                            Image(systemName: "phone.fill")
                                                .foregroundColor(.green)
                                                .font(.title2)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    
                    // Share Location
                    Button {
                        shareLocation()
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Share My Location")
                        }
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Emergency Checklist
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Emergency Checklist")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ChecklistItem(title: "Stay calm and assess situation")
                        ChecklistItem(title: "Ensure personal safety first")
                        ChecklistItem(title: "Call emergency services if needed")
                        ChecklistItem(title: "Share location with contacts")
                        ChecklistItem(title: "Conserve phone battery")
                        ChecklistItem(title: "Stay visible if lost")
                        ChecklistItem(title: "Find or create shelter")
                        ChecklistItem(title: "Signal for help if possible")
                    }
                    .padding()
                    
                    // Survival Tips
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Survival Tips")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TipCard(title: "Water", content: "Find water sources: streams, rivers, collect rainwater. Purify if possible.")
                        TipCard(title: "Shelter", content: "Protect from elements. Use natural materials or your gear.")
                        TipCard(title: "Fire", content: "Fire provides warmth, light, and can signal for help.")
                        TipCard(title: "Signaling", content: "Use mirrors, bright colors, smoke, or sounds to attract attention.")
                        TipCard(title: "Navigation", content: "Stay put if lost. Use landmarks and natural navigation if moving.")
                    }
                    .padding()
                }
            }
            .navigationTitle("Emergency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss handled by sheet
                    }
                }
            }
            .sheet(isPresented: $showingContactEditor) {
                EmergencyContactEditorView()
            }
            .sheet(isPresented: $showingLocationShare) {
                ShareSheet(items: shareItems)
            }
        }
    }
    
    private func shareLocation() {
        guard let location = gps.currentLocation else { return }
        let coordinateString = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        let message = "EMERGENCY: My current location\nCoordinates: \(coordinateString)\nGoogle Maps: https://www.google.com/maps?q=\(coordinateString)\nTime: \(Date().formatted(date: .long, time: .complete))"
        shareItems = [message]
        showingLocationShare = true
    }
}

struct ChecklistItem: View {
    let title: String
    @State private var isChecked = false
    
    var body: some View {
        HStack {
            Button {
                isChecked.toggle()
            } label: {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? .green : .gray)
            }
            Text(title)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct TipCard: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.bold())
            Text(content)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct EmergencyContactEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var kitStore = EmergencyKitStore.shared
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var relationship: String = ""
    @State private var isPrimary: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                TextField("Relationship", text: $relationship)
                Toggle("Primary Contact", isOn: $isPrimary)
            }
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let contact = EmergencyContact(
                            name: name,
                            phoneNumber: phoneNumber,
                            relationship: relationship,
                            isPrimary: isPrimary
                        )
                        kitStore.kit.contacts.append(contact)
                        kitStore.save()
                        dismiss()
                    }
                    .disabled(name.isEmpty || phoneNumber.isEmpty)
                }
            }
        }
    }
}

