struct QuestionView: View {
    let question: Question
    @State private var selectedAnswer: String = ""
    @State private var userAnswer: UserAnswer?
    
    var body: some View {
        VStack {
            Text(question.text)
                .font(.largeTitle)
                .padding()

            ForEach(question.options, id: \.self) { option in
                Button(action: {
                    selectedAnswer = option
                }) {
                    Text(option)
                        .padding()
                        .background(selectedAnswer == option ? Color.blue : Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.bottom, 5)
            }
            
            Button("Submit") {
                guard !selectedAnswer.isEmpty else { return }
                userAnswer = UserAnswer(question: question, selectedOption: selectedAnswer)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // Reset selection after a delay for emphasis on feedback
                    selectedAnswer = ""
                }
            }
            .padding()
            
            if let userAnswer = userAnswer {
                QuestionAnalysisView(viewModel: QuestionAnalysisViewModel(), userAnswer: userAnswer)
                    .animation(.easeIn, value: userAnswer) // Animate feedback view 
            }
        }
        .navigationTitle("Frage")
        .padding()
    }
}