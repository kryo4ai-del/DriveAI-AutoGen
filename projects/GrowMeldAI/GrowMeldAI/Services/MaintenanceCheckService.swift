// Concern 1: Running checks
protocol MaintenanceCheckService: Sendable {
    func runWeeklyChecks() async throws -> MaintenanceCheckResult
    func resolveCheck(_ id: UUID) async throws
}

// Concern 2: Scheduling when to run
protocol MaintenanceScheduler: Sendable {
    func scheduleWeeklyChecks(_ schedule: WeeklyMaintenanceSchedule) async throws
    func cancelScheduledChecks() async throws
    func getNextScheduledDate() async -> Date?
}

// Implementation
nonisolated actor DefaultMaintenanceScheduler: MaintenanceScheduler {
    private let checkService: MaintenanceCheckService
    private var scheduledTask: Task<Void, Never>?
    
    init(checkService: MaintenanceCheckService) {
        self.checkService = checkService
    }
    
    func scheduleWeeklyChecks(_ schedule: WeeklyMaintenanceSchedule) async throws {
        guard schedule.isEnabled else {
            await cancelScheduledChecks()
            return
        }
        
        // Calculate next run
        guard let nextRun = schedule.nextExecutionDate() else {
            throw MaintenanceScheduleError.invalidSchedule
        }
        
        // Cancel existing task
        scheduledTask?.cancel()
        
        // Schedule new task
        scheduledTask = Task {
            while !Task.isCancelled {
                let delay = nextRun.timeIntervalSinceNow
                if delay > 0 {
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
                
                if !Task.isCancelled {
                    do {
                        let result = try await checkService.runWeeklyChecks()
                        await logScheduledExecution(result)
                    } catch {
                        await logSchedulingError(error)
                    }
                }
                
                // Recalculate next run (7 days later)
                // ... repeat
            }
        }
    }
}