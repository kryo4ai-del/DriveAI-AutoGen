import SwiftUI

struct SecondaryButton: View {
    let title: String?
    let action: () -> Void
    var isEnabled: Bool = true
    var icon: String? = nil
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            action()
        }) {
            HStack(spacing: AppTheme.Spacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                if let title {
                    Text(title)
                        .font(AppTheme.Typography.button)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Spacing.buttonHeight)
            .foregroundColor(AppTheme.Colors.primary)
            .background(AppTheme.Colors.surfaceSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
        }
        .disabled(!isEnabled)
        .buttonStyle(DriveAISecondaryButtonStyle())
        .accessibilityLabel(title ?? (icon.map { Icon(systemName: $0).label } ?? "Button"))
        .accessibilityAddTraits(isEnabled ? [] : .isNotEnabled)
    }
}

struct DriveAISecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.lg) {
        SecondaryButton(title: "Abbrechen") { }
        SecondaryButton(title: nil, icon: "xmark") { }
        SecondaryButton(title: "Mit Icon", icon: "arrow.left") { }
        SecondaryButton(title: "Deaktiviert", isEnabled: false) { }
    }
    .padding(AppTheme.Spacing.lg)
}