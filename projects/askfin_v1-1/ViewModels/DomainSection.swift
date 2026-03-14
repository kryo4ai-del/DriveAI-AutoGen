import Foundation

/// One cluster in the SkillMapView — a domain with its topic competences.
struct DomainSection: Identifiable {
    let domain: TopicDomain
    let competences: [TopicCompetence]

    var id: String { domain.rawValue }

    /// When all topics in this domain are mastered, the section label
    /// renders in bold weight in SkillMapView.
    var isFullyMastered: Bool {
        competences.allSatisfy { $0.competenceLevel == .mastered }
    }
}
