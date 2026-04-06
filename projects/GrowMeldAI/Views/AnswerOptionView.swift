import SwiftUI

struct AnswerOptionView: View {
    let text: String
    let isCorrect: Bool
    let userSelected: Bool
    let isAnswered: Bool

    var body: some View {
        HStack(spacing: 12) {
            if isAnswered {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .accessibilityLabel(statusLabel)
                    .accessibilityHidden(false)
            }

            Text(text)
                .font(.body)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Answer option: \(text)")
        .accessibilityHint(accessibilityHint)
    }

    private var statusIcon: String {
        if userSelected && isCorrect { return "checkmark.circle.fill" }
        if userSelected && !isCorrect { return "xmark.circle.fill" }
        if isCorrect { return "checkmark.circle.fill" }
        return "circle"
    }

    private var statusColor: Color {
        if userSelected && isCorrect { return .green }
        if userSelected && !isCorrect { return .red }
        if isCorrect { return .green }
        return .gray
    }

    private var statusLabel: String {
        if userSelected && isCorrect { return "Correct" }
        if userSelected && !isCorrect { return "Incorrect" }
        if isCorrect { return "Correct answer" }
        return ""
    }

    private var accessibilityHint: String {
        guard isAnswered else { return "" }
        if userSelected && isCorrect { return "You selected this. It is correct." }
        if userSelected && !isCorrect { return "You selected this. It is incorrect." }
        if isCorrect { return "This is the correct answer." }
        return ""
    }
}