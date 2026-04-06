struct ConsentBenefitRow: View {
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline) // ✓ Scales with Dynamic Type
                .lineLimit(sizeCategory > .extraLarge ? 3 : 2)
            
            Text(description)
                .font(.subheadline)
                .lineLimit(nil) // Allow wrapping
            
            if let time = timeInfo {
                Text(time)
                    .font(.caption)
                    .lineLimit(1)
                    .accessibilityLabel("Benachrichtigungszeit: \(time)")
            }
        }
        .padding(sizeCategory > .extraLarge ? 16 : 12)
    }
}