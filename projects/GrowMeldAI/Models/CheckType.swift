import Foundation

enum CheckType: String, Codable, CaseIterable {
    case reminder
    case maintenance
}

enum CheckSeverity: String, Codable, CaseIterable {
    case low
    case medium
    case high
}

struct Check {
    let type: CheckType
    let severity: CheckSeverity
    let scheduledTime: Date
}