import SwiftUI

struct QuizResultView: View {
    @Environment(\.presentationMode) var presentationMode
    let result: QuizResult

    var body: some View {
        VStack {
            Text("Quiz Finished!")
                .font(.largeTitle)
            Text("You scored \(result.correctAnswers) out of \(result.totalQuestions)")
            Text("Score: \(String(format: "%.2f", result.score))%")
            Button("Retry Quiz") {
                resetQuiz()
            }
            .padding()
        }
        .padding()
    }
    
    private func resetQuiz() {
        // Logic to restart quiz flow
        presentationMode.wrappedValue.dismiss()
    }
}