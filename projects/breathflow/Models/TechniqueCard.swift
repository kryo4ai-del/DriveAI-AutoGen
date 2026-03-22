struct TechniqueCard: View {
    let technique: BreathingTechnique
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: technique.icon)
                        .font(.system(size: 24))
                        .accessibilityHidden(true)  // ✓ Hide from VoiceOver (redundant with text)
                    Spacer()
                    Text("\(technique.totalCycleDuration)s/cycle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(technique.displayName)
                    .font(.headline)
                
                Text(technique.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
            .border(isSelected ? Color.blue : Color.clear, width: 2)
            .cornerRadius(12)
        }
        .foregroundColor(.primary)
        // ✓ Add comprehensive label for VoiceOver
        .accessibilityLabel("\(technique.displayName)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint(technique.description)
        .accessibilityAddTraits([.isButton, .isSelectable])
        .accessibilityRemoveTraits(.isStaticText)
    }
}