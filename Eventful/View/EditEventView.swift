import SwiftUI

struct EditEventView: View {
    @Binding var events: [Event]
    var index: Int
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var notes: String
    @State private var location: String 

    var isSaveDisabled: Bool {
        endDate <= startDate || title.isEmpty
    }

    init(events: Binding<[Event]>, index: Int) {
        self._events = events
        self.index = index
        self._title = State(initialValue: events.wrappedValue[index].title)
        self._startDate = State(initialValue: events.wrappedValue[index].startDate)
        self._endDate = State(initialValue: events.wrappedValue[index].endDate)
        self._notes = State(initialValue: events.wrappedValue[index].notes)
        self._location = State(initialValue: events.wrappedValue[index].location)
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

                // Free-form location input
                TextField("Location", text: $location)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
            }
            .navigationTitle("Edit Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        events[index].title = title
                        events[index].startDate = startDate
                        events[index].endDate = endDate
                        events[index].notes = notes
                        events[index].location = location
                        dismiss()
                    }
                    .disabled(isSaveDisabled)
                }
            }
        }
    }
}
