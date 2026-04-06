struct PasswordStrengthIndicator: View {
    let strength: SignUpFormViewModel.PasswordStrength
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                // ✅ Icon + Text, not color alone
                Image(systemName: strength.iconName)
                    .foregroundColor(strength.color)
                    .font(.caption.bold())
                
                Text(strength.label)
                    .font(.caption.bold())
                    .foregroundColor(strength.color)
                
                Spacer()
            }
            
            // ✅ Visual progress bar with high contrast
            ProgressView(value: Double(strength.rawValue), total: 3)
                .tint(strength.color)
                .accessibilityLabel("Passwort-Stärke")
                .accessibilityValue(strength.label)
                .accessibilityHint(strength.hint)
        }
        .padding(.horizontal)
    }
}

// Add to PasswordStrength enum:
extension SignUpFormViewModel.PasswordStrength {
    var iconName: String {
        switch self {
        case .weak: return "exclamationmark.circle.fill"
        case .fair: return "info.circle.fill"
        case .strong: return "checkmark.circle.fill"
        }
    }
    
    var hint: String {
        switch self {
        case .weak: return "Großbuchstaben, Kleinbuchstaben und Zahlen erforderlich"
        case .fair: return "Gut, aber ein Sonderzeichen würde helfen"
        case .strong: return "Sehr sicher"
        }
    }
}