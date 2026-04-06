extension RecommendedQuestion {
    /// Human-readable label for VoiceOver
    var accessibilityLabel: String {
        let categoryLabel = NSLocalizedString("category_\(category)", comment: "Question category")
        let urgencyLabel = urgency.displayLabel
        
        return "\(categoryLabel), Priorität: \(urgencyLabel)"
    }
    
    /// Detailed hint with spacing and performance context
    var accessibilityHint: String {
        let daysLabel = spaceInterval == 1 ? "1 Tag" : "\(spaceInterval) Tage"
        let successRate = Int((1.0 - failureRate) * 100)
        
        var hint = "Empfohlen in \(daysLabel). "
        hint += "Erfolgsquote: \(successRate)%. "
        
        if let context = emotionalContext {
            hint += context
        }
        
        return hint
    }
    
    /// Spoken value for readiness gauge
    var accessibilityValue: String {
        let strengthPercent = Int(retrievalStrength * 100)
        return "\(strengthPercent)% Abrufstärke"
    }
}