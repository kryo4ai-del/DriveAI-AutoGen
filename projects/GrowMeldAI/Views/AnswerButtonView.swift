import SwiftUI

struct AnswerButtonView: View {
    let answer: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(answer)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.blue : Color.gray)
        }
        .accessibilityLabel("Answer option")
        .accessibilityHint(answer)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}