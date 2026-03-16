import Foundation

enum RecommendationType: String, Codable {
    case practiceWeakCategory
    case reviewMaterial
    case takeSimulation
    case maintainStrength
}

// Stable ID based on type + target category:
extension ReadinessRecommendation {
    static func stableID(type: RecommendationType, categoryID: String?) -> UUID {
        let seed = "\(type.rawValue)-\(categoryID ?? "nil")"
        // Deterministic UUID from seed string
        let hash = seed.utf8.reduce(into: [UInt8](repeating: 0, count: 16)) { result, byte in
            for i in 0..<16 { result[i] &+= byte &+ UInt8(i) }
        }
        return UUID(uuid: (hash[0], hash[1], hash[2], hash[3],
                           hash[4], hash[5], hash[6], hash[7],
                           hash[8], hash[9], hash[10], hash[11],
                           hash[12], hash[13], hash[14], hash[15]))
    }
}
