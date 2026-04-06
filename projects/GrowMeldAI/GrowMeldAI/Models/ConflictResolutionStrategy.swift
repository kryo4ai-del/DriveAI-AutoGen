// ❌ CURRENT (UNDEFINED CONFLICT RESOLUTION)
func syncProgress(local: CategoryProgress, remote: CategoryProgress) {
    // What's the right logic here?
    // Last-write-wins?
    // Higher score?
    // Merge attempt counts?
}

// ✅ REQUIRED (Explicit strategy with timestamp)
enum ConflictResolutionStrategy {
    case lastWriteWins  // Timestamp-based
    case highestScore   // Domain-specific
    case merge          // Combine attempts
}
