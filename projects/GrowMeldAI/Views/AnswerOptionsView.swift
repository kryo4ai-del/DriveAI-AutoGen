import SwiftUI

struct AnswerOption: Identifiable {
    let id: Int
    let text: String
}

struct AnswerOptionsView: View {
    let options: [AnswerOption]
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(options) { option in
                Button(action: { onSelect(option.id) }) {
                    AnswerOptionButton(text: option.text)
                }
                .accessibilityLabel("Option \(option.id + 1)")
                .accessibilityHint("Antwortoption: \(option.text)")
                .accessibilityElement(children: .ignore)
            }
        }
        .accessibilityElement(children: .contain)
    }
}