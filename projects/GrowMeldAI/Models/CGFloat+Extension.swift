// ✅ FIXED:
Text(question.text)
    .font(.system(.body, design: .default))  // Relative size
    .dynamicTypeSize(.small ... .xxxLarge)   // Support full range
    .lineLimit(nil)                           // Allow unlimited lines

VStack(spacing: .spacingForDynamicType) {    // Adaptive spacing
    AnswerButton(...)
}

Button(action: {}) {
    Text("Next")
}
.frame(minHeight: 44)  // Minimum, not fixed

// Create adaptive spacing helper:
extension CGFloat {
    static let spacingForDynamicType: CGFloat = {
        let size = UIFont.preferredFont(forTextStyle: .body).pointSize
        return 12 + (size / 18)  // Scale with Dynamic Type
    }()
}