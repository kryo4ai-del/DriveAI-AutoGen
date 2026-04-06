struct PaywallFeatureRow: View {
    let feature: SubscriptionFeature
    let isIncluded: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // ❌ WRONG (too small):
            // Image(systemName: isIncluded ? "checkmark.circle.fill" : "xmark.circle")
            //     .font(.system(size: 16))
            
            // ✅ CORRECT (44×44 minimum):
            Button(action: {}) {
                Image(systemName: isIncluded ? "checkmark.circle.fill" : "xmark.circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isIncluded ? .green : .gray)
            }
            .frame(width: 44, height: 44)  // Explicit touch target
            .accessibilityLabel(
                isIncluded ? "✓ \(feature.displayName)" : "✗ \(feature.displayName)"
            )
            .accessibilityHint(feature.psychologicalBenefit)
            .accessibilityAddTraits(.isButton)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(feature.psychologicalBenefit)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}