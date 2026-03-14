struct ResultHeader: View {
    let result: SimulationResult
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                // Use both color AND icon to convey status
                Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        result.passed
                            ? Color(red: 0.0, green: 0.5, blue: 0.0)  // Darker green: #008000
                            : Color(red: 0.7, green: 0.0, blue: 0.0)  // Darker red: #B30000
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.passed ? "Bestanden! 🎉" : "Nicht bestanden")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                    
                    // Add explicit text label (not just color)
                    Text(result.passed ? "90% erreicht" : "Unter 90%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // ... rest
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Prüfungsergebnis")
        .accessibilityValue(
            "\(result.passed ? "Bestanden" : "Nicht bestanden"), \(Int(result.score * 100)) Prozent, \(result.correctAnswers) von \(result.totalQuestions) richtig"
        )
    }
}