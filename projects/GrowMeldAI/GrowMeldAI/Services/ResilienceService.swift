import Foundation
import Combine

final class ResilienceService: ObservableObject {
    // MARK: - Published State
    @Published var isSyncing = false
    @Published var lastSyncTime: Date?
    @Published var pendingOperations: Int = 0
    @Published var offlineState: OfflineState = .online
    
    // MARK: - Dependencies
    private nonisolated let networkMonitor: NetworkMonitor
    private nonisolated let cacheManager: CacheManager
    private nonisolated let syncQueue: SyncQueue
    private nonisolated let logger: ResilienceLogger
    private nonisolated let middleware: OperationMiddleware
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(
        networkMonitor: NetworkMonitor = .shared,
        cacheManager: CacheManager = .default,
        syncQueue: SyncQueue = .shared,
        logger: ResilienceLogger = .shared,
        middleware: OperationMiddleware = .default
    ) {
        self.networkMonitor = networkMonitor
        self.cacheManager = cacheManager
        self.syncQueue = syncQueue
        self.logger = logger
        self.middleware = middleware
        
        setupObservation()
    }
    
    // MARK: - Public API
    
    /// Execute operation with automatic fallback to cache
    func execute<T: Codable>(
        key: String,
        cacheTTL: TimeInterval = ResilienceConfiguration.CacheTTL.questions,
        operation: @escaping () async throws -> T
    ) async -> AsyncResult<T> {
        // Apply middleware transformations
        let wrapped = await middleware.wrapOperation(
            id: key,
            operation: operation
        )
        
        // Try network if available
        if networkMonitor.isOnline {
            let result = await AsyncResult.async(wrapped, logger: logger, context: "Operation: \(key)")
            
            if case .success(let value) = result {
                await cacheManager.set(value, for: key, ttl: cacheTTL)
                await updateLastSyncTime()
            }
            
            return result
        }
        
        // Fall back to cache
        if let cached: T = await cacheManager.get(key) {
            logger.log(.info, "📦 Served from cache: \(key)")
            return .success(cached)
        }
        
        return .failure(.networkUnavailable)
    }
    
    /// Queue operation for retry when network restored
    func queueForSync<T>(
        id: String,
        operation: @escaping () async throws -> T
    ) async {
        await syncQueue.add(
            id: id,
            operation: operation,
            onSuccess: { [weak self] _ in
                self?.logger.log(.info, "✅ Synced: \(id)")
            },
            onFailure: { [weak self] error in
                self?.logger.log(.error, "❌ Sync failed: \(id), Error: \(error)")
            }
        )
        await updatePendingCount()
    }
    
    // MARK: - Private
    
    private func setupObservation() {
        networkMonitor.$isOnline
            .removeDuplicates()
            .sink { [weak self] isOnline in
                Task {
                    await self?.handleNetworkStateChange(isOnline: isOnline)
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func handleNetworkStateChange(isOnline: Bool) async {
        offlineState = isOnline ? .online : .offline
        logger.log(isOnline ? .info : .warning, "Network: \(isOnline ? "🟢 Online" : "🔴 Offline")")
        
        if isOnline {
            await processSyncQueue()
        }
    }
    
    private func processSyncQueue() async {
        await MainActor.run {
            self.isSyncing = true
        }
        
        let result = await syncQueue.processAll()
        
        await MainActor.run {
            self.isSyncing = false
            self.lastSyncTime = Date()
            self.logger.log(
                result.failed > 0 ? .warning : .info,
                "Sync complete: \(result.succeeded) ✅, \(result.failed) ❌"
            )
        }
    }
    
    @MainActor
    private func updateLastSyncTime() {
        self.lastSyncTime = Date()
    }
    
    private func updatePendingCount() async {
        let count = await syncQueue.count()
        await MainActor.run {
            self.pendingOperations = count
        }
    }
}