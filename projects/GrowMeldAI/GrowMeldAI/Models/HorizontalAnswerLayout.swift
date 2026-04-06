struct HorizontalAnswerLayout: View {
    var answers: [String]
    @Binding var selectedAnswer: String?
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(answers, id: \.self) { answer in
                Button(action: { selectedAnswer = answer }) {
                    Text(answer)
                        .frame(minHeight: 44)  // ← iOS minimum
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())  // Expand tap target
                }
                .accessibilityLabel("Answer option: \(answer)")
                .accessibilityHint("Double tap to select")
            }
        }
        .padding()
    }
}