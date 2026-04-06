import SwiftUI

struct FlaggedQuestionsWidgetCard: View {
    let title: String
    let questionCount: Int
    let onDismiss: () -> Void

    init(title: String = "Flagged Questions", questionCount: Int = 0, onDismiss: @escaping () -> Void = {}) {
        self.title = title
        self.questionCount = questionCount
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Dismiss")
            }
            Text("\(questionCount) flagged question(s)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(LayoutConstants.cardCornerRadius)
        .shadow(radius: LayoutConstants.cardShadowRadius)
    }
}