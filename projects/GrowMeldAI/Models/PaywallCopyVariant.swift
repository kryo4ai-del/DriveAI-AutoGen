// ✅ Use Localizable.strings with variant keys
enum PaywallCopyVariant: String, CaseIterable {
    case control
    case emotional
    case functional
    case urgency
    
    var headline: String {
        return NSLocalizedString(
            "paywall_\(self.rawValue)_headline",
            bundle: Bundle.main,
            comment: "Paywall headline for \(self.rawValue)"
        )
    }
    
    var subheadline: String {
        return NSLocalizedString(
            "paywall_\(self.rawValue)_subheadline",
            bundle: Bundle.main,
            comment: "Paywall subheadline for \(self.rawValue)"
        )
    }
}

// Localizable.strings (German)
"paywall_emotional_headline" = "Bestehe mit Zuversicht";
"paywall_emotional_subheadline" = "...";

// Localizable.strings (Austrian variant)
"paywall_emotional_headline" = "Bestehe mit Selbstvertrauen";  // Regional variant