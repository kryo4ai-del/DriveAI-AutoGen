// Shown in MaintenanceStats
struct MaintenanceStats: Codable {
    let highSeverityCount: Int
    let mediumSeverityCount: Int
    let lowSeverityCount: Int
}

// But implementation just does:
let stats = MaintenanceStats(
    totalChecksRun: allChecks.count,
    checksResolved: allChecks.filter(\.isResolved).count,
    highSeverityCount: ???  // Not calculated
)