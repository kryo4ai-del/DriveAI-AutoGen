struct ResultView: View {
    @Environment(\.presentationMode) var presentationMode
    var results: ResultDetails
    
    var body: some View {
        VStack {
            Text("Quiz Finished!")
                .font(.largeTitle)
                .padding()
            Text("You scored \(results.correctAnswers) out of \(results.totalAnswered) (\(Double(results.correctAnswers) / Double(results.totalAnswered) * 100, specifier: "%.2f")%)")
            Text("Review Incorrect Answers:")
                .font(.headline)
            List(results.incorrectQuestions) { question in
                Text(question.questionText)
            }
            Button("Start Over") {
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(CustomButtonStyle(backgroundColor: .blue))
        }
        .padding()
    }
}