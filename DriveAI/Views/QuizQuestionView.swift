import SwiftUI

struct QuizQuestionView: View {
    let question: QuizQuestion
    var onAnswerSelected: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(question.question)
                .font(.headline)
            ForEach(0..<question.options.count, id: \.self) { index in
                Button(action: {
                    onAnswerSelected(index)
                }) {
                    Text(question.options[index])
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                .foregroundColor(.primary)
                .buttonStyle(PlainButtonStyle()) // Removes default button style for a customized look
                .scaleEffect(viewModel.selectedAnswerIndex == index ? 1.05 : 1.0) // Scales the button on selection
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedAnswerIndex)
            }
        }
    }
}