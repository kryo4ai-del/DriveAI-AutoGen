// Add this modifier during development to visualize touch areas
struct AccessibilityPreview: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red, lineWidth: 1)
            )
            .frame(minHeight: 44)  // Ensure min height visible
    }
}

// Apply during testing:
AnswerOptionView(option: "A", text: "Test")
    .modifier(AccessibilityPreview())