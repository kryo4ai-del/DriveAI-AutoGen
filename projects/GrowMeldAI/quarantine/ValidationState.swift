enum ValidationState {
    case empty
    case invalid(reason: String)  // "Missing @domain"
    case valid
}

@Published var emailValidation: ValidationState = .empty

var emailFeedbackText: String? {
    switch emailValidation {
    case .empty: return nil
    case .invalid(let reason): return "✗ " + reason  // Visible immediately
    case .valid: return "✓"  // Confidence signal
    }
}

// In SignUpView, below email field:
if let feedback = viewModel.emailFeedbackText {
    Text(feedback)
        .font(.caption)
        .foregroundColor(viewModel.emailValidation == .valid ? .green : .red)
        .transition(.opacity)
}