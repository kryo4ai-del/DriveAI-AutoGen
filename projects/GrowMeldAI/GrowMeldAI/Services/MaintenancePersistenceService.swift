protocol MaintenancePersistenceService: Sendable {
    // Basic CRUD
    func saveCheckResult(_ result: MaintenanceCheckResult) async throws
    func getCheck(id: UUID) async throws -> MaintenanceCheck?
    func saveCheck(_ check: MaintenanceCheck) async throws
    func deleteCheck(id: UUID) async throws
    
    // Batch operations
    func saveChecks(_ checks: [MaintenanceCheck]) async throws
    func deleteChecks(ids: [UUID]) async throws
    
    // Querying
    func getChecks(type: MaintenanceCheckType) async throws -> [MaintenanceCheck]
    func getChecks(severity: CheckSeverity) async throws -> [MaintenanceCheck]
    func getChecks(after date: Date) async throws -> [MaintenanceCheck]
    func getUnresolvedChecks() async throws -> [MaintenanceCheck]
    
    // Lifecycle
    func deleteChecksOlderThan(_ date: Date) async throws -> Int
    func getStorageUsage() async throws -> Int  // Bytes
    
    // Migration support
    func migrateIfNeeded() async throws
}