import SwiftUI

struct MultipleChoiceView: View {
    @ObservedObject var viewModel: MultipleChoiceViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.question?.question ?? "")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            
            if let answers = viewModel.question?.answers {
                ForEach(answers.indices, id: \.self) { index in
                    answerButton(for: answers[index], index: index)
                }
            }
            
            if viewModel.isAnswered {
                Text(viewModel.feedbackMessage)
                    .font(.headline)
                    .padding()
            }
            
            Button("Next Question") {
                viewModel.reset()
            }
            .padding()
            .disabled(!viewModel.isAnswered)
            .opacity(viewModel.isAnswered ? 1.0 : 0.5)
        }
        .padding()
        .navigationTitle("Multiple Choice Quiz")
    }
    
    @ViewBuilder
    private func answerButton(for answer: AnswerModel, index: Int) -> some View {
        Button(action: {
            viewModel.selectAnswer(at: index)
        }) {
            Text(answer.text)
                .padding()
                .background(viewModel.selectedAnswerIndex == index ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(viewModel.isAnswered)
        .animation(.default, value: viewModel.isAnswered)
        .accessibilityLabel(answer.text) // Accessibility support
    }
}