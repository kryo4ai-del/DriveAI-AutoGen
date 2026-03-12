import SwiftUI

struct DemoQuizView: View {
    @StateObject private var viewModel = DemoQuizViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if let result = viewModel.results {
                    QuizResultView(result: result)
                } else if !viewModel.questions.isEmpty {
                    QuizQuestionView(question: viewModel.questions[viewModel.currentQuestionIndex]) { answerIndex in
                        viewModel.selectAnswer(index: answerIndex)
                    }
                    Button("Next") {
                        viewModel.nextQuestion()
                    }
                    .disabled(viewModel.selectedAnswerIndex == nil)
                    .opacity(viewModel.selectedAnswerIndex == nil ? 0.5 : 1.0)
                }
            }
            .navigationTitle("Demo Quiz")
            .padding()
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? ""),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
