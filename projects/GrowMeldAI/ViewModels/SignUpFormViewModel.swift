// ✅ FIXED: SignUpFormViewModel.swift

import Foundation
import SwiftUI
import Combine

@MainActor
final class SignUpFormViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var agreedToTerms: Bool = false
    
    @Published var passwordStrength: PasswordStrength = .weak
    @Published var formErrors: [FormField: String] = [:]
    @Published var isTouched: Set<FormField> = []
    
    enum FormField: String, CaseIterable, Hashable {
        case email, password, confirmPassword, terms
    }
    
    enum PasswordStrength: Int, Comparable {
        case weak = 1
        case fair = 2
        case strong = 3
        
        static func < (lhs: PasswordStrength, rhs: PasswordStrength) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
        
        var color: String {
            switch self {
            case .weak: return "red"
            case .fair: return "orange"
            case .strong: return "green"
            }
        }
        
        var label: String {
            switch self {
            case .weak: return "Schwach"
            case .fair: return "Mittel"
            case .strong: return "Stark"
            }
        }
    }
    
    // MARK: - Validation
    
    func validateField(_ field: FormField) {
        isTouched.insert(field)
        
        switch field {
        case .email:
            validateEmail()
        case .password:
            validatePassword()
        case .confirmPassword:
            validateConfirmPassword()
        case .terms:
            validateTerms()
        }
    }
    
    func validateForm() -> Bool {
        // Clear previous errors
        formErrors.removeAll()
        
        // Validate all fields
        FormField.allCases.forEach { validateField($0) }
        
        return formErrors.isEmpty
    }
    
    private func validateEmail() {
        formErrors.removeValue(forKey: .email)
        
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            formErrors[.email] = "Email erforderlich"
            return
        }
        
        let emailRegex = "^[^@]+@[^@]+\\.[^@]{2,}$"
        guard trimmed.range(of: emailRegex, options: .regularExpression) != nil else {
            formErrors[.email] = "Ungültige Email-Adresse"
            return
        }
    }
    
    private func validatePassword() {
        formErrors.removeValue(forKey: .password)
        passwordStrength = evaluatePasswordStrength(password)
        
        if password.count < 8 {
            formErrors[.password] = "Mindestens 8 Zeichen erforderlich"
            return
        }
        
        if passwordStrength == .weak {
            formErrors[.password] = "Großbuchstaben, Kleinbuchstaben und Zahlen erforderlich"
        }
    }
    
    private func validateConfirmPassword() {
        formErrors.removeValue(forKey: .confirmPassword)
        
        guard !confirmPassword.isEmpty else {
            formErrors[.confirmPassword] = "Bestätigung erforderlich"
            return
        }
        
        guard password == confirmPassword else {
            formErrors[.confirmPassword] = "Passwörter stimmen nicht überein"
            return
        }
    }
    
    private func validateTerms() {
        formErrors.removeValue(forKey: .terms)
        
        if !agreedToTerms {
            formErrors[.terms] = "Sie müssen den Bedingungen zustimmen"
        }
    }
    
    // MARK: - Password Strength Evaluation
    
    private func evaluatePasswordStrength(_ pwd: String) -> PasswordStrength {
        var score = 0
        
        if pwd.count >= 8 { score += 1 }
        if pwd.count >= 12 { score += 1 }
        if pwd.range(of: "[A-Z]", options: .regularExpression) != nil { score += 1 }
        if pwd.range(of: "[a-z]", options: .regularExpression) != nil { score += 1 }
        if pwd.range(of: "[0-9]", options: .regularExpression) != nil { score += 1 }
        if pwd.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil { score += 1 }
        
        switch score {
        case 0...2: return .weak
        case 3...4: return .fair
        default: return .strong
        }
    }
    
    // MARK: - Error Messages
    
    func errorMessage(for field: FormField) -> String? {
        isTouched.contains(field) ? formErrors[field] : nil
    }
    
    func hasError(for field: FormField) -> Bool {
        errorMessage(for: field) != nil
    }
    
    // MARK: - Reset
    
    func reset() {
        email = ""
        password = ""
        confirmPassword = ""
        agreedToTerms = false
        formErrors.removeAll()
        isTouched.removeAll()
        passwordStrength = .weak
    }
}