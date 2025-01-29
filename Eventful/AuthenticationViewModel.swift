import FirebaseAuth
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var errorMessage: String?

    // Register a new user
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                print("Error registering: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.errorMessage = nil
            }
            print("User registered successfully!")
        }
    }

    // Login an existing user
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                print("Error logging in: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.errorMessage = nil
            }
            print("User logged in successfully!")
        }
    }

    // Logout the user
    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
            print("User logged out successfully!")
        } catch let error {
            print("Error logging out: \(error.localizedDescription)")
        }
    }
}
