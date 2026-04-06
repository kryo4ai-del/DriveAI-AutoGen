// In account deletion flow (if exists):

protocol AccountDeletionService {
    func deleteAllUserData() async throws
}

extension AccountDeletionService {
    func deleteUserDataForMaintenanceChecks() async throws {
        // Must include:
        try await maintenanceService.getAllChecks()
            .forEach { check in
                try await maintenanceService.dismissCheck(check.id)
            }
    }
}