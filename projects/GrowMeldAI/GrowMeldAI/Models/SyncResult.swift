// File: Domain/Services/OfflineSyncService.swift
import Foundation

actor OfflineSyncService {
    private let localRepository: LocalQuestionRepository
    private let remoteRepository: RemoteQuestionRepository
    private let syncQueue: SyncQueue
    private let conflictResolver: ConflictResolutionService
    
    private var isSyncing = false
    
    init(
        localRepository: LocalQuestionRepository,
        remoteRepository: RemoteQuestionRepository,
        syncQueue: SyncQueue,
        conflictResolver: ConflictResolutionService
    ) {
        self.localRepository = localRepository
        self.remoteRepository = remoteRepository
        self.syncQueue = syncQueue
        self.conflictResolver = conflictResolver
    }
    
    // MARK: - Public Sync Operations
    
    /// Synchronize question catalog from remote
    func syncQuestions(priority: SyncPriority = .high) async throws -> SyncResult {
        guard !isSyncing else {
            throw ResilienceError.sync(.validationFailed(reason: "Sync already in progress"))
        }
        
        isSyncing = true
        defer { isSyncing = false }
        
        let startTime = Date()
        
        do {
            // Try differential sync first
            let lastSync = try await localRepository.getLastSyncDate()
            let remoteQuestions = try await remoteRepository.fetchQuestionsSince(lastSync)
            
            let upsertCount = try await localRepository.upsertQuestions(remoteQuestions)
            try await localRepository.updateLastSyncDate(Date())
            
            return SyncResult(
                syncedCount: upsertCount,
                totalRemote: remoteQuestions.count,
                duration: Date().timeIntervalSince(startTime),
                timestamp: Date()
            )
            
        } catch let error as ResilienceError {
            // On network error, fallback to full sync
            if case .network = error {
                return try await syncQuestionsFallback(startTime: startTime)
            }
            throw error
        }
    }
    
    /// Upload pending user answers with conflict resolution
    func uploadPendingAnswers(policy: SyncPolicy = .highPriority) async throws {
        let pendingOps = try await syncQueue.getPendingOperations(type: .uploadAnswer)
        
        var conflicts: [String] = []
        
        for operation in pendingOps {
            do {
                try await syncQueue.updateStatus(operation.id, to: .processing)
                
                let answer = try decode(UserAnswer.self, from: operation.payload)
                try await uploadAnswerWithRetry(answer, policy: policy)
                
                try await syncQueue.markAsProcessed(operation.id)
                
            } catch let error as ResilienceError {
                if case .sync(.conflictDetected) = error {
                    conflicts.append(operation.id)
                    try await syncQueue.markAsConflicted(operation.id, error: error)
                } else if error.recoveryStrategy.shouldRetry {
                    try await syncQueue.incrementRetryCount(operation.id)
                } else {
                    try await syncQueue.markAsFailedPermanently(operation.id, error: error)
                }
            }
        }
        
        if !conflicts.isEmpty {
            throw ResilienceError.sync(.conflictDetected(resourceId: conflicts.joined(separator: ", ")))
        }
    }
    
    /// Process entire sync queue with priority ordering
    func processSyncQueue(policy: SyncPolicy = .default) async throws -> SyncQueueResult {
        let pending = try await syncQueue.getAllPending()
        
        var processed = 0
        var failed = 0
        var conflicts = 0
        
        for operation in pending {
            var attempt = 0
            
            while attempt < policy.maxRetries {
                do {
                    try await syncQueue.updateStatus(operation.id, to: .processing)
                    try await executeOperation(operation, policy: policy)
                    try await syncQueue.markAsProcessed(operation.id)
                    processed += 1
                    break
                    
                } catch let error as ResilienceError {
                    attempt += 1
                    
                    if case .sync(.conflictDetected) = error {
                        try await syncQueue.markAsConflicted(operation.id, error: error)
                        conflicts += 1
                        break
                    } else if attempt < policy.maxRetries && error.recoveryStrategy.shouldRetry {
                        let delay = policy.delayForAttempt(attempt)
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    } else {
                        try await syncQueue.markAsFailedPermanently(operation.id, error: error)
                        failed += 1
                        break
                    }
                }
            }
        }
        
        try await syncQueue.clearCompleted()
        
        return SyncQueueResult(
            processed: processed,
            failed: failed,
            conflicts: conflicts,
            timestamp: Date()
        )
    }
    
    /// Resolve a conflicted sync operation
    func resolveConflict(
        operationId: String,
        strategy: ConflictResolutionService.ResolutionStrategy
    ) async throws {
        guard let operation = try await syncQueue.getOperation(operationId) else {
            throw ResilienceError.offline(.resourceNotFound(resourceId: operationId))
        }
        
        guard case .uploadAnswer = operation.type else {
            throw ResilienceError.sync(.validationFailed(reason: "Only answer uploads support conflict resolution"))
        }
        
        let answer = try decode(UserAnswer.self, from: operation.payload)
        let remoteAnswer = try await remoteRepository.fetchAnswer(id: answer.id)
        
        let resolved = try await conflictResolver.resolveAnswerConflict(
            local: answer,
            remote: remoteAnswer,
            strategy: strategy
        )
        
        // Re-encode and update queue
        let newPayload = try JSONEncoder().encode(resolved)
        try await syncQueue.updatePayload(operationId, newPayload: newPayload)
        
        // Retry upload
        try await uploadAnswerWithRetry(resolved, policy: .highPriority)
        try await syncQueue.markAsProcessed(operationId)
    }
    
    // MARK: - Private Helpers
    
    private func uploadAnswerWithRetry(
        _ answer: UserAnswer,
        policy: SyncPolicy
    ) async throws {
        var lastError: Error?
        
        for attempt in 1...policy.maxRetries {
            do {
                try await remoteRepository.uploadAnswer(answer)
                return
            } catch {
                lastError = error
                
                if attempt < policy.maxRetries {
                    let delay = policy.delayForAttempt(attempt)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? ResilienceError.offline(.resourceNotFound(resourceId: answer.id))
    }
    
    private func syncQuestionsFallback(startTime: Date) async throws -> SyncResult {
        let remoteQuestions = try await remoteRepository.fetchAllQuestions()
        try await localRepository.clearAndInsert(remoteQuestions)
        try await localRepository.updateLastSyncDate(Date())
        
        return SyncResult(
            syncedCount: remoteQuestions.count,
            totalRemote: remoteQuestions.count,
            duration: Date().timeIntervalSince(startTime),
            timestamp: Date()
        )
    }
    
    private func executeOperation(_ operation: SyncQueue.SyncOperation, policy: SyncPolicy) async throws {
        switch operation.type {
        case .uploadAnswer:
            let answer = try decode(UserAnswer.self, from: operation.payload)
            try await remoteRepository.uploadAnswer(answer)
            
        case .updateProgress:
            let progress = try decode(ProgressUpdate.self, from: operation.payload)
            try await remoteRepository.updateProgress(progress)
            
        case .syncQuestions:
            _ = try await syncQuestions(priority: operation.priority)
        }
    }
    
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ResilienceError.offline(.corruptedCache)
        }
    }
}

// MARK: - Result Types

struct SyncResult: Sendable {
    let syncedCount: Int
    let totalRemote: Int
    let duration: TimeInterval
    let timestamp: Date
}

struct SyncQueueResult: Sendable {
    let processed: Int
    let failed: Int
    let conflicts: Int
    let timestamp: Date
}