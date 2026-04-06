// MARK: - Services/Analytics/AnalyticsEventQueue.swift

import Foundation
import os

actor AnalyticsEventQueue {
    nonisolated private let fileURL: URL
    nonisolated private let logger = Logger(subsystem: "com.driveai.analytics", category: "queue")
    
    private var pendingEvents: [StoredAnalyticsEvent] = []
    private var isLoading = false
    
    init() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = url.appendingPathComponent("analytics_queue.json")
        Task {
            await loadFromDisk()
        }
    }
    
    /// Enqueue event for eventual delivery
    func enqueue(_ event: AnalyticsEvent) async {
        let stored = StoredAnalyticsEvent(
            event: event,
            timestamp: Date(),
            retryCount: 0
        )
        pendingEvents.append(stored)
        try? await saveToDisk()
        
        logger.debug("Event enqueued: \(event.eventName) [total: \(self.pendingEvents.count)]")
    }
    
    /// Flush pending events to Firebase (with exponential backoff)
    func flushPending(
        sendHandler: (AnalyticsEvent) async throws -> Void
    ) async -> FlushResult {
        var flushedCount = 0
        var failedCount = 0
        var failed: [StoredAnalyticsEvent] = []
        
        for var storedEvent in pendingEvents {
            do {
                // Send with 5-second timeout
                try await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        try await Task.sleep(nanoseconds: 5_000_000_000)
                        throw AnalyticsError.timeout
                    }
                    group.addTask {
                        try await sendHandler(storedEvent.event)
                    }
                    try await group.next()
                    group.cancelAll()
                }
                
                flushedCount += 1
                logger.debug("Event flushed: \(storedEvent.event.eventName)")
            } catch {
                failedCount += 1
                storedEvent.retryCount += 1
                
                // Exponential backoff: max 5 retries
                if storedEvent.retryCount < 5 {
                    failed.append(storedEvent)
                    logger.warning("Event retry \(storedEvent.retryCount): \(storedEvent.event.eventName)")
                } else {
                    logger.error("Event discarded (max retries): \(storedEvent.event.eventName)")
                }
            }
        }
        
        pendingEvents = failed
        try? await saveToDisk()
        
        return FlushResult(flushed: flushedCount, failed: failedCount, queued: pendingEvents.count)
    }
    
    func queueSize() async -> Int {
        pendingEvents.count
    }
    
    // MARK: - Private
    
    private func saveToDisk() async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(pendingEvents)
        try data.write(to: fileURL, options: .atomic)
    }
    
    private func loadFromDisk() async {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            pendingEvents = try decoder.decode([StoredAnalyticsEvent].self, from: data)
            logger.info("Loaded \(self.pendingEvents.count) events from disk")
        } catch {
            logger.error("Failed to load queue: \(error.localizedDescription)")
            pendingEvents = []
        }
        
        isLoading = false
    }
}

struct StoredAnalyticsEvent: Codable {
    let event: AnalyticsEvent
    let timestamp: Date
    var retryCount: Int
}

struct FlushResult {
    let flushed: Int
    let failed: Int
    let queued: Int
}

enum AnalyticsError: LocalizedError {
    case timeout
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .timeout:
            return "Firebase event send timeout"
        case .networkError(let msg):
            return msg
        }
    }
}