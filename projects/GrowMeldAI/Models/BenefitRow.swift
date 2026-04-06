// ❌ Current
struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)  // ❌ No label
                .foregroundColor(.blue)
            Text(text)
        }
    }
}

// ✅ Fixed
struct BenefitRow: View {
    let icon: String
    let text: String
    let accessibilityLabel: String  // Add parameter
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .accessibilityLabel(Text(accessibilityLabel))
                .accessibilityHidden(false)  // Ensure it's announced
            Text(text)
                .accessibilityLabel(Text(text))
        }
        .accessibilityElement(children: .combine)  // Combine for single announcement
    }
}

// Usage:
BenefitRow(
    icon: "checkmark.circle.fill",
    text: "Tägliche Erinnerungen zu Deinen besten Lernzeiten",
    accessibilityLabel: "Haken-Symbol"
)