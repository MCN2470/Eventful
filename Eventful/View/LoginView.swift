import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @AppStorage("loggedInUsername") private var loggedInUsername: String = ""
    @State private var showMainApp = false
    @State private var showRegistration = false

    var body: some View {
        if showMainApp {
            EventfulAppView() // Navigate to the main app
        } else {
            VStack {
                Text("Welcome to Eventful")
                    .font(.largeTitle)
                    .padding()

                TextField("Enter your username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)

                Button(action: {
                    guard !username.isEmpty else { return }
                    loggedInUsername = username
                    showMainApp = true
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                Button(action: {
                    showRegistration = true
                }) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .padding()
            .fullScreenCover(isPresented: $showRegistration) {
                RegistrationView(showMainApp: $showMainApp) // Pass binding to navigate to the main app
            }
        }
    }
}
