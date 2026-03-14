import Foundation

/// Clusters of related TopicArea values.
/// Rendered as section headers in SkillMapView.
enum TopicDomain: String, CaseIterable, Codable {
    case roadRules
    case specialSituations
    case humanFactors
    case vehicleAndEnvironment

    var displayName: String {
        switch self {
        case .roadRules:             return "Verkehrsregeln"
        case .specialSituations:     return "Besondere Situationen"
        case .humanFactors:          return "Menschliche Faktoren"
        case .vehicleAndEnvironment: return "Fahrzeug & Umwelt"
        }
    }

    /// Topics grouped by domain. Computed once — not recalculated per render.
    static let topicsByDomain: [TopicDomain: [TopicArea]] = {
        Dictionary(grouping: TopicArea.allCases, by: \.domain)
    }()

    var topics: [TopicArea] {
        Self.topicsByDomain[self] ?? []
    }
}