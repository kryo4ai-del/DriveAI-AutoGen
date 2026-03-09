struct SomeView: View {
    let question: Question
    @State private var selectedAnswer: String = ""
    @State private var userAnswer: UserAnswer?

    var body: some View {
        VStack {
            // Assume options are displayed here
            // On option selection:
            Button("Submit") {
                userAnswer = UserAnswer(question: question, selectedOption: selectedAnswer)
            }
            
            if let userAnswer = userAnswer {
                QuestionAnalysisView(viewModel: QuestionAnalysisViewModel(), userAnswer: userAnswer)
            }
        }
    }
}