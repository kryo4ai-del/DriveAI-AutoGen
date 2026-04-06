// Add to MaintenanceCheckConfiguration

protocol MaintenanceCheckConfiguration {
    var checkRetentionDays: Int { get }        // Default: 90 days
    var resultRetentionDays: Int { get }       // Default: 180 days
    var autoDeleteScheduleDay: Int { get }     // Day of week to run cleanup
}

// Implement cleanup in scheduler

nonisolated actor MaintenanceScheduler {
    func scheduleAutoDeletion(_ schedule: WeeklyMaintenanceSchedule) async throws {
        // Every week, delete checks older than retentionDays
        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -config.checkRetentionDays,
            to: Date()
        )!
        
        let deletedCount = try await persistenceService.deleteChecksOlderThan(cutoffDate)
        logger.info("Deleted \(deletedCount) old maintenance checks")
    }
}

// Add to PrivacyPolicy:
/*
Datenspeicherung:
- Einzelne Checks: 90 Tage
- Zusammenfassende Ergebnisse: 180 Tage
- Nach Ablauf werden Daten automatisch gelöscht
*/