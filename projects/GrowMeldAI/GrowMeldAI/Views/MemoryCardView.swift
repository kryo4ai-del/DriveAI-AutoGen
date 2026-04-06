// ✅ ACCESSIBLE
struct MemoryCardView: View {
    let memory: EpisodicMemory
    
    var body: some View {
        HStack {
            Text(memory.metadata.emoji)
                .accessibilityHidden(true)  // Emoji is decorative
            
            VStack(alignment: .leading, spacing: 4) {
                // Memory type headline
                Text(memory.type.displayName)
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                
                // Memory detail
                Text(memory.metadata.detail)
                    .font(.body)
                    .accessibilityLabel("Memory detail: \(memory.metadata.detail)")
                
                // Timestamp with accessible format
                Text(memory.relativeTimeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Date: \(dateAccessibleFormat(memory.timestamp))")
            }
            
            Spacer()
            
            // Streak indicator
            if let streak = memory.metadata.streakDays {
                VStack(alignment: .center, spacing: 2) {
                    Image(systemName: "flame.fill")
                        .accessibilityHidden(true)
                    Text("\(streak)")
                        .accessibilityLabel("\(streak) day streak")
                        .font(.caption)
                }
                .foregroundColor(.orange)
                .accessibilityElement(children: .combine)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(cardAccessibilityLabel)
        .accessibilityHint("Memory from \(memory.type.displayName) category")
    }
    
    private var cardAccessibilityLabel: String {
        let detail = memory.metadata.detail
        let time = memory.relativeTimeString
        let streak = memory.metadata.streakDays.map { " with \($0) day streak" } ?? ""
        return "\(memory.type.displayName): \(detail)\(streak), \(time)"
    }
    
    private func dateAccessibleFormat(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}