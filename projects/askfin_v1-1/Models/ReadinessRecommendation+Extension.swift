import Foundation
// Stable ID based on type + target category:
extension ReadinessRecommendation {
    static func stableID(type: RecommendationType, categoryID: String?) -> UUID {
        let seed = "\(type.rawValue)-\(categoryID ?? "nil")"
        return UUID(uuidString: uuidV5String(namespace: "recommendations", name: seed))
            ?? UUID() // fallback should never trigger with valid inputs
    }
}