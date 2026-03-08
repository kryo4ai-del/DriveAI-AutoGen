import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack {
            if let currentQuestion = viewModel.currentQuestion {
                Text(currentQuestion.questionText)
                ForEach(currentQuestion.answers, id: \.self) { answer in
                    Button(answer) {
                        viewModel.submitAnswer(answer)
                    }
                }
            } else {
                NavigationLink(destination: ResultView(viewModel: viewModel)) {
                    Text("See Results")
                }
            }
        }
    }
}