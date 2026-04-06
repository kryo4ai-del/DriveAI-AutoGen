import SwiftUI
struct VerticalAnswerLayout: View {
    var question: Question
    var answers: [String]
    @Binding var selectedAnswer: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ✅ Semantic grouping for accessibility
            VStack(spacing: 12) {
                ForEach(answers, id: \.self) { answer in
                    Button(action: { selectedAnswer = answer }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(answer)
                                    .font(.body)
                                    .frame(minHeight: 44)  // ✅ Touch target
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Answer option")
                    .accessibilityValue(answer)
                    .accessibilityHint(selectedAnswer == answer ? "Currently selected" : "Double tap to select")
                }
            }
            .accessibilityElement(children: .contain)  // ← Group all answers
            .accessibilityLabel("Answer options for: \(question.text)")
            .accessibilityAddTraits(.isButton)
        }
        .padding()
    }
}