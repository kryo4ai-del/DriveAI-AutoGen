import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    var errorMessage: String?

    var body: some View {
        VStack {
            TextField(placeholder, text: $text)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(DesignSystemModel().cornerRadius)
                .font(ThemeService().getFont(size: 16))
                .overlay(RoundedRectangle(cornerRadius: DesignSystemModel().cornerRadius)
                    .stroke(errorMessage != nil ? Color.red : Color.clear, lineWidth: 1))
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 5)
            }
        }
        .accessibilityLabel("Text field for \(placeholder)")
    }
}