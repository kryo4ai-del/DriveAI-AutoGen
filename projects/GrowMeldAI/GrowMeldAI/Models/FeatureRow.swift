struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3.bold())
                .frame(width: 40, height: 40)
                .accessibilityHidden(true)  // Icon is decorative
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        // ✅ Semantic grouping
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(description)
        .accessibilityHint("Feature beschreibung")
    }
}