// MARK: - Models/AgeVerification.swift

import Foundation

enum AgeVerificationStep: Equatable {
    case ageInput
    case ageConfirmation
    case parentalConsent
    case complete
    
    var title: String {
        switch self {
        case .ageInput: return "Schritt 1: Dein Alter"
        case .ageConfirmation: return "Schritt 2: Bestätigung"
        case .parentalConsent: return "Schritt 3: Elternzustimmung"
        case .complete: return "Abgeschlossen"
        }
    }
    
    var stepNumber: Int {
        switch self {
        case .ageInput: return 1
        case .ageConfirmation: return 2
        case .parentalConsent: return 3
        case .complete: return 4
        }
    }
}

struct AgeVerificationState: Equatable {
    var userAge: Int?
    var hasConfirmedAge: Bool = false
    var parentalEmail: String = ""
    var parentalEmailError: String?
    
    // Configuration
    private let minimumIndependentAge = 16
    private let minimumValidAge = 1
    private let maximumValidAge = 120
    
    // MARK: - Computed Properties
    
    var isAgeInputValid: Bool {
        guard let age = userAge else { return false }
        return age >= minimumValidAge && age <= maximumValidAge
    }
    
    var requiresParentalConsent: Bool {
        guard hasConfirmedAge, let age = userAge else { return false }
        return age < minimumIndependentAge
    }
    
    var canProceedFromStep(_ step: AgeVerificationStep) -> Bool {
        switch step {
        case .ageInput:
            return isAgeInputValid
        case .ageConfirmation:
            return hasConfirmedAge
        case .parentalConsent:
            return !parentalEmail.isEmpty && parentalEmailError == nil
        case .complete:
            return true
        }
    }
}