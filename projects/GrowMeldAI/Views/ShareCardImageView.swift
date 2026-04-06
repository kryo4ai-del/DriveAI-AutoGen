struct ShareCardImageView: View {
    let card: ShareableQuestionCard
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DriveAI")
                            .accessibilityLabel("DriveAI Logo")
                            .font(.system(.caption, design: .default))
                        
                        Text(card.category)
                            .accessibilityLabel("Category: \(card.category)")
                            .font(.system(.headline, design: .default))
                    }
                    
                    Spacer()
                    
                    Text(card.difficulty.displayName)
                        .accessibilityLabel("Difficulty: \(card.difficulty.displayName)")
                        .font(.caption)
                }
            }
            
            Text(card.title)
                .accessibilityLabel("Question: \(card.title)")
                .font(.system(.title3, design: .default))
        }
    }
}