import SwiftUI

struct EventsView: View {
    @State private var events: [Event] = [
        Event(title: "Meeting with Client", startDate: Date(), endDate: Date().addingTimeInterval(3600), notes: "Discuss project milestones", location: "Hong Kong"),
        Event(title: "Birthday Party", startDate: Date().addingTimeInterval(86400), endDate: Date().addingTimeInterval(90000), notes: "Bring a gift!", location: "Tuen Mun")
    ]
    @State private var showAuthErrorAlert = false
    @State private var alertMessage = ""
    @State private var selectedEventIndex: Int? // Holds the index of the selected event
    @State private var showEditEventView = false // Controls the EditEventView sheet
    @State private var showAddEventView = false // Controls the AddEventView sheet

    var body: some View {
        NavigationView {
            List {
                ForEach(events.indices, id: \.self) { index in
                    let event = events[index]
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.headline)
                        Text("Location: \(event.location)")
                            .font(.subheadline)

                        // Button to view route in the Map Tab
                        Button("View Route in Map") {
                            print("Open MapTabView to show route to: \(event.location)")
                        }
                        .foregroundColor(.blue)
                    }
                    .swipeActions {
                        // Modify Action
                        Button {
                            authenticateForModify {
                                selectedEventIndex = index // Save the index of the event to modify
                                showEditEventView = true // Show EditEventView
                            }
                        } label: {
                            Label("Modify", systemImage: "pencil")
                        }
                        .tint(.blue)

                        // Delete Action
                        Button(role: .destructive) {
                            authenticateForDelete {
                                deleteEvent(event: event)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Your Events")
            .toolbar {
                // Add Button in the navigation bar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddEventView = true // Show the AddEventView
                    }) {
                        Label("Add Event", systemImage: "plus")
                    }
                }
            }
            .alert("Authentication Failed", isPresented: $showAuthErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showEditEventView) {
                if let index = selectedEventIndex {
                    EditEventView(events: $events, index: index) // Pass events and index to EditEventView
                }
            }
            .sheet(isPresented: $showAddEventView) {
                AddEventView(events: $events) // Pass the events array to AddEventView
            }
        }
    }

    // Deletes an event from the list
    func deleteEvent(event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            withAnimation {
                events.remove(at: index)
            }
        } else {
            alertMessage = "Unable to find the event to delete."
            showAuthErrorAlert = true
        }
    }

    // Biometric authentication for delete
    func authenticateForDelete(successAction: @escaping () -> Void) {
        BiometricAuthenticator.authenticateUser { success, errorMessage in
            if success {
                successAction()
            } else {
                alertMessage = errorMessage ?? "Authentication failed."
                showAuthErrorAlert = true
            }
        }
    }

    // Biometric authentication for modify
    func authenticateForModify(successAction: @escaping () -> Void) {
        BiometricAuthenticator.authenticateUser { success, errorMessage in
            if success {
                successAction()
            } else {
                alertMessage = errorMessage ?? "Authentication failed."
                showAuthErrorAlert = true
            }
        }
    }
}
