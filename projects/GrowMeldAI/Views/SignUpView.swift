import SwiftUI
import Combine

enum PasswordStrength: Int, CaseIterable {
    case weak = 0
    case fair = 1
    case good = 2
    case strong = 3
    
    var label: String {
        switch self {
        case .weak: return "Weak"
        case .fair: return "Fair"
        case .good: return "Good"
        case .strong: return "Strong"
        }
    }
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .fair: return .orange
        case .good: return .yellow
        case .strong: return .green
        }
    }
}

@MainActor
final class PasswordStrengthEvaluator {
    static let shared = PasswordStrengthEvaluator()
    
    // Precompile regexes once at initialization
    private let uppercaseRegex = try! NSRegularExpression(pattern: "[A-Z]")
    private let numberRegex = try! NSRegularExpression(pattern: "[0-9]")
    private let specialRegex = try! NSRegularExpression(pattern: "[!@#$%^&*()_+\\-=\\[\\]{};':\",./<>?]")
    
    func evaluate(_ password: String) -> PasswordStrength {
        var score = 0
        
        if password.count >= 8 { score += 1 }
        
        let nsPassword = password as NSString
        let range = NSRange(location: 0, length: nsPassword.length)
        
        if uppercaseRegex.firstMatch(in: password, range: range) != nil { score += 1 }
        if numberRegex.firstMatch(in: password, range: range) != nil { score += 1 }
        if specialRegex.firstMatch(in: password, range: range) != nil { score += 1 }
        
        switch score {
        case 0...1: return .weak
        case 2: return .fair
        case 3: return .good
        default: return .strong
        }
    }
}

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var password: String = "" {
        didSet {
            passwordStrength = PasswordStrengthEvaluator.shared.evaluate(password)
        }
    }
    @Published var passwordStrength: PasswordStrength = .weak
}

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            SecureField("Password", text: $viewModel.password)
            
            // Strength indicator updates only when password changes
            HStack {
                ForEach(PasswordStrength.allCases, id: \.self) { strength in
                    Capsule()
                        .fill(strength.color.opacity(viewModel.passwordStrength.rawValue >= strength.rawValue ? 1 : 0.2))
                }
            }
            .frame(height: 4)
            
            Text(viewModel.passwordStrength.label)
                .font(.caption)
                .foregroundColor(viewModel.passwordStrength.color)
        }
    }
}