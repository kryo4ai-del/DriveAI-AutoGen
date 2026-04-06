extension DACHCountry {
    /// User-friendly, accessible validation error message
    func accessibleValidationError(for input: String) -> String {
        let normalized = normalizeInputPLZ(input)
        
        if normalized.isEmpty {
            return "PLZ erforderlich. Bitte \(expectedPLZLength) Ziffern eingeben."
        }
        
        if normalized.count < expectedPLZLength {
            let remaining = expectedPLZLength - normalized.count
            return "PLZ unvollständig. \(remaining) weitere Ziffern erforderlich."
        }
        
        if !isValidPLZFormat(normalized) {
            return "Ungültige PLZ für \(displayName). Erwartet: \(expectedPLZLength) Ziffern."
        }
        
        return "PLZ validiert."
    }
}