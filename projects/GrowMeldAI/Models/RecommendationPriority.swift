enum RecommendationPriority: Int, Comparable, Codable {
    case low = 3
    case medium = 2
    case high = 1
    case critical = 0  // Sorts first
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct RecommendationAction {
    var priority: RecommendationPriority = .medium
    // ...
}

// Usage: sort by priority automatically
let sorted = actions.sorted(by: { $0.priority < $1.priority })