import Foundation

struct CoachingRecommendation: Identifiable {
    let id: UUID
    let headline: String
    let evidence: String
    let psychologicalCue: String
    let actionItems: [String]
    let priority: CoachingPriority

    enum CoachingPriority: Comparable {
        case immediate
        case soon
        case maintenance

        var badgeColor: Color {
            switch self {
            case .immediate: return .red
            case .soon: return .orange
            case .maintenance: return .green
            }
        }

        var accessibilityDescription: String {
            switch self {
            case .immediate: return NSLocalizedString("priority.immediate.accessibility",
                                                    bundle: .main,
                                                    comment: "Immediate priority accessibility description")
            case .soon: return NSLocalizedString("priority.soon.accessibility",
                                               bundle: .main,
                                               comment: "Soon priority accessibility description")
            case .maintenance: return NSLocalizedString("priority.maintenance.accessibility",
                                                      bundle: .main,
                                                      comment: "Maintenance priority accessibility description")
            }
        }
    }
}