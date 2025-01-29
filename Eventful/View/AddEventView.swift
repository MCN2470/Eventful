import SwiftUI

struct AddEventView: View {
    @Binding var events: [Event]
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var notes = ""
    @State private var location = "" // Selected location
    @State private var showLocationSearch = false // Show the AppleMapsAutocompleteView

    var isSaveDisabled: Bool {
        endDate <= startDate || title.isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Event Title", text: $title)

                // Start Date Picker
                DatePicker("Start Date & Time", selection: $startDate)
                    .datePickerStyle(.compact)

                // End Date Picker
                DatePicker("End Date & Time", selection: $endDate)
                    .datePickerStyle(.compact)

                TextField("Notes", text: $notes)

                // Location input with a button to open search
                HStack {
                    TextField("Location", text: $location)
                        .disabled(true) // Disable manual typing to enforce search usage
                    Button(action: {
                        showLocationSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newEvent = Event(title: title, startDate: startDate, endDate: endDate, notes: notes, location: location)
                        events.append(newEvent)
                        dismiss()
                    }
                    .disabled(isSaveDisabled)
                }
            }
            .sheet(isPresented: $showLocationSearch) {
                AppleMapsAutocompleteView { selectedLocation in
                    self.location = selectedLocation
                    self.showLocationSearch = false // Close the sheet after selection
                }
            }
        }
    }
}
