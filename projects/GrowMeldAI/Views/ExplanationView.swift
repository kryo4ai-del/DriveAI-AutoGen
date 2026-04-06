struct ExplanationView: View {
    let text: String
    let isCorrect: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .green : .red)
                    .font(.title)
                
                Text(isCorrect ? "Correct!" : "Incorrect")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(isCorrect ? "Correct answer" : "Incorrect answer"))
            
            Text(text)
                .font(.body)
                .lineLimit(nil)
                .accessibilityLabel(Text("Explanation"))
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .border(isCorrect ? Color.green : Color.red, width: 2)
        
        // ✅ Announce this view to VoiceOver users
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)  // Treat as section header
        .onAppear {
            // Post announcement when explanation appears
            UIAccessibility.post(notification: .announcement, argument: 
                isCorrect ? "Correct answer. \(text)" : "Incorrect answer. \(text)"
            )
        }
    }
}

// In QuestionView: