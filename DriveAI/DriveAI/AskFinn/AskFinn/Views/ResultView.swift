import SwiftUI

struct ResultView: View {
    let quizResult: QuizResult
    var retryAction: () -> Void

    var body: some View {
        VStack(spacing: 28) {

            // Result icon
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            // Score card
            VStack(spacing: 8) {
                Text("Quiz Completed!")
                    .font(.largeTitle)
                    .bold()
                Text("Score: \(quizResult.score, specifier: "%.0f")%")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)

            Button(action: { withAnimation { retryAction() } }) {
                Text("Retry Quiz")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}
