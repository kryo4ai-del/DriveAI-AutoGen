import SwiftUI

struct QuestionRow: View {
    let question: Question
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(question.questionText)
                .font(.headline)
                .accessibilityLabel(question.questionText)
            userAnswerView
            correctAnswerView
        }
        .padding()
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var userAnswerView: some View {
        Text("Deine Antwort: \(question.givenAnswer)")
            .foregroundColor(question.isCorrect ? .green : .red)
    }

    private var correctAnswerView: some View {
        if !question.isCorrect {
            Text("Korrekte Antwort: \(question.correctAnswer)")
                .foregroundColor(.blue)
        }
    }
}