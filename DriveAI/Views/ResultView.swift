import SwiftUI

struct ResultView: View {
    let quizResult: QuizResult
    var retryAction: () -> Void

    var body: some View {
        VStack {
            Text("Quiz Completed!")
                .font(.title)
                .padding()
            Text("Score: \(quizResult.score, specifier: "%.2f")%")
                .font(.headline)
            
            Button(action: {
                withAnimation {
                    retryAction()
                }
            }) {
                Text("Retry Quiz")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}