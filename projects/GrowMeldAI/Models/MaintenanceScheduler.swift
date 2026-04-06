// 1. MaintenanceScheduler.swift - Fixed thread safety
@MainActor
final class MaintenanceScheduler {
    private let checkService: MaintenanceCheckService
    private let userDefaults: UserDefaults
    private var scheduledTask: Task<Void, Never>?

    init(checkService: MaintenanceCheckService) {
        self.checkService = checkService
        self.userDefaults = UserDefaults.standard
    }

    func scheduleWeeklyChecks(_ schedule: WeeklyMaintenanceSchedule) async throws {
        cancelScheduledChecks()

        guard let nextRun = schedule.nextExecutionDate() else {
            throw MaintenanceServiceError.invalidSchedule
        }

        scheduledTask = Task {
            let delay = nextRun.timeIntervalSinceNow
            guard delay > 0 else { return }

            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

            _ = try await checkService.runWeeklyChecks()
            await updateLastExecutionDate(nextRun)
        }
    }

    func cancelScheduledChecks() {
        scheduledTask?.cancel()
        scheduledTask = nil
    }

    func getNextScheduledDate() async -> Date? {
        guard let scheduleData = userDefaults.data(forKey: "weeklyMaintenanceSchedule"),
              let schedule = try? JSONDecoder().decode(WeeklyMaintenanceSchedule.self, from: scheduleData) else {
            return nil
        }
        return schedule.nextExecutionDate()
    }

    private func updateLastExecutionDate(_ date: Date) async {
        guard let scheduleData = userDefaults.data(forKey: "weeklyMaintenanceSchedule"),
              var schedule = try? JSONDecoder().decode(WeeklyMaintenanceSchedule.self, from: scheduleData) else {
            return
        }
        schedule.lastExecutionDate = date
        if let encoded = try? JSONEncoder().encode(schedule) {
            userDefaults.set(encoded, forKey: "weeklyMaintenanceSchedule")
        }
    }
}