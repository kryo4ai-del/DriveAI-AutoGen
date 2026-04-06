struct FeedbackView: View {
    let isCorrect: Bool
    let explanation: String?
    
    var body: some View {
        VStack(spacing: 12) {
            // Color indicator
            HStack(spacing: 12) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(isCorrect ? .green : .red)
                
                // Text label (essential for colorblind users)
                Text(isCorrect ? "Richtig!" : "Leider falsch.")
                    .font(.headline)
                    .foregroundColor(isCorrect ? .green : .red)
                    .accessibilityLabel(isCorrect ? "Richtig" : "Falsch")
            }
            .padding(12)
            .background(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            .cornerRadius(8)
            
            // Explanation text
            if let explanation = explanation {
                Text(explanation)
                    .font(.body)
                    .foregroundColor(.primary)
                    .accessibilityLabel("Erklärung")
                    .accessibilityValue(explanation)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
    }
}