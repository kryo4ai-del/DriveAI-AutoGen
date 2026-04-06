import Foundation

struct MaintenanceCheck: Identifiable, Codable, Equatable {
    let id: UUID
    let type: MaintenanceCheckType
    let severity: CheckSeverity
    let detectedAt: Date
    let affectedCategories: [String]
    let suggestedAction: String
    var isResolved: Bool
    let metadata: [String: String]  // Simplified to avoid AnyCodable complexity
    
    init(
        id: UUID = UUID(),
        type: MaintenanceCheckType,
        severity: CheckSeverity,
        detectedAt: Date = Date(),
        affectedCategories: [String] = [],
        suggestedAction: String,
        isResolved: Bool = false,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.severity = severity
        self.detectedAt = detectedAt
        self.affectedCategories = affectedCategories
        self.suggestedAction = suggestedAction
        self.isResolved = isResolved
        self.metadata = metadata
    }
}