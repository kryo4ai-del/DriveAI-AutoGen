// ✅ FIXED
VStack(spacing: 16) {
    Text("Deine Datenschutzeinstellungen")
        .font(.title2)
        .accessibilityAddTraits(.isHeader)
    
    Divider()
    
    // Group required consents
    VStack(alignment: .leading, spacing: 12) {
        Text("Erforderlich")
            .font(.headline)
            .accessibilityAddTraits(.isHeader)
        
        ConsentSummaryRow(
            category: .essential,
            isGranted: true
        )
        .accessibilityElement(children: .combine)
    }
    .accessibilityElement(children: .contain)
    
    Divider()
    
    // Group optional consents
    VStack(alignment: .leading, spacing: 12) {
        Text("Optional")
            .font(.headline)
            .accessibilityAddTraits(.isHeader)
        
        ConsentSummaryRow(
            category: .analytics,
            isGranted: privacySettings.consents[.analytics]?.isGranted ?? false
        )
        
        ConsentSummaryRow(
            category: .notifications,
            isGranted: privacySettings.consents[.notifications]?.isGranted ?? false
        )
    }
    .accessibilityElement(children: .contain)
}

// Helper component
private struct ConsentSummaryRow: View {
    let category: ConsentCategory
    let isGranted: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isGranted ? .green : .red)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading) {
                Text(category.displayName)
                    .font(.body)
                Text(isGranted ? "Aktiviert" : "Deaktiviert")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .accessibilityLabel(category.displayName)
        .accessibilityValue(isGranted ? "Aktiviert" : "Deaktiviert")
        .accessibilityHint("Diese Einstellung kontrolliert \(category.displayName)")
    }
}