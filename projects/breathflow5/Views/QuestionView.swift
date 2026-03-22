// ✅ CORRECT: Domain state in ViewModel

// View uses ViewModel
struct QuestionView: View {
    @StateObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.currentQuestion.text)
            ForEach(viewModel.currentQuestion.options, id: \.id) { option in
                Button(option.text) {
                    viewModel.selectedAnswer = option.id
                    Task { await viewModel.submitAnswer() }
                }
            }
        }
    }
}