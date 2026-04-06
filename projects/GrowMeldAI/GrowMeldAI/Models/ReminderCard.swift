// ReminderCard with scaffolded information
struct ReminderCard: View {
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tier 1: Urgency + Time + Action
            HStack {
                VStack(alignment: .leading) {
                    Text(urgencyEmoji + " " + urgencyLabel)
                        .font(.headline)
                    Text("\(daysRemaining) Tage verbleibend")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: { Task { await startQuiz() } }) {
                    Label("Jetzt", systemImage: "arrow.right")
                }
            }
            
            Divider()
            
            // Tier 2: Progress clarity (only if expanded)
            if showDetails {
                ProgressSection(
                    readinessPct: readinessPct,
                    passThreshold: 75,
                    pointsNeeded: calculatePointsGap()
                )
                
                // Tier 3: Domain-specific next step
                if let weakestCategory = weakestCategory {
                    NextActionSection(
                        category: weakestCategory,
                        accuracy: weakestCategory.accuracy,
                        daysNotReviewed: weakestCategory.daysSinceReview
                    )
                }
            }
            
            if !showDetails {
                Button("Mehr Info", action: { showDetails = true })
                    .buttonStyle(.bordered)
            }
        }
    }
}