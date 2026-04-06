import SwiftUI

struct AnswerOptionButton: View {
    let option: AnswerOption
    let onSelectOption: (String) -> Void

    var body: some View {
        Button(action: { onSelectOption(option.id) }) {
            HStack(spacing: 8) {
                Text(option.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: A11yConstants.minTouchTarget)
            .padding(8)
            .padding(.vertical, 12)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Answer option")
        .accessibilityValue(option.text)
        .accessibilityHint("Double-tap to select. Minimum 44-point touch target.")
    }
}

struct AnswerOption: Identifiable {
    let id: String
    let text: String
}