import SwiftUI

struct AnswerOptionsView: View {
    let options: [Answer]
    let onSelect: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options.indices, id: \.self) { index in
                Button(action: { onSelect(index) }) {
                    AnswerOptionButton(text: options[index].text)
                }
                .accessibilityLabel("Option \(index + 1)")
                .accessibilityHint("Antwortoption: \(options[index].text)")
                .accessibilityElement(children: .ignore)
            }
        }
        .accessibilityElement(children: .contain)
    }
}