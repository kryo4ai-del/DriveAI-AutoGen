import SwiftUI
struct FeedbackCard: View {
    let isCorrect: Bool
    let explanation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(isCorrect ? .green : .red)
                
                Text(isCorrect ? "Richtig!" : "Falsch!")
                    .font(.headline)
                
                Spacer()
            }
            
            Text(explanation)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .border(isCorrect ? Color.green : Color.red, width: 1)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}