import SwiftUI

struct AnalysisStateView: View {
    @ObservedObject var viewModel: AnalysisStateViewModel
    
    var body: some View {
        VStack {
            if viewModel.isProcessing {
                ProgressView("Analysiere...")
                    .padding()
            } else if let result = viewModel.analysisResult {
                Text("Frage: \(result.question)")
                    .font(.headline)
                    .padding()
                Text("Deine Antwort: \(result.userAnswer)")
                    .padding()
                Text("Richtige Antwort: \(result.correctAnswer)")
                    .foregroundColor(result.isCorrect ? .green : .red)
                    .padding()
                Text(viewModel.feedbackMessage)
                    .font(.subheadline)
                    .padding()
            } else {
                Text("Bitte beantworte die Frage.")
                    .font(.subheadline)
                    .padding()
            }
            Spacer() // Ensures better spacing
        }
        .padding()
    }
}