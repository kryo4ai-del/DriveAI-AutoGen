struct QuestionContentView: View {
    let question: Question
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.text)
                .font(.body)  // ✅ Automatically scales with Dynamic Type
                .lineLimit(nil)  // Allow unlimited lines
                .fixedSize(horizontal: false, vertical: true)  // Expand container as needed
                .padding(.vertical)
            
            // Optional: Add text size indicator for accessibility
            if sizeCategory >= .extraLarge {
                Text("Textvergrößerung ist aktiv")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)  // Redundant info
            }
        }
    }
}