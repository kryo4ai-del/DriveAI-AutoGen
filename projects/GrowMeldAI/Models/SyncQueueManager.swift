// ViewModels/SyncQueueManager.swift
import Foundation
import Combine
import os

@MainActor
final class SyncQueueManager: ObservableObject {
    // MARK: - Public State
    
    @Published private(set) var pendingCount = 0
    @Published private(set) var syncedCount = 0
    @Published private(set) var failedCount = 0
    @Published private(set) var isSyncing = false
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var lastError: SyncError?
    
    // MARK: - Private Dependencies
    
    private let localDataService: LocalDataService
    private let apiService: APIService
    private let networkMonitor: NetworkMonitor
    
    private var queueItems: [SyncQueueItem] = []
    private var cancellables = Set<AnyCancellable>()
    
    private let logger = Logger(subsystem: "com.driveai", category: "SyncQueue")
    private let persistenceKey = "com.driveai.syncQueue"
    
    // Exponential backoff with jitter
    private let maxRetries = 5
    private let baseDelay: TimeInterval = 1.0
    private let maxDelay: TimeInterval = 32.0
    
    // MARK: - Lifecycle
    
    init(
        localDataService: LocalDataService,
        apiService: APIService,
        networkMonitor: NetworkMonitor
    ) {
        self.localDataService = localDataService
        self.apiService = apiService
        self.networkMonitor = networkMonitor
        
        loadPersistedQueue()
        setupAutoSync()
    }
    
    // MARK: - Public API
    
    func enqueueAnswer(_ answer: UserAnswer) async {
        let item = SyncQueueItem(
            id: UUID(),
            answer: answer,
            createdAt: Date(),
            retryCount: 0,
            status: .pending
        )
        
        // Persist locally first
        do {
            try await localDataService.saveAnswer(answer)
            queueItems.append(item)
            await persistQueue()
            updateCounts()
            
            logger.debug("Answer enqueued: \(answer.questionId)")
            
            // Attempt immediate sync if online
            if networkMonitor.isConnected {
                await syncQueue()
            }
        } catch {
            logger.error("Failed to enqueue answer: \(error.localizedDescription)")
            lastError = .saveFailed(error)
        }
    }
    
    func syncQueue() async {
        guard !isSyncing else {
            logger.debug("Sync already in progress")
            return
        }
        
        guard networkMonitor.isConnected else {
            logger.warning("Cannot sync: no network connection")
            lastError = .offline
            return
        }
        
        isSyncing = true
        defer { isSyncing = false }
        
        let pendingItems = queueItems.filter { $0.status == .pending }
        guard !pendingItems.isEmpty else {
            lastSyncDate = Date()
            return
        }
        
        logger.info("Starting sync of \(pendingItems.count) items")
        
        for batch in pendingItems.chunked(into: 20) {
            await syncBatch(batch)
        }
        
        lastSyncDate = Date()
        await persistQueue()
        updateCounts()
    }
    
    func clearFailedItems() {
        queueItems.removeAll { $0.status == .failed }
        Task { await persistQueue() }
        updateCounts()
    }
    
    // MARK: - Private
    
    private func setupAutoSync() {
        // Sync when network becomes available
        networkMonitor.$isConnected
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .filter { $0 }
            .sink { [weak self] _ in
                Task { await self?.syncQueue() }
            }
            .store(in: &cancellables)
        
        // Periodic sync attempt every 5 minutes
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.syncQueue() }
            }
            .store(in: &cancellables)
    }
    
    private func syncBatch(_ batch: [SyncQueueItem]) async {
        for attempt in 0..<maxRetries {
            do {
                // Check network before each attempt
                guard networkMonitor.isConnected else {
                    logger.warning("Network lost during batch sync")
                    lastError = .offline
                    return
                }
                
                let answers = batch.map { $0.answer }
                
                // Sync with 30-second timeout
                try await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        try await Task.sleep(nanoseconds: 30_000_000_000)
                        throw SyncError.timeout
                    }
                    
                    group.addTask {
                        try await self.apiService.syncAnswers(answers)
                    }
                    
                    // First task to complete wins
                    _ = try await group.next()
                    group.cancelAll()
                }
                
                // Mark as synced
                for item in batch {
                    if let index = queueItems.firstIndex(where: { $0.id == item.id }) {
                        queueItems[index].status = .synced
                    }
                }
                
                logger.info("Batch synced: \(batch.count) items")
                lastError = nil
                return
                
            } catch {
                let delay = calculateBackoff(attempt: attempt)
                logger.warning("Batch sync failed (attempt \(attempt + 1)/\(maxRetries)): \(error.localizedDescription)")
                
                // Update retry count and status
                for item in batch {
                    if let index = queueItems.firstIndex(where: { $0.id == item.id }) {
                        queueItems[index].retryCount += 1
                        
                        if queueItems[index].retryCount >= maxRetries {
                            queueItems[index].status = .failed
                            lastError = .retryExhausted(error)
                        }
                    }
                }
                
                // Don't retry if network is gone
                if !networkMonitor.isConnected {
                    logger.warning("Network unavailable, stopping retry attempts")
                    lastError = .offline
                    return
                }
                
                // Wait before next attempt
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }
    
    private func calculateBackoff(attempt: Int) -> TimeInterval {
        let exponential = min(pow(2.0, Double(attempt)), maxDelay / baseDelay)
        let base = baseDelay * exponential
        
        // Add jitter: ±20% of base
        let jitter = Double.random(in: -0.2...0.2) * base
        let delay = max(0, base + jitter)
        
        return min(delay, maxDelay)
    }
    
    private func loadPersistedQueue() {
        if let data = UserDefaults.standard.data(forKey: persistenceKey),
           let decoded = try? JSONDecoder().decode([SyncQueueItem].self, from: data) {
            queueItems = decoded
            logger.info("Loaded \(decoded.count) queued items from storage")
        }
    }
    
    private func persistQueue() async {
        // Only keep pending and failed items (remove synced)
        let itemsToKeep = queueItems.filter { $0.status != .synced }
        
        do {
            let encoded = try JSONEncoder().encode(itemsToKeep)
            UserDefaults.standard.set(encoded, forKey: persistenceKey)
            logger.debug("Queue persisted: \(itemsToKeep.count) items")
        } catch {
            logger.error("Failed to persist queue: \(error.localizedDescription)")
        }
    }
    
    private func updateCounts() {
        pendingCount = queueItems.filter { $0.status == .pending }.count
        syncedCount = queueItems.filter { $0.status == .synced }.count
        failedCount = queueItems.filter { $0.status == .failed }.count
    }
}

// MARK: - Models

struct SyncQueueItem: Codable, Identifiable {
    enum Status: String, Codable {
        case pending, synced, failed
    }
    
    let id: UUID
    let answer: UserAnswer
    let createdAt: Date
    var retryCount: Int
    var status: Status
}

// Utility extension
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}