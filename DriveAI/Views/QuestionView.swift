import SwiftUI

struct QuestionView: View {
    @ObservedObject var viewModel: QuestionViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(viewModel.currentQuestion.text)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                ForEach(viewModel.currentQuestion.choices, id: \.self) { choice in
                    AnswerButton(choice: choice) {
                        // Logic to handle user response
                        print("Selected Answer: \(choice)")
                    }
                }
                
                HStack {
                    Button("Previous") {
                        viewModel.previousQuestion()
                    }
                    .disabled(viewModel.currentQuestionIndex == 0)
                    
                    Button("Next") {
                        viewModel.nextQuestion()
                    }
                    .disabled(viewModel.currentQuestionIndex == viewModel.questions.count - 1)
                }
                .padding(.top)
            }
            .padding()
            .navigationTitle("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
            .alert(item: $viewModel.loadingError) { error in
                Alert(title: Text("Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct AnswerButton: View {
    let choice: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(choice)
                .padding()
                .background(Color.blue.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}