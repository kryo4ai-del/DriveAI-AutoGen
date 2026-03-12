import SwiftUI

struct DemoFlowView: View {
    @StateObject private var viewModel = DemoFlowViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if let quizResult = viewModel.quizResult {
                    ResultView(quizResult: quizResult, retryAction: {
                        viewModel.resetQuiz()
                    })
                } else if let question = viewModel.currentQuestion {
                    QuestionView(question: question)
                } else {
                    Text("No questions available.")
                }
            }
            .navigationBarTitle("Demo Quiz - Practice Questions", displayMode: .inline)
            .onAppear {
                viewModel.loadQuestions()
            }
        }
    }
}
