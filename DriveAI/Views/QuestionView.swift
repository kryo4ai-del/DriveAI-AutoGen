import SwiftUI

struct QuestionView: View {
    @ObservedObject var viewModel: QuizQuestionViewModel
    @EnvironmentObject var demoViewModel: DemoFlowViewModel // Access main view model

    var body: some View {
        VStack {
            Text(viewModel.question.question)
                .font(.headline)
                .accessibilityLabel(Text(viewModel.question.question))

            ForEach(viewModel.question.answers) { answer in
                Button(action: {
                    demoViewModel.submitAnswer(selectedAnswer: answer.id)
                }) {
                    Text(answer.text)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .accessibilityIdentifier("answerButton_\(answer.id)")
                .accessibilityLabel(Text(answer.text)) // Accessible for VoiceOver
            }

            if let message = demoViewModel.feedbackMessage {
                Text(message)
                    .foregroundColor(message == "Correct!" ? .green : .red)
                    .animation(.default)
            }
        }
        .padding()
        .overlay(
            Group {
                if demoViewModel.isLoading {
                    ProgressView("Loading...")
                }
            }
        )
        .alert(item: $demoViewModel.errorMessage, content: { message in
            Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("OK")))
        })
    }
}