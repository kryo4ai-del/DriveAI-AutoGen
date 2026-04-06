import SwiftUI

/// Ensures minimum 44x44pt touch target with visual feedback
struct AccessibleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())  // Expand tap area
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

// Usage:
Button("Back") { dismiss() }
    .buttonStyle(AccessibleButtonStyle())

// Or with custom styling:
Button(action: onTap) {
    Image(systemName: "xmark")
        .font(.headline)
}
.buttonStyle(AccessibleButtonStyle())
.frame(width: 44, height: 44)  // Explicit minimum