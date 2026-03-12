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
                } else {
                    QuestionView(viewModel: viewModel)
                }
            }
            .navigationBarTitle("Demo Quiz - Practice Questions", displayMode: .inline)
            .onAppear {
                viewModel.loadQuestions()
            }
        }
    }
}