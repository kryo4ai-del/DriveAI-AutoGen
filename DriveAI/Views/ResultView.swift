// Views/ResultView.swift
import SwiftUI

struct ResultView: View {
    @StateObject private var viewModel = ResultViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 20) {
                if let result = viewModel.result {
                    Text(resultTitle(result.isPassed))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(result.isPassed ? .green : .red)
                    
                    Text("Ergebnis: \(result.score) / \(result.totalQuestions)")
                        .font(.title)
                    
                    Text(result.detailedFeedback)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    NavigationLink(destination: NextStepsView(score: result.score, totalQuestions: result.totalQuestions)) {
                        Text("Ergebnisse ansehen")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .accessibilityLabel("Ergebnisse ansehen") // Accessibility enhancement
                    
                    // Additional feedback if score is less than 50%
                    if result.score < Int(Double(result.totalQuestions) * 0.5) {
                        Text("Tip: Sie haben unter 50% erzielt – überdenken Sie die Verkehrszeichen.")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding()
                    }
                } else {
                    ProgressView("Lade Ihr Ergebnis...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .padding()
            .navigationTitle("Ergebnis")
            .onAppear {
                viewModel.loadResult(score: 25, totalQuestions: 30) // Placeholder data
            }
        }
    }
    
    /// Create result title based on pass/fail status.
    private func resultTitle(_ isPassed: Bool) -> String {
        return isPassed ? "🎉 Sie haben bestanden!" : "❌ Sie haben nicht bestanden"
    }
}