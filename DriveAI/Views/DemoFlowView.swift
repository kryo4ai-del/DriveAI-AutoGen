import SwiftUI

struct DemoFlowView: View {
    @StateObject private var viewModel: DemoFlowViewModel

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.currentIndex < viewModel.questions.count {
                    QuestionView(viewModel: QuizQuestionViewModel(question: viewModel.questions[viewModel.currentIndex]))
                } else {
                    ResultView(results: viewModel.results!)
                }
            }
            .navigationTitle("Demo Quiz")
        }
    }
}