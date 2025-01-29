import SwiftUI
import UserNotifications

struct SettingsView: View {
    @State private var notificationsEnabled = false
    @AppStorage("loggedInUsername") private var loggedInUsername: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("User")) {
                Text("Logged in as: \(loggedInUsername)")
            }            
            // Notifications toggle
            Section {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { newValue in
                        toggleNotifications(enabled: newValue)
                    }
            }
            
            // Logout button
            Section {
                Button("Logout") {
                    loggedInUsername = "" // Clear the username
                }
                .foregroundColor(.red)
            }
        }
        .onAppear {
            // Check current notification settings
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    notificationsEnabled = (settings.authorizationStatus == .authorized)
                }
            }
        }
        .navigationTitle("Settings")
    }
    
    // Function to enable or disable notifications
    func toggleNotifications(enabled: Bool) {
        if enabled {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    notificationsEnabled = granted
                }
            }
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
}
