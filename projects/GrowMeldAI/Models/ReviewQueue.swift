
struct ReviewQueue: View {
    let userProgress: UserProgress
    let nextReviewDue: [UUID]  // Question IDs ready for review today
    
    var body: some View {
        if !nextReviewDue.isEmpty {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .foregroundColor(.blue)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Review Ready")
                        .font(.headline)
                    Text("\(nextReviewDue.count) question\(nextReviewDue.count == 1 ? "" : "s") to strengthen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Review queue")
            .accessibilityValue("\(nextReviewDue.count) questions due for spaced review")
        }
    }
}