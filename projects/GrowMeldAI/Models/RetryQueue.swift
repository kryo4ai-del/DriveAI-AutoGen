// Services/Network/RetryQueue.swift

import Foundation
import Combine

@MainActor
final class RetryQueue: ObservableObject {
    @Published private(set) var pendingRequests: [PendingRequest] = []
    @Published private(set) var isProcessing = false
    
    private let persistenceKey = "net.driveai.retry-queue"
    private let fileManager = FileManager.default
    private let maxQueueSize = 100
    private let maxRequestAge: TimeInterval = 86400  // 24 hours
    
    // ✅ REQUIRED: Document directory setup
    private var documentDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let driveAIDir = paths[0].appendingPathComponent("net.driveai")
        
        try? fileManager.createDirectory(
            at: driveAIDir,
            withIntermediateDirectories: true
        )
        return driveAIDir
    }
    
    init() {
        loadPersistedQueue()
        removeExpiredRequests()
    }
    
    func enqueue(_ request: PendingRequest) throws {
        if pendingRequests.count >= maxQueueSize {
            pendingRequests.removeFirst()  // FIFO when full
        }
        
        var mutableRequest = request
        mutableRequest.retryCount = 0
        pendingRequests.append(mutableRequest)
        persistQueue()
    }
    
    func remove(_ id: UUID) {
        pendingRequests.removeAll { $0.id == id }
        persistQueue()
    }
    
    private func removeExpiredRequests() {
        let cutoff = Date().addingTimeInterval(-maxRequestAge)
        pendingRequests.removeAll { $0.createdAt < cutoff }
        if !pendingRequests.isEmpty {
            persistQueue()
        }
    }
    
    private func persistQueue() {
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(pendingRequests) else { return }
        
        let fileURL = documentDirectory.appendingPathComponent(persistenceKey)
        try? encoded.write(to: fileURL)
    }
    
    private func loadPersistedQueue() {
        let fileURL = documentDirectory.appendingPathComponent(persistenceKey)
        guard let data = try? Data(contentsOf: fileURL) else { return }
        
        if let decoded = try? JSONDecoder().decode([PendingRequest].self, from: data) {
            pendingRequests = decoded
        }
    }
}