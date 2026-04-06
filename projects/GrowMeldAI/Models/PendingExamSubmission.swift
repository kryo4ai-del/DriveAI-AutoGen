import Foundation

/// Models a pending exam submission
struct PendingExamSubmission: Codable, Identifiable, Equatable {
    let id: UUID
    let examResult: ExamResult
    let timestamp: Date
    let attemptCount: Int
    
    func incrementAttempt() -> PendingExamSubmission {
        PendingExamSubmission(
            id: id,
            examResult: examResult,
            timestamp: timestamp,
            attemptCount: attemptCount + 1
        )
    }
    
    var shouldRetry: Bool {
        attemptCount < 5
    }
    
    var nextRetryDelay: TimeInterval {
        // Exponential backoff: 1s, 2s, 4s, 8s, 16s
        pow(2.0, Double(attemptCount))
    }
}

enum SyncQueueError: LocalizedError {
    case alreadyProcessing
    case persistenceFailed(String)
    case invalidSubmission(UUID)
    
    var errorDescription: String? {
        switch self {
        case .alreadyProcessing:
            return "Synchronisierung läuft bereits"
        case .persistenceFailed(let detail):
            return "Speicherungsfehler: \(detail)"
        case .invalidSubmission(let id):
            return "Ungültige Übermittlung: \(id)"
        }
    }
}

/// Thread-safe queue for offline exam submissions
actor ExamSyncQueue {
    private let persistence: LocalStorageService
    private let syncService: ExamSyncService
    
    // State
    private var pendingSubmissions: [PendingExamSubmission] = []
    private var isProcessing = false
    private let logger: Logger
    
    private static let storageKey = "pending_exam_submissions"
    
    init(
        persistence: LocalStorageService,
        syncService: ExamSyncService
    ) {
        self.persistence = persistence
        self.syncService = syncService
        self.logger = Logger(label: "ExamSyncQueue")
    }
    
    // MARK: - Public API
    
    /// Queue an exam result for sync
    func queue(_ result: ExamResult) async throws {
        let submission = PendingExamSubmission(
            id: UUID(),
            examResult: result,
            timestamp: Date(),
            attemptCount: 0
        )
        
        pendingSubmissions.append(submission)
        
        do {
            try await persistQueue()
            logger.info("Queued exam result: \(submission.id)")
        } catch {
            // Remove from memory if persistence fails
            pendingSubmissions.removeAll { $0.id == submission.id }
            throw SyncQueueError.persistenceFailed(error.localizedDescription)
        }
    }
    
    /// Process all pending submissions with retry logic
    /// - Returns: IDs of successfully synced submissions
    func processPending() async throws -> [UUID] {
        guard !isProcessing else {
            throw SyncQueueError.alreadyProcessing
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        // Create snapshot to avoid race conditions during iteration
        let snapshot = pendingSubmissions
        guard !snapshot.isEmpty else { return [] }
        
        var completedIDs: [UUID] = []
        var updatedSubmissions: [PendingExamSubmission] = []
        
        for submission in snapshot {
            do {
                // Attempt submission with retry policy
                _ = try await withRetry(policy: .aggressive) {
                    try await syncService.submitExamResult(submission.examResult)
                }
                
                completedIDs.append(submission.id)
                logger.info("Synced exam result: \(submission.id)")
                
            } catch let error as CloudFunctionError {
                logger.warning("Sync failed for \(submission.id): \(error.errorDescription ?? "")")
                
                // Non-retryable errors: discard submission
                if !error.isRetryable {
                    completedIDs.append(submission.id)
                    continue
                }
                
                // Retryable errors: update attempt count and keep
                let updated = submission.incrementAttempt()
                if updated.shouldRetry {
                    updatedSubmissions.append(updated)
                } else {
                    // Max retries reached: discard
                    completedIDs.append(submission.id)
                }
                
            } catch {
                logger.error("Unexpected error: \(error)")
                // Keep in queue for retry
                updatedSubmissions.append(submission.incrementAttempt())
            }
        }
        
        // Atomically update state
        pendingSubmissions = pendingSubmissions.filter {
            !completedIDs.contains($0.id)
        }
        
        for updated in updatedSubmissions {
            if let idx = pendingSubmissions.firstIndex(where: { $0.id == updated.id }) {
                pendingSubmissions[idx] = updated
            }
        }
        
        // Persist updated queue
        try await persistQueue()
        
        return completedIDs
    }
    
    /// Get count of pending submissions
    func pendingCount() -> Int {
        pendingSubmissions.count
    }
    
    /// Clear all pending submissions
    func clear() async throws {
        pendingSubmissions.removeAll()
        try await persistence.deleteAll(from: Self.storageKey)
        logger.info("Queue cleared")
    }
    
    /// Recover state from persistent storage (call on app startup)
    func recoverFromStorage() async throws {
        do {
            let stored = try await persistence.fetchAll(
                PendingExamSubmission.self,
                from: Self.storageKey
            )
            pendingSubmissions = stored.sorted { $0.timestamp < $1.timestamp }
            logger.info("Recovered \(pendingSubmissions.count) pending submissions")
        } catch {
            logger.warning("Failed to recover queue: \(error)")
            // Fail silently; queue starts empty
        }
    }
    
    // MARK: - Private
    
    private func persistQueue() async throws {
        do {
            try await persistence.save(pendingSubmissions, to: Self.storageKey)
        } catch {
            throw SyncQueueError.persistenceFailed(error.localizedDescription)
        }
    }
}