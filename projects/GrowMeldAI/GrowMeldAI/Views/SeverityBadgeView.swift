struct SeverityBadgeView: View {
    let severity: GapSeverity
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: severity.icon)
            Text(severity.label)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            // ✅ Use dark color for any badge (contrast ≥4.5:1)
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.7))
        )
        
        // ✅ Color accents in icon only (non-text element)
        .overlay(
            Image(systemName: severity.icon)
                .foregroundColor(severity.color)
                .padding(.leading, 8),
            alignment: .leading
        )
    }
}