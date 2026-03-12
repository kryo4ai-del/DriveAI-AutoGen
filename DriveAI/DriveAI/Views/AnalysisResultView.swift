import SwiftUI

struct AnalysisResultView: View {
    let result: AnalysisResult
    
    var body: some View {
        VStack {
            Text(result.isRecognized ? "Recognized" : "Not Recognized")
                .font(.headline)
                .foregroundColor(result.isRecognized ? .green : .red)
            Text(result.description)
                .font(.subheadline)
                .padding()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}