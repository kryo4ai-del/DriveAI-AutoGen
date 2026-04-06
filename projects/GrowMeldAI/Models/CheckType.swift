import Foundation
// Align naming:
// Option 1: Use generic "Check" for both
enum CheckType: String, Codable, CaseIterable {
    case reminder       // From reminders domain
    case maintenance    // From maintenance domain
}

struct Check {
    let type: CheckType
    let severity: CheckSeverity  // Shared enum
    let scheduledTime: Date
    // ...
}

// Option 2: Keep separate but consistent naming
// Reminders:
//   - ReminderCheck, ReminderFrequency, ReminderService
// Maintenance:
//   - MaintenanceCheck, MaintenanceSchedule, MaintenanceCheckService
// 
// Shared (both domains):
//   - CheckSeverity  ✓
//   - CheckType (abstract base)

// Choose Option 2 for MVP (separate domains), document naming: