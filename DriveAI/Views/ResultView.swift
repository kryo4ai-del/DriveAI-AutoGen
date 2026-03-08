import SwiftUI

struct ResultView: View {
    var results: QuizResult

    var body: some View {
        VStack {
            Text("Results")
                .font(.largeTitle)
            Text("Correct: \(results.correctAnswers)/\(results.totalQuestions)")
            // Additional UI for results as needed
        }
        .padding()
    }
}