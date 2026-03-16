import SwiftUI
struct AnswerButtonView: View {
    let label: String
    var isSelected: Bool = false
    var isCorrect: Bool = false
    var showFeedback: Bool = false
    var answerIndex: Int = 0

    var body: some View {
        Button(action: {}) {
            Text(label)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 56) // ✅ Well above 44pt minimum
                .padding(.vertical, 12) // ✅ Ensures spacing
        }
        .accessibilityElement(children: .combine)
    }
}

// In Previews:
#Preview {
    VStack(spacing: 16) {
        AnswerButtonView(label: "Test", isSelected: false, isCorrect: false, showFeedback: false, answerIndex: 0)
            .frame(maxWidth: .infinity)
            .environment(\.sizeCategory, .large)
            .previewLayout(.fixed(width: 375, height: 100))
        
        // Test with accessibility inspector:
        // 1. Select Preview
        // 2. Cmd+Option+A → Accessibility Inspector
        // 3. Click each element, check "Frame" readout
        // 4. Verify all interactive: ≥44×44
    }
}