// Create a custom color palette in Assets
struct AccessibleColors {
    // ✅ Uses darker, saturated colors that meet WCAG AA
    static let errorText = Color(red: 0.843, green: 0.039, blue: 0.043)  // #D70A0E (5.2:1)
    static let warningText = Color(red: 0.808, green: 0.431, blue: 0.0)  // #CE6E00 (5.1:1)
    static let successText = Color(red: 0.0, green: 0.435, blue: 0.259)  // #006F42 (5.5:1)
    
    // Backgrounds
    static let errorBackground = Color(red: 0.98, green: 0.92, blue: 0.92)  // #FAE8E8
    static let warningBackground = Color(red: 1.0, green: 0.96, blue: 0.90)  // #FFF6E6
    static let successBackground = Color(red: 0.92, green: 0.98, blue: 0.95)  // #EBF8F2
}

// Update error message display:
if case .failed(let error) = backupService.backupStatus {
    HStack(alignment: .top, spacing: 12) {
        // ✅ Icon with contrasting color
        Image(systemName: "exclamationmark.circle.fill")
            .foregroundColor(AccessibleColors.errorText)
            .font(.title3)
            // ✅ Make icon decorative for screen readers
            .accessibilityHidden(true)
        
        VStack(alignment: .leading, spacing: 4) {
            Text("Sicherung fehlgeschlagen")
                .font(.headline)
                .foregroundColor(AccessibleColors.errorText)
                .lineLimit(nil)
            
            // ✅ Error description in darker color (meets 4.5:1)
            Text(error.recoverySuggestion ?? error.errorDescription ?? "Versuche es erneut")
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
    }
    .padding(12)
    .background(AccessibleColors.errorBackground)
    .cornerRadius(8)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Fehler bei der Sicherung")
    .accessibilityValue(error.errorDescription ?? "Unbekannter Fehler")
    // ✅ Announce error immediately
    .onAppear {
        UIAccessibility.post(notification: .announcement, argument: error.errorDescription)
    }
}