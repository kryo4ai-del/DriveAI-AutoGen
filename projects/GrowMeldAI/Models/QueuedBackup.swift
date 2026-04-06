// Define or use existing LocalDataService for queue persistence
private let queueDatabase: LocalDataService  // Reuse existing SQLite wrapper

// Or create dedicated queue table:
/*
CREATE TABLE IF NOT EXISTS BackupQueue (
    id TEXT PRIMARY KEY,
    snapshot BLOB NOT NULL,
    attemptCount INTEGER DEFAULT 0,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lastAttemptAt TIMESTAMP
)
*/

struct QueuedBackup: Codable {
    let id: UUID
    let snapshot: ProgressSnapshot
    let attemptCount: Int
    let createdAt: Date
    let lastAttemptAt: Date?
}