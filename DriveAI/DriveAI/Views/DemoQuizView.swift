import SwiftUI

struct DemoQuizView: View {
    @StateObject private var viewModel = DemoQuizViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if let result = viewModel.results {
                    QuizResultView(result: result)
                } else {
                    QuizQuestionView(question: viewModel.questions[viewModel.currentQuestionIndex]) { answerIndex in
                        viewModel.selectAnswer(index: answerIndex)
                    }
                    Button("Next") {
                        viewModel.nextQuestion()
                    }
                    .disabled(viewModel.selectedAnswerIndex == nil)
                    .opacity(viewModel.selectedAnswerIndex == nil ? 0.5 : 1.0) // Visual feedback
                }
            }
            .navigationTitle("Demo Quiz")
            .padding()
            .alert(item: $viewModel.errorMessage) { errorMessage in
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}