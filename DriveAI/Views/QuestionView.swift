import SwiftUI

struct QuestionView: View {
    @ObservedObject var viewModel: DemoFlowViewModel
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            Text(viewModel.currentQuestion?.text ?? "")
                .font(.headline)
                .padding()
            
            if viewModel.currentQuestion != nil {
                ForEach(viewModel.currentQuestion?.options ?? [], id: \.self) { option in
                    Button(action: {
                        isLoading = true // Start loading
                        viewModel.answerQuestion(with: option)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Simulate delay
                            isLoading = false // Stop loading after a brief delay
                        }
                    }) {
                        Text(option)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.quizResult != nil) // Disable after quiz completion
                }
            }
            
            if isLoading {
                ProgressView()
            } else if let feedback = viewModel.feedback {
                FeedbackView(feedback: feedback.message, isCorrect: feedback.isCorrect)
            }
        }
        .padding()
    }
}