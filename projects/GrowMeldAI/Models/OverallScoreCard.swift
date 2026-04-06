struct OverallScoreCard: View {
    var body: some View {
        VStack {
            Text("\(score)%")
                .font(.title)
                .accessibilityLabel("Gesamt-Fortschritt: \(score) Prozent")
            
            ProgressView(value: Double(score), total: 100)
                .accessibilityLabel("Fortschritts-Balken")
                .accessibilityValue("\(score) von 100 Prozent")
                .accessibilityHint("Zeigt deinen aktuellen Lernfortschritt")
            
            Text(motivationalText)
                .accessibilityLabel("Motivations-Nachricht")
                .accessibilityAddTraits(.updatesFrequently)
        }
    }
}