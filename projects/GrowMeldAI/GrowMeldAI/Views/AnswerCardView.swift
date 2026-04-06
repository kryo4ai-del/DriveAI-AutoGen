import SwiftUI

struct AnswerCardView: View {
    let answerText: String
    let isCorrect: Bool?  // nil, true, false

    var body: some View {
        VStack {
            Text(answerText).font(.body)

            if let isCorrect = isCorrect {
                HStack(spacing: 8) {
                    // ✅ ICON + COLOR + TEXT (not color alone)
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)

                    Text(isCorrect ? "Correct" : "Incorrect")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
        }
        .background(
            // ✅ Pattern in addition to color
            isCorrect == true ? Color.green.opacity(0.2) :
            isCorrect == false ? Color.red.opacity(0.2) :
            Color(.systemGray6)
        )
        .border(
            isCorrect == true ? Color.green :
            isCorrect == false ? Color.red :
            Color.clear,
            width: 2
        )
    }
}