import LocalAuthentication

struct BiometricAuthenticator {
    static func authenticateUser(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?

        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to modify or delete an event."

            // Perform biometric authentication
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil) // Authentication succeeded
                    } else {
                        let message = authenticationError?.localizedDescription ?? "Authentication failed."
                        completion(false, message) // Authentication failed
                    }
                }
            }
        } else {
            // Biometric authentication is not available
            let message = error?.localizedDescription ?? "Biometric authentication is not available on this device."
            DispatchQueue.main.async {
                completion(false, message) // Return failure with a message
            }
        }
    }
}
