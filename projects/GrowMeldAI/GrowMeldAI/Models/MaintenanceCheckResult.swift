struct MaintenanceCheckResult: Codable {
    let checksPerformed: [MaintenanceCheck]
    let executedAt: Date
    // ... no deletion policy defined
}