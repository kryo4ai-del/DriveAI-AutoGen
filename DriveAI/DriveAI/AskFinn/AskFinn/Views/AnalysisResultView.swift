import SwiftUI

struct AnalysisResultView: View {
    let result: AnalysisResult

    var body: some View {
        VStack {
            Text(result.isCorrect ? "Correct" : "Incorrect")
                .font(.headline)
                .foregroundColor(result.isCorrect ? .green : .red)
            Text("Question: \(result.question)")
                .font(.subheadline)
                .padding()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}
