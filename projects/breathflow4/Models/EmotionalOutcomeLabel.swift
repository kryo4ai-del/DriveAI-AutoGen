import SwiftUI
struct EmotionalOutcomeLabel: View {
    let outcomes: [EmotionalOutcome]
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(outcomes.prefix(maxDisplay)) { outcome in
                HStack(spacing: 4) {
                    Image(systemName: outcome.icon)
                    Text(outcome.label)  // ❌ No relevance info
                }
                .font(.caption2)
                // ❌ NO ACCESSIBILITY
            }
            
            if outcomes.count > maxDisplay {
                Text("+\(outcomes.count - maxDisplay)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}