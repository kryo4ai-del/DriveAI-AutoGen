// AnalyticsEventQueue.swift
import Foundation
import os

actor AnalyticsEventQueue {
    private var pendingEvents: [StoredAnalyticsEvent] = []
    private let fileURL: URL
    private let logger = Logger(subsystem: "com.driveai.analytics", category: "queue")

    init() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documentsURL.appendingPathComponent("analytics_queue_v2.json")
        Task { await loadFromDisk() }
    }

    // Safe enqueue with persistence
    func enqueue(_ event: AnalyticsEvent) async {
        let stored = StoredAnalyticsEvent(event: event)
        pendingEvents.append(stored)
        do {
            try await saveToDisk()
            logger.debug("Event enqueued: \(event.eventName)")
        } catch {
            logger.error("Failed to persist event: \(error.localizedDescription)")
            // Keep in memory for retry
        }
    }

    // Flush with retry logic and timeout
    func flush(firebase: FirebaseAnalyticsProtocol) async -> Int {
        guard !pendingEvents.isEmpty else { return 0 }

        var flushedCount = 0
        var failedEvents: [StoredAnalyticsEvent] = []

        for var event in pendingEvents {
            do {
                // Timeout after 3 seconds
                try await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                        throw AnalyticsError.timeout
                    }
                    group.addTask {
                        try await firebase.logEvent(
                            event.event.eventName,
                            parameters: event.event.parameters
                        )
                    }
                    try await group.next()
                }

                flushedCount += 1
                logger.debug("Event flushed: \(event.event.eventName)")
            } catch {
                event.retryCount += 1
                if event.retryCount < 5 {
                    failedEvents.append(event)
                    logger.warning("Event failed (attempt \(event.retryCount)): \(error.localizedDescription)")
                } else {
                    logger.error("Event discarded after \(event.retryCount) attempts: \(event.event.eventName)")
                }
            }
        }

        pendingEvents = failedEvents
        try? await saveToDisk()
        return flushedCount
    }

    // Crash-safe persistence
    private func saveToDisk() async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(pendingEvents)
        try data.write(to: fileURL, options: .atomic)
    }

    private func loadFromDisk() async {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            logger.debug("No persisted queue found")
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            pendingEvents = try decoder.decode([StoredAnalyticsEvent].self, from: data)
            logger.debug("Loaded \(pendingEvents.count) pending events from disk")
        } catch {
            logger.error("Failed to load queue: \(error.localizedDescription)")
            // Start fresh on error
            pendingEvents = []
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    // Clear old events (older than 7 days)
    func cleanupOldEvents() async {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        pendingEvents.removeAll { $0.timestamp < cutoff }
        try? await saveToDisk()
    }
}

enum AnalyticsError: Error {
    case timeout
    case serializationFailed
    case networkFailure
}