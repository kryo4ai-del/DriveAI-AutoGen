// ✅ ACCESSIBLE: Full Dynamic Type support
Text(questionText)
    .font(.body)  // ✓ Scales with Dynamic Type
    .lineLimit(nil)  // ✓ Allow text wrapping

Button(action: { submitAnswer() }) {
    Text("Submit")
        .frame(maxWidth: .infinity)
}
.frame(minHeight: 44)  // ✓ Minimum height, but grows with text
.padding()  // ✓ Extra space for large text

// Custom text style that respects Dynamic Type
struct AccessibleHeading: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.headline)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)  // iOS 17+
    }
}