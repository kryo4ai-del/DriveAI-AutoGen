import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var cornerRadius: CGFloat = 8

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? backgroundColor.opacity(0.6) : backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring())
    }
}