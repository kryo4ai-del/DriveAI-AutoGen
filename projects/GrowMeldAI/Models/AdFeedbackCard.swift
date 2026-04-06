// ✅ FIXED
struct AdFeedbackCard: View {
    let feedback: AdFeedback
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("📊 Lernfortschritt durch diese Anzeige")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Wie diese Werbepause Dir geholfen hat")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .accessibilityElement(children: .combine)
            
            Divider()
                .accessibilityHidden(true)  // Decorative
            
            // Stat Pills with accessible labels
            HStack(spacing: 16) {
                StatPill(
                    value: "\(feedback.questionsReviewedCount)",
                    label: "Fragen wiederholt",
                    accessibilityLabel: "Du hast \(feedback.questionsReviewedCount) Fragen wiederholt"
                )
                
                StatPill(
                    value: "+\(Int(feedback.confidenceIncreasePercent))%",
                    label: "Sicherheit gestiegen",
                    accessibilityLabel: "Deine Sicherheit ist um \(Int(feedback.confidenceIncreasePercent)) Prozent gestiegen"
                )
            }
            
            // Motivational Message
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)  // Icon is decorative
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Du bist näher dran!")
                        .font(.callout)
                        .fontWeight(.semibold)
                    
                    Text("Diese Pausen helfen Dir, schneller sicherer zu werden.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Du machst gute Fortschritte")
            .accessibilityHint("Diese Anzeigenpause hilft Dir, schneller zur Prüfung bereit zu sein")
            .padding(10)
            .background(.green.opacity(0.1))
            .clipShape(.rect(cornerRadius: 8))
        }
        .padding(12)
        .background(.blue.opacity(0.05))
        .clipShape(.rect(cornerRadius: 10))
    }
}

// ✅ FIXED StatPill
private struct StatPill: View {
    let value: String
    let label: String
    let accessibilityLabel: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(.green)
                .accessibilityHidden(true)  // Redundant with label
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(.gray.opacity(0.05))
        .clipShape(.rect(cornerRadius: 8))
        .accessibilityElement(children: .ignore)  // Don't read children separately
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isSummary)
    }
}