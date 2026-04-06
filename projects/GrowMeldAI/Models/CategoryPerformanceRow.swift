struct CategoryPerformanceRow: View {
    let metric: PerformanceMetrics
    let spacedRepetitionDaysUntilReview: Int? // e.g., 2 days until optimal review
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(metric.categoryName)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    // Accuracy bar
                    ProgressView(value: metric.accuracy / 100)
                        .frame(height: 4)
                    
                    Text(String(format: "%.0f%%", metric.accuracy))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // ✅ DOMAIN-SPECIFIC: Spaced repetition cue
                if let daysUntilReview = spacedRepetitionDaysUntilReview {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        
                        if daysUntilReview == 0 {
                            Text("Zeit für Wiederholung — jetzt üben!")
                                .font(.caption)
                                .foregroundColor(.orange)
                        } else {
                            Text("Wiederholung in \(daysUntilReview)d")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .accessibilityLabel("Spaced repetition due in \(daysUntilReview) days")
                }
            }
            
            Spacer()
            
            // Streak with visual weight
            if metric.currentStreak > 0 {
                VStack(alignment: .center, spacing: 2) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.body)
                    
                    Text("\(metric.currentStreak)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}