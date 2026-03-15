struct RecommendationCard: View {
    let recommendation: Recommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(recommendation.priority.color)
                    .accessibilityHidden(true)
                
                Text(recommendation.title)
                    .font(.headline)
                    .lineLimit(2) // UI constraint
                    // ✅ Use full text for accessibility
                    .accessibilityLabel(recommendation.title)
                
                Spacer()
            }
            
            Text(recommendation.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .accessibilityLabel("Details: \(recommendation.description)")
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        // ✅ Full semantic description for screen readers
        .accessibilityValue(
            "\(recommendation.priority.label) priority recommendation. " +
            "\(recommendation.description)"
        )
    }
}