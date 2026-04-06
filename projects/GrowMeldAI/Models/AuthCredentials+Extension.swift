extension AuthCredentials {
    var validationError: AuthError? {
        guard !email.isEmpty else { return .invalidEmail }
        guard email.contains("@") && email.contains(".") else { 
            return .invalidEmail 
        }
        guard password.count >= 6 else { return .weakPassword }
        return nil
    }
    
    // For UI feedback
    var isValid: Bool {
        validationError == nil
    }
}