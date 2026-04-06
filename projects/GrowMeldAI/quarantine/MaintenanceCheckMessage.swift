struct MaintenanceCheckMessage {
    let templateKey: String
    let parameters: [String: Any]
    let accessibilityEmojis: [String]?  // None for VoiceOver
    
    func accessibilityDescription(for locale: Locale = .current) -> String {
        // Return message WITHOUT emoji for accessibility users
        return NSLocalizedString(
            templateKey + ".a11y",  // Separate key: "maintenance.stale_category_alert.a11y"
            tableName: "MaintenanceStrings",
            value: localizedDescription(for: locale),
            comment: "Accessible version without emoji"
        )
    }
}

// Localizable.strings
"maintenance.stale_category_alert" = "📚 %@ übe ich seit %@ nicht. Möchte ich 5 Minuten üben?";
"maintenance.stale_category_alert.a11y" = "%@ übe ich seit %@ nicht. Möchte ich 5 Minuten üben?";