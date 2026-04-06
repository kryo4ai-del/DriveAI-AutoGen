@MainActor
final class DiagnosticEngine {
    
    private var cachedSnapshot: UserDiagnosticProfile?
    private var lastSnapshotDataHash: String?
    
    /// Record attempt + invalidate cache synchronously
    func recordQuestionAttempt(_ attempt: QuestionAttempt) async throws {
        // Append to persistence
        try await dataService.appendAttempt(attempt)
        
        // ← CRITICAL: Invalidate cache IMMEDIATELY
        self.cachedSnapshot = nil
        self.lastSnapshotDataHash = nil
        
        // Recompute with fresh data
        let freshSnapshot = try await generateDiagnosticSnapshot(skipCache: true)
        
        // Save + notify observers
        try await dataService.saveDiagnosticProfile(freshSnapshot)
        await MainActor.run {
            self.snapshotDidChange(freshSnapshot)
        }
    }
    
    /// Get snapshot with data-change detection
    func generateDiagnosticSnapshot(skipCache: Bool = false) async throws -> UserDiagnosticProfile {
        if !skipCache, let cached = cachedSnapshot {
            // Verify data hasn't changed since cache
            let currentDataHash = try await computeDataHash()
            if currentDataHash == lastSnapshotDataHash {
                return cached  // ← Safe to return: data unchanged
            }
        }
        
        // Recompute
        let snapshot = try await computeSnapshot()
        
        // Update cache
        self.cachedSnapshot = snapshot
        self.lastSnapshotDataHash = try await computeDataHash()
        
        return snapshot
    }
    
    /// Fast hash of underlying data (not snapshot itself)
    private func computeDataHash() async throws -> String {
        let history = try await dataService.loadPerformanceHistory()
        let historyData = try JSONEncoder().encode(history)
        
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        historyData.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(historyData.count), &digest)
        }
        
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    // Publish snapshot updates
    @Published private(set) var currentSnapshot: UserDiagnosticProfile?
    
    private func snapshotDidChange(_ snapshot: UserDiagnosticProfile) {
        self.currentSnapshot = snapshot
    }
}