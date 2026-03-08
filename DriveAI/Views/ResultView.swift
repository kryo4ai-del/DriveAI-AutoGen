struct ResultView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack {
            Text("Your Score: \(viewModel.score) out of \(viewModel.questions.count)")
            Text(viewModel.passed ? "You Passed!" : "Try Again")
            if let questionCount = viewModel.questions.count {
                Text("Total Questions: \(questionCount)")
                Text("Correct Answers: \(viewModel.score)")
                
                // Additional feedback such as tips can go here
            }
        }
    }
}