import SwiftUI
// ✅ ACCESSIBLE VERSION
struct RetentionMetricsView: View {
    let metrics: RetentionMetrics
    
    var body: some View {
        VStack(spacing: 16) {
            // Accuracy metric with full context
            VStack(alignment: .leading, spacing: 4) {
                Text("Overall Accuracy")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(metrics.overallAccuracy * 100))%")
                    .font(.system(size: 32, weight: .bold))
                    .accessibilityLabel("Overall accuracy")
                    .accessibilityValue("\(Int(metrics.overallAccuracy * 100)) percent correct")
                    .accessibilityHint("Based on all reviewed questions")
            }
            
            // Review streak with emotional context
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text("\(metrics.reviewStreak)")
                        .font(.system(size: 24, weight: .semibold))
                    Text(streakEmoji(metrics.reviewStreak))
                        .font(.system(size: 24))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Current review streak")
                .accessibilityValue("\(metrics.reviewStreak) days in a row")
                .accessibilityHint("Keep practicing to maintain your streak")
            }
            
            // Due count status
            HStack(spacing: 12) {
                Image(systemName: dueIcon(metrics.dueForReview))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(dueColor(metrics.dueForReview))
                
                VStack(alignment: .leading) {
                    Text("Ready to Review")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(metrics.dueForReview)")
                        .font(.headline)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Questions due for review")
            .accessibilityValue("\(metrics.dueForReview) questions")
            .accessibilityHint(
                dueColor(metrics.dueForReview) == .red
                    ? "Action needed: Please review these questions"
                    : "All questions are up to date"
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Retention metrics summary")
    }
    
    private func streakEmoji(_ days: Int) -> String {
        switch days {
        case 0: return "🚫"
        case 1...3: return "⚡"
        case 4...7: return "🔥"
        case 8...: return "🎯"
        default: return ""
        }
    }
    
    private func dueIcon(_ count: Int) -> String {
        count > 0 ? "exclamationmark.circle.fill" : "checkmark.circle.fill"
    }
    
    private func dueColor(_ count: Int) -> Color {
        count > 0 ? .red : .green
    }
}