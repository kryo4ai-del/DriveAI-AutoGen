import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var textColor: Color {
        (UIApplication.shared.windows.first?.overrideUserInterfaceStyle == .dark) ? Color.white : Color.black
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(ThemeService().getFont(size: 20))
                .padding()
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .background(StyleService.color(for: AppTheme.light))
                .cornerRadius(DesignSystemModel().cornerRadius)
        }
        .accessibilityLabel("Primary button: \(title)")
    }
}