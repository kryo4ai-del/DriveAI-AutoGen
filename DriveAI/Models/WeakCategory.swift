// Each model has this pattern:
struct WeakCategory {
    var formattedScore: String { "\(correctPercentage)%" }
    var priorityLabel: String { ... }
    
    static let preview = WeakCategory(...)
    
    enum CodingKeys { ... }
}

// Repeated 5 times across models