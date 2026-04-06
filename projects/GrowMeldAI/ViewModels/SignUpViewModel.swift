@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var passwordStrengthValue: PasswordStrength = .weak
    
    var passwordStrength: PasswordStrength {
        passwordStrengthValue
    }
    
    func updatePasswordStrength() {
        passwordStrengthValue = ValidationService.shared.evaluatePasswordStrength(password)
    }
}

// In View:
.onChange(of: viewModel.password) { _ in
    viewModel.updatePasswordStrength()
}