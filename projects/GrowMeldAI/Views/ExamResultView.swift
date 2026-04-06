struct ExamResultView: View {
    let result: ExamSimulationResult
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(result.passed ? Color.green : Color.red)
                
                HStack(spacing: 12) {
                    Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title)
                        .accessibilityHidden(true)  // Text already conveys result
                    
                    Text(result.passed ? "Bestanden" : "Nicht bestanden")
                        .font(.headline)
                }
                .foregroundColor(.white)
            }
            .frame(height: 60)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Prüfungsergebnis")
            .accessibilityValue(result.passed ? "Bestanden" : "Nicht bestanden")
        }
    }
}