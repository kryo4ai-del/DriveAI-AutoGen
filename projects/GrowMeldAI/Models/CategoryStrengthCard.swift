// MARK: - Presentation/Common/Components/CategoryStrengthCard.swift

struct CategoryStrengthCard: View {
    let strength: CategoryStrength
    
    @ScaledMetric(relativeTo: .body) private var cornerRadius = 12
    @ScaledMetric(relativeTo: .body) private var padding = 16
    
    var body: some View {
        VStack(alignment: .leading, spacing: padding / 2) {
            // Category name with proper scaling
            Text(strength.category.name)
                .font(.headline)  // ← Uses system scaling
                .accessibilityLabel(strength.accessibilityLabel)
            
            // Accuracy with dynamic text
            HStack {
                Text("Genauigkeit:")
                    .font(.body)
                
                Text("\(strength.accuracyPercentage)%")
                    .font(.title3)
                    .foregroundColor(strength.masteryLevel.color)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Genauigkeit: \(strength.accuracyPercentage) Prozent")
            
            // Mastery level with accessible value
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(strength.masteryLevel.color)
                    .accessibilityHidden(true)
                
                Text(strength.masteryLevel.label)
                    .font(.caption)
            }
            .accessibilityElement(children: .combine)
            .accessibilityValue(strength.masteryLevel.accessibilityLabel)
            
            // Accessibility hint
            Text(strength.accessibilityHint)
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)  // ← Hide from VoiceOver (already in label)
        }
        .padding(padding)
        .background(Color(.systemBackground))
        .cornerRadius(cornerRadius)
    }
}