import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: QuizViewModel

    var body: some View {
        VStack {
            if let currentQuestion = viewModel.currentQuestion {
                Text(currentQuestion.text)
                    .font(.headline)
                    .padding()
                ForEach(currentQuestion.options) { answer in
                    Button(answer.text) {
                        viewModel.submitAnswer(answer.id)
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Text("Quiz Complete! Score: \(viewModel.score)")
                    .font(.title)
            }
        }
    }
}
