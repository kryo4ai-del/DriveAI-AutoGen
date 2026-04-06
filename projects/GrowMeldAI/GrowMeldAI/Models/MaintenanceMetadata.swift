/// Flexible metadata for extensibility without model changes
enum MaintenanceMetadata: Codable, Equatable {
    case string(String)
    case integer(Int)
    case double(Double)
    case date(Date)
    case boolean(Bool)
    case array([MaintenanceMetadata])
    case dictionary([String: MaintenanceMetadata])
    
    // Helpers for common patterns
    static func daysAgo(_ days: Int) -> Self {
        .integer(days)
    }
    
    static func percentageCompletion(_ rate: Double) -> Self {
        .double(rate)
    }
}

// Usage
let check = MaintenanceCheck(
    type: .staleCategoryAlert,
    severity: .high,
    suggestedAction: "...",
    metadata: [
        "daysAgo": .integer(9),
        "lastPracticedDate": .date(Date()),
        "categoryName": .string("Verkehrszeichen")
    ]
)