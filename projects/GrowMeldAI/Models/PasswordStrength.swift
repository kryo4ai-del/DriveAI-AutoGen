// Core/Utilities/ValidationService.swift (add)

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

extension ValidationService {
    // Precompile regexes once
    private static let uppercaseRegex = try! NSRegularExpression(pattern: "[A-Z]")
    private static let numberRegex = try! NSRegularExpression(pattern: "[0-9]")
    private static let specialRegex = try! NSRegularExpression(pattern: "[!@#$%^&*()_+\\-=\\[\\]{};':\",./<>?]")
    
    func evaluatePasswordStrength(_ password: String) -> PasswordStrength {
        var score = 0
        
        if password.count >= 8 { score += 1 }
        
        let nsPassword = password as NSString
        let range = NSRange(location: 0, length: nsPassword.length)
        
        if Self.uppercaseRegex.firstMatch(in: password, range: range) != nil { score += 1 }
        if Self.numberRegex.firstMatch(in: password, range: range) != nil { score += 1 }
        if Self.specialRegex.firstMatch(in: password, range: range) != nil { score += 1 }
        
        switch score {
        case 0...1: return .weak
        case 2: return .fair
        case 3: return .good
        default: return .strong
        }
    }
}

// SignUpViewModel (refactored)
@MainActor