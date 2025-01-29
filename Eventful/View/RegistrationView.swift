import SwiftUI

struct RegistrationView: View {
    @State private var username = ""
    @AppStorage("loggedInUsername") private var loggedInUsername: String = ""
    @Binding var showMainApp: Bool
    @Environment(\.presentationMode) var presentationMode // For dismissing the view

    var body: some View {
        VStack {
            Text("Register for Eventful")
                .font(.largeTitle)
                .padding()

            TextField("Choose a username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)

            Button(action: {
                guard !username.isEmpty else { return }
                loggedInUsername = username
                showMainApp = true // Navigate to the main app
            }) {
                Text("Register")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Button(action: {
                // Dismiss the RegistrationView to go back to LoginView
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }
}
