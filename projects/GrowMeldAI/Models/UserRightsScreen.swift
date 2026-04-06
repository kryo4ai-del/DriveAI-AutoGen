struct UserRightsScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Right to Access (Article 15)
                ActionButton(
                    title: NSLocalizedString("rights.access.button", comment: ""),
                    icon: "arrow.down.doc.fill",
                    style: .primary
                ) {
                    // Export data
                }
                
                // Right to Deletion (Article 17)
                ActionButton(
                    title: NSLocalizedString("rights.delete.button", comment: ""),
                    icon: "trash.fill",
                    style: .destructive
                ) {
                    // Delete account
                }
                
                // Right to Object (Article 21)
                ActionButton(
                    title: NSLocalizedString("rights.object.button", comment: ""),
                    icon: "hand.raised.fill",
                    style: .secondary
                ) {
                    // Revoke non-essential consents
                }
            }
            .padding()
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let style: ActionStyle
    let action: () -> Void
    
    enum ActionStyle {
        case primary, secondary, destructive
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(title)
                    .font(.system(.body, design: .default))
                    .dynamicallyScaled()
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .frame(minHeight: 44)  // ✅ Minimum touch target
            .contentShape(Rectangle())  // Entire area tappable
        }
        .buttonStyle(AccessibleActionButtonStyle(style: style))
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(accessibilityHintForStyle(style)))
    }
    
    private func accessibilityHintForStyle(_ style: ActionStyle) -> String {
        switch style {
        case .primary:
            return NSLocalizedString("rights.hint.primary", comment: "Export your data")
        case .secondary:
            return NSLocalizedString("rights.hint.secondary", comment: "Manage your preferences")
        case .destructive:
            return NSLocalizedString("rights.hint.destructive", comment: "This action cannot be undone")
        }
    }
}

struct AccessibleActionButtonStyle: ButtonStyle {
    let style: ActionButton.ActionStyle
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(8)
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return .blue
        case .secondary: return Color(.systemGray5)
        case .destructive: return .red
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary: return .black
        }
    }
}