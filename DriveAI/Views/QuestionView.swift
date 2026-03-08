struct QuestionView: View {
    @ObservedObject var viewModel: QuestionViewModel

    var body: some View {
        VStack {
            Text(viewModel.currentQuestion.text)
                .font(.title)

            ForEach(viewModel.currentQuestion.answers, id: \.self) { answer in
                Button(answer) {
                    viewModel.submitAnswer(answer)
                }
                .buttonStyle(.bordered)
            }

            if let feedbackMessage = viewModel.feedbackMessage {
                Text(feedbackMessage)
                    .foregroundColor(viewModel.isAnswerCorrect ? .green : .red)
                    .padding().font(.body)
            }
        }
        .padding()
        .navigationTitle("Question \(viewModel.currentQuestionIndex + 1)")
    }
}