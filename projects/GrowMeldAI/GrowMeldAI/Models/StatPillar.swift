struct StatPillar: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2) // Allow wrapping for longer labels
                .minimumScaleFactor(0.8)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .minimumScaleFactor(0.9)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 44) // WCAG minimum touch target
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(value)
        .accessibilityAddTraits(.isStaticText)
    }
}