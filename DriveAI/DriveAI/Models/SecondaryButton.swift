import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var textColor: Color {
        (UIApplication.shared.windows.first?.overrideUserInterfaceStyle == .dark) ? Color.blue : Color.blue.opacity(0.8)
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(ThemeService().getFont(size: 16))
                .padding()
                .foregroundColor(textColor)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystemModel().cornerRadius)
                        .stroke(textColor, lineWidth: 2)
                )
                .background(Color.clear)
        }
        .accessibilityLabel("Secondary button: \(title)")
    }
}