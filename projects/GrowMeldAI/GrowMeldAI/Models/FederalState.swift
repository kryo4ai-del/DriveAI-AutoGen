struct FederalState: Codable, Equatable, Hashable, Sendable {
    // ... existing properties ...
    
    /// Accessibility label (avoid abbreviations)
    var accessibilityName: String {
        displayName
    }
    
    /// Abbreviated form for compact UI display
    var compactName: String {
        abbreviation
    }
}