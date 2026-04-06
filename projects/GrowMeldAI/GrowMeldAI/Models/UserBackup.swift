// Add version field to UserBackup
struct UserBackup: Codable {
    let version: Int = 1  // Increment on breaking changes
    // ...
}

// Add migration logic in repository
private func migrateIfNeeded(_ backup: UserBackup) -> UserBackup {
    switch backup.version {
    case 1:
        return backup  // No migration needed
    default:
        return backup
    }
}