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
