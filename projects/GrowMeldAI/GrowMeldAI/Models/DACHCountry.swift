import Foundation

/// German-speaking DACH countries
enum DACHCountry: String, Codable, Equatable, Hashable, CaseIterable, Sendable {
    case de = "DE"  // Deutschland
    case at = "AT"  // Österreich
    case ch = "CH"  // Schweiz
    
    /// ISO 3166-1 alpha-2 country code
    var code: String {
        rawValue
    }
    
    /// Localized country name (German)
    var displayName: String {
        switch self {
        case .de: return "Deutschland"
        case .at: return "Österreich"
        case .ch: return "Schweiz"
        }
    }
    
    /// Validate postal code format for this country
    func isValidPLZFormat(_ plz: String) -> Bool {
        let trimmed = plz.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        
        let pattern: String
        switch self {
        case .de: pattern = "^[0-9]{5}$"
        case .at, .ch: pattern = "^[0-9]{4}$"
        }
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
            return regex.firstMatch(in: trimmed, range: range) != nil
        } catch {
            return false
        }
    }
    
    /// Normalize input by removing spaces and hyphens
    func normalizeInputPLZ(_ input: String) -> String {
        input.filter { $0.isNumber }
    }
    
    /// Expected length for user feedback
    var expectedPLZLength: Int {
        switch self {
        case .de: return 5
        case .at, .ch: return 4
        }
    }
}

extension DACHCountry {
    /// Get all federal states for this country
    var federalStates: [FederalState] {
        switch self {
        case .de: return FederalState.germanStates
        case .at: return FederalState.austrianStates
        case .ch: return FederalState.swissCantons
        }
    }
}