struct QuestionCardView: View {
    let question: Question
    @State private var selectedAnswer: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.questionText)
                .accessibilityLabel("Frage")
                .accessibilityValue(question.questionText)
            
            ForEach(Array(question.answers.enumerated()), id: \.offset) { idx, answer in
                Button(action: { selectedAnswer = idx }) {
                    HStack(spacing: 12) {
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle().fill(Color.blue).scaleEffect(0.5)
                                    .opacity(selectedAnswer == idx ? 1 : 0)
                            )
                        
                        Text(answer)
                            .lineLimit(nil)  // Support VoiceOver wrapping
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())  // Full button hitbox for VoiceOver
                }
                .accessibilityLabel("Antwort \(idx + 1)")
                .accessibilityValue(answer)
                .accessibilityHint("Tippen zum Auswählen")
                .accessibilityAddTraits(.isButton)
                .accessibilityRemoveTraits(.isStaticText)
            }
        }
        .accessibilityElement(children: .contain)  // Group for VoiceOver navigation
    }
}