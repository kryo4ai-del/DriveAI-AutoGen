// ❌ CURRENT (too small):
struct RegionCard: View {
    let region: PostalCodeRegion
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(region.name)
                .font(.headline)
            Text(region.state)
                .font(.caption)
        }
        .padding(8)  // ❌ Too small padding
        .frame(minHeight: 40)  // ❌ Below 44pt minimum
    }
}

// ✅ FIXED – Meets 44×44pt minimum:
struct RegionCard: View {
    let region: PostalCodeRegion
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(region.name)
                            .font(.headline)
                            .lineLimit(2)
                        Text(region.state)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // ✅ Traffic level indicator
                    Text(region.trafficLevel.icon)
                        .font(.title3)
                }
                .padding(16)  // ✅ Sufficient padding
                .frame(minHeight: 56)  // ✅ EXCEEDS 44pt minimum
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        // ✅ CRITICAL: Explicit accessibility setup
        .accessibilityLabel(region.name)
        .accessibilityValue(
            "Bundesland: \(region.state), Verkehr: \(region.trafficLevel.displayName)"
        )
        .accessibilityHint("Doppeltippen zum Auswählen")
        .accessibilityAddTraits(.isButton)
    }
}