struct QuizResultFeedback: View {
    let question: Question
    let userAnswer: String
    let isCorrect: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Verdict
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .green : .red)
                Text(isCorrect ? "Richtig!" : "Leider falsch")
                    .font(.headline)
            }
            
            // Correct answer
            VStack(alignment: .leading, spacing: 4) {
                Text("Richtige Antwort:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(question.correctAnswer)
                    .font(.body)
                    .fontWeight(.semibold)
            }
            
            // ✅ ELABORATIVE HINT (THE KEY FIX)
            VStack(alignment: .leading, spacing: 4) {
                Text("Warum:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(question.elaborativeHint)  // e.g., "Stadtgebiete haben 50 km/h als Standard zum Schutz von Fußgängern."
                    .font(.caption)
                    .italic()
                    .foregroundColor(.primary)
            }
            .padding(.top, 8)
            .padding(8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(4)
        }
        .accessibilityElement(children: .combine)
    }
}