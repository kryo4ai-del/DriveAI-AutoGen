// Models/AuthValidator.swift
import Foundation

enum AuthValidator {
    static func validateEmail(_ email: String) -> AuthError? {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else {
            return .invalidEmail
        }
        
        // RFC 5322 simplified pattern
        let pattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return .invalidEmail
        }
        
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        guard regex.firstMatch(in: trimmed, range: range) != nil else {
            return .invalidEmail
        }
        
        return nil
    }
    
    static func validatePassword(_ password: String) -> AuthError? {
        guard password.count >= 8 else {
            return .weakPassword
        }
        
        let hasUppercase = password.contains { $0.isUppercase }
        let hasLowercase = password.contains { $0.isLowercase }
        let hasNumber = password.contains { $0.isNumber }
        let hasSpecial = password.contains { "!@#$%^&*()_+-=[]{}|;:',.<>?/~`".contains($0) }
        
        guard hasUppercase, hasLowercase, hasNumber, hasSpecial else {
            return .weakPassword
        }
        
        return nil
    }
}