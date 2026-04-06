import SwiftUI

struct AnswerOptionCard: View {
    let optionText: String
    let isSelected: Bool
    let isCorrect: Bool?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(optionText)
                Spacer()
                if isSelected {
                    Image(systemName: isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Antwort: \(optionText)"))
        .accessibilityHint(isSelected ? Text(isCorrect == true ? "Richtig" : "Falsch") : Text(""))
        .accessibilityAddTraits(.isButton)
    }

    private var backgroundColor: Color {
        if isSelected {
            return isCorrect == true ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
        }
        return Color(.systemGray6)
    }
}