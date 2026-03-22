import SwiftUI

struct QuizQuestion: Identifiable {
    let id = UUID()
    var text: String
    var answer: String
}

// DON'T do this
struct QuizView: View {
    @State var currentQuestion: QuizQuestion = QuizQuestion(text: "Sample?", answer: "Yes")
    @State var score: Int = 0

    var body: some View {
        VStack {
            Text(currentQuestion.text)
            Text("Score: \(score)")
        }
    }
}