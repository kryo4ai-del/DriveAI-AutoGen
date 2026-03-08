import SwiftUI

struct MockQuestionAnalysisView: View {
    @StateObject private var viewModel = MockQuestionAnalysisViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text(Strings.quizAnalysisTitle)
                    .font(.largeTitle)
                    .padding()

                List(viewModel.questions) { question in
                    VStack(alignment: .leading) {
                        Text(question.text)
                            .font(.headline)
                            .accessibilityLabel(question.text)

                        let answer = viewModel.answers.first(where: { $0.questionId == question.id })

                        Text("Ihre Antwort: \(answer?.displayResult ?? "N/A")")
                            .foregroundColor(.secondary)
                            .accessibilityLabel(answer?.displayResult ?? "No answer selected")
                            .accessibilityIdentifier("answer-\(question.id)")

                        Text("Korrekte Antwort: \(question.correctAnswer)")
                            .foregroundColor(answer?.isCorrect == true ? .green : .red)
                            .accessibilityLabel("Korrekte Antwort: \(question.correctAnswer)")
                    }
                }
                
                Text(viewModel.resultSummary)
                    .font(.subheadline)
                    .padding()
                    
                Spacer()
            }
            .navigationTitle("Analyse Ergebnisse")
        }
    }
}