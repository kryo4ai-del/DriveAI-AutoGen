struct QuestionView: View {
    let question: Question
    @Binding var selectedAnswer: Int?
    let checkAnswer: (Int) -> Void
    let isAnswerCorrect: Bool?

    var body: some View {
        VStack(alignment: .leading) {
            Text(question.text)
                .font(.title2)
                .padding(.bottom, 20)
                
            ForEach(0..<question.options.count, id: \.self) { index in
                Button(action: {
                    selectedAnswer = index
                    checkAnswer(index)
                }) {
                    Text(question.options[index])
                        .padding()
                        .background(selectedAnswer == index ? Color.blue.opacity(0.2) : Color.blue.opacity(0.05))
                        .cornerRadius(10)
                }
                .disabled(isAnswerCorrect != nil)
                .foregroundColor(.black)
            }

            if let answerFeedback = isAnswerCorrect {
                Text(answerFeedback ? "Richtig!" : "Falsch!")
                    .font(.headline)
                    .foregroundColor(answerFeedback ? .green : .red)
                    .padding(.top, 20)
            }
        }
    }
}