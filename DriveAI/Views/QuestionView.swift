import SwiftUI

struct QuestionView: View {
    @StateObject private var viewModel = QuestionViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.currentQuestion.questionText)
                .font(.title)
                .padding()
            
            ForEach(viewModel.currentQuestion.options, id: \.self) { option in
                Button(action: {
                    if viewModel.submitAnswer(option) {
                        viewModel.advanceToNextQuestion()
                    }
                }) {
                    HStack {
                        if viewModel.isAnswerCorrect(option) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.white)
                        }
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isAnswerCorrect(option) ? Color(.systemGreen) : Color(.systemRed))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .navigationTitle("Question \(viewModel.currentQuestionIndex + 1)")
        .onAppear {
            viewModel.loadQuestion()
        }
    }
}