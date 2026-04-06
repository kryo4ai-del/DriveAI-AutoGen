import SwiftUI

struct AnswerButton: View {
    let answerLetter: String
    let text: String
    let action: () -> Void
    let backgroundColor: Color
    let isFeedbackShown: Bool
    let feedbackIcon: String
    let accessibilityLabel: String

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(answerLetter)
                        .font(.headline)
                        .accessibilityHidden(true)
                    Text(text)
                        .font(.body)
                        .lineLimit(3)
                }
                Spacer()
                if isFeedbackShown {
                    Image(systemName: feedbackIcon)
                        .font(.title3)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 44)
            .background(backgroundColor)
            .cornerRadius(12)
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
    }
}