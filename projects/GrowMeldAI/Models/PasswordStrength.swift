import Foundation
import SwiftUI

enum PasswordStrength {
    case weak, fair, good, strong
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .fair: return .orange
        case .good: return .yellow
        case .strong: return .green
        }
    }
    
    var label: String {
        switch self {
        case .weak: return NSLocalizedString("auth.password.weak", value: "Weak", comment: "")
        case .fair: return NSLocalizedString("auth.password.fair", value: "Fair", comment: "")
        case .good: return NSLocalizedString("auth.password.good", value: "Good", comment: "")
        case .strong: return NSLocalizedString("auth.password.strong", value: "Strong", comment: "")
        }
    }
}

// Class ValidationService declared in Services/ValidationService.swift
