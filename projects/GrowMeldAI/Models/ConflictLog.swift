struct ConflictLog {
    let timestamp: Date
    let localVersion: String      // SHA256 of local progress
    let cloudVersion: String      // SHA256 of cloud progress
    let resolvedVersion: String   // SHA256 of merged result
    let dataLost: [String]        // Fields that were overwritten (empty for LWW)
}
// Stored locally for debugging; exposed in Settings > Advanced