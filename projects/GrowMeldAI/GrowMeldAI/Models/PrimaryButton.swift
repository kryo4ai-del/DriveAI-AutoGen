import SwiftUI

struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    @Environment(\.colorPalette) private var palette
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.md) {
                if isLoading {
                    ProgressView()
                        .tint(palette.background)
                }
                
                Text(title)
                    .font(DesignTokens.Typography.bodyBold)
                    .frame(maxWidth: .infinity)
            }
            .foregroundColor(palette.background)
            .padding(.vertical, DesignTokens.Spacing.md)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .background(
                isEnabled ? palette.primary : palette.textTertiary
            )
            .cornerRadius(DesignTokens.Radius.md)
        }
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.6)
        .accessibilityLabel(title)
        .accessibilityHint(isLoading ? "Loading" : nil)
    }
}

#Preview {
    VStack(spacing: DesignTokens.Spacing.lg) {
        PrimaryButton(title: "Continue", isLoading: false, isEnabled: true, action: {})
        PrimaryButton(title: "Loading", isLoading: true, isEnabled: false, action: {})
        PrimaryButton(title: "Disabled", isLoading: false, isEnabled: false, action: {})
    }
    .padding(DesignTokens.Spacing.lg)
    .background(ColorPalette.current.background)
}