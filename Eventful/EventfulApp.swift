import SwiftUI
import Firebase

@main
struct EventfulApp: App {
    init() {
           FirebaseApp.configure()
       }
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
