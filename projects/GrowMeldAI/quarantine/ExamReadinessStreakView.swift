// Instead of:
StreakIndicatorView(
    currentStreak: 12,
    motivationalMessage: "Großartig! Weiter so!" // ❌ Generic
)

// Use:
struct ExamReadinessStreakView: View {
    let dailyConsistencyDays: Int // 12
    let estimatedPassProbability: Double // 78% (calculated from category performance + time-to-exam)
    let previousProbability: Double // 71% (7 days ago)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(dailyConsistencyDays) Tage Vorbereitung")
                        .font(.headline)
                    
                    // ✅ Intrinsic motivation: Show learning progress, not streak
                    Text("Deine Bestehenschance: \(Int(estimatedPassProbability))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    // ✅ Relatedness: Show growth trajectory
                    Text("↑ \(Int((estimatedPassProbability - previousProbability) * 100)) Punkte in 7 Tagen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Exam Readiness")
        .accessibilityValue("\(Int(estimatedPassProbability)) percent pass probability")
    }
}