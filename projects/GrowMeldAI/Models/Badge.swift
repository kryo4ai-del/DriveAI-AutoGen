struct Badge: View {
    let level: LimitApproachLevel
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
            Text(text)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeBackground)
        .foregroundColor(badgeText)
        .cornerRadius(6)
        // ✅ This is good, but parent context missing
        .accessibilityLabel(level.accessibilityLabel)
    }
}