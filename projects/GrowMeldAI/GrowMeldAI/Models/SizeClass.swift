import Foundation

enum SizeClass: String, Codable, Hashable, CaseIterable {
    case critical      // Kritische Fragen
    case important     // Wichtige Fragen
    case reference     // Referenzfragen
    case contextual    // Kontextfragen

    var displayName: String {
        switch self {
        case .critical: return "Kritisch"
        case .important: return "Wichtig"
        case .reference: return "Referenz"
        case .contextual: return "Kontext"
        }
    }
}