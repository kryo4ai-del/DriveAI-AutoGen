struct QuestionCard: View {
    let question: Question
    @Binding var selectedAnswerId: UUID?
    @Binding var isAnswered: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.text)
                .font(.headline)
                .lineLimit(nil)
            
            VStack(spacing: 12) {
                ForEach(question.answers) { answer in
                    AnswerButton(
                        answer: answer,
                        isSelected: selectedAnswerId == answer.id,
                        isAnswered: isAnswered,
                        isCorrect: isAnswered && answer.isCorrect,
                        action: {
                            if !isAnswered {
                                selectedAnswerId = answer.id
                            }
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}