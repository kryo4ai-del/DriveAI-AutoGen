import Foundation

/// Postal code data model — Sendable for Swift 6 concurrency compliance
struct PostalCode: Codable, Identifiable, Hashable, Sendable {
    let id: String  // Unique identifier
    let plz: String  // Postal code (e.g., "10115")
    let city: String
    let district: String?  // Optional: district/county
    let state: String  // State/Canton (e.g., "Berlin", "Zurich")
    let country: String  // "DE", "AT", "CH"
    let latitude: Double
    let longitude: Double
    
    var displayName: String {
        let stateStr = !state.isEmpty ? ", \(state)" : ""
        return "\(plz) \(city)\(stateStr)"
    }
    
    var fullDisplayName: String {
        var parts = [plz, city]
        if let district = district, !district.isEmpty {
            parts.append(district)
        }
        parts.append(state)
        return parts.joined(separator: ", ")
    }
}

// MARK: - Validation

extension PostalCode {
    /// Validates postal code format for DE (5-digit), AT (4-digit), or CH (4-digit)
    static func isValidFormat(_ plz: String) -> Bool {
        let trimmed = plz.trimmingCharacters(in: .whitespaces)
        
        // DE: 5 digits
        if trimmed.count == 5 && trimmed.allSatisfy({ $0.isNumber }) {
            return true
        }
        
        // AT/CH: 4 digits
        if trimmed.count == 4 && trimmed.allSatisfy({ $0.isNumber }) {
            return true
        }
        
        return false
    }
    
    /// Detects country from postal code format
    static func detectedCountry(for plz: String) -> String? {
        let trimmed = plz.trimmingCharacters(in: .whitespaces)
        
        // This is approximate — ideally cross-reference with actual database
        if trimmed.count == 5 && trimmed.allSatisfy({ $0.isNumber }) {
            return "DE"
        }
        if trimmed.count == 4 && trimmed.allSatisfy({ $0.isNumber }) {
            // Could be AT or CH — return nil and require database lookup
            return nil
        }
        
        return nil
    }
}