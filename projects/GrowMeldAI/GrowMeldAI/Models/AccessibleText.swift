// Features/Shared/Components/AccessibleText.swift
struct AccessibleText: View {
    let text: String
    let fontSize: Font
    let isImportant: Bool
    
    var body: some View {
        Text(text)
            .font(fontSize)
            .dynamicTypeSize(.xSmall ... .xxxLarge)  // Respect system text size
            .accessibilityAddTraits(isImportant ? .isHeader : [])
            .accessibilityLabel(text)
            .foregroundColor(.primary)  // Accessible default color
    }
}

// Features/Question/Views/AnswerOption.swift
struct AnswerOption: View {
    let text: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool?
    let onSelect: (Int) -> Void
    
    var body: some View {
        Button(action: { onSelect(index) }) {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(backgroundColor)
                .cornerRadius(8)
        }
        .accessibilityElement()
        .accessibilityLabel("Option \(index + 1)")
        .accessibilityValue(text)
        .accessibilityHint(isCorrect == true ? "Richtig!" : (isCorrect == false ? "Falsch" : ""))
        .accessibilityAddTraits(.isButton)
    }
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green.opacity(0.2) : .red.opacity(0.2)
        }
        return isSelected ? .blue.opacity(0.2) : .gray.opacity(0.1)
    }
}