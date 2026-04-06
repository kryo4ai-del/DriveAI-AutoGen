struct ConflictContext {
    let localTimestamp: Date
    let remoteTimestamp: Date
    let isOfflineWrite: Bool
}

// Three implementations
struct ProgressConflictResolver: ConflictResolver { ... }  // Last-write-wins
struct ExamDateConflictResolver: ConflictResolver { ... }  // Client-authoritative
struct QuestionConflictResolver: ConflictResolver { ... }  // Server-authoritative