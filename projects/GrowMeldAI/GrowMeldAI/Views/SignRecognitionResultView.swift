struct SignRecognitionResultView: View {
    let recognition: TrafficSignRecognition
    
    var body: some View {
        VStack(spacing: 16) {
            // Sign image & info
            VStack {
                AsyncImage(url: URL(string: recognition.sign.imageAssetName))
                    .frame(height: 200)
                    .accessibilityIgnored(true) // Image is decorative
                
                Text(recognition.sign.germanName)
                    .font(.title)
                    .accessibilityLabel("Erkanntes Zeichen: \(recognition.sign.germanName)")
                
                Text(recognition.sign.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Beschreibung: \(recognition.sign.description)")
            }
            .padding()
            
            // ✅ Explicit focus order for buttons
            HStack(spacing: 12) {
                Button("Erneut versuchen") {
                    // retry logic
                }
                .keyboardShortcut(.escape, modifiers: [])
                .accessibilityHint("Drücken Sie Escape zum Erneut versuchen")
                
                Button("Diese Fragen lernen") {
                    // navigate to questions
                }
                .keyboardShortcut(.return, modifiers: [])
                .accessibilityHint("Drücken Sie Return zum Starten der Lernfragen")
            }
            .focusable(true)
        }
        .accessibilityElement(children: .contain)
        .focusSection() // Establish focus group
    }
}