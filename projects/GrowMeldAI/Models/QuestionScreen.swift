struct QuestionScreen: View {
    @StateObject var viewModel: QuestionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("Frage \(viewModel.progress.current)/\(viewModel.progress.total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("✕") { dismiss() }
            }
            .padding()
            
            // Question
            if let question = viewModel.currentQuestion {
                QuestionContent(question: question)
                    .transition(.opacity)
                
                // Answers
                AnswerGrid(
                    answers: question.answers,
                    selectedIndex: viewModel.selectedAnswer,
                    correctIndex: viewModel.isAnswered ? question.correctAnswerIndex : nil,
                    onSelect: { index in
                        Task {
                            await viewModel.submitAnswer(index)
                        }
                    }
                )
                .disabled(viewModel.isAnswered)
                
                // Explanation (shown after answer)
                if viewModel.isAnswered {
                    ExplanationCard(text: question.explanation)
                        .transition(.move(edge: .bottom))
                }
                
                Spacer()
                
                // Navigation
                if viewModel.isAnswered {
                    Button(action: viewModel.nextQuestion) {
                        Text(viewModel.currentIndex == viewModel.progress.total - 1 
                            ? "Fertig" : "Nächste Frage")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            } else if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                ErrorView(message: error)
            }
        }
        .navigationBarHidden(true)
    }
}