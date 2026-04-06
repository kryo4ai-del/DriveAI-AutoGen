// ExamSyncQueue.swift
import Foundation

protocol SyncQueueObserver: AnyObject {
    func syncQueueDidUpdate(_ state: SyncQueueState)
}

actor ExamSyncQueue {
    private(set) var pendingSubmissions: [StoredExamResult] = []
    private var observers = NSHashTable<AnyObject>.weakObjects()
    private let persistence: LocalStorageService

    init(persistence: LocalStorageService) {
        self.persistence = persistence
    }

    func addObserver(_ observer: SyncQueueObserver) {
        observers.add(observer)
    }

    private func notifyObservers(_ state: SyncQueueState) {
        let enumerator = observers.objectEnumerator()
        while let observer = enumerator.nextObject() as? SyncQueueObserver {
            observer.syncQueueDidUpdate(state)
        }
    }

    func queueForSync(_ result: ExamResult) async throws {
        let stored = StoredExamResult(
            id: UUID(),
            examResult: result,
            timestamp: .now,
            syncAttempts: 0
        )
        pendingSubmissions.append(stored)
        try await persistence.save(stored, to: "pending_exam_results")
        await notifyObservers(.idle(pendingCount: pendingSubmissions.count))
    }

    func processPendingQueue(using service: ExamSyncService) async throws -> [UUID] {
        guard !pendingSubmissions.isEmpty else {
            await notifyObservers(.idle(pendingCount: 0))
            return []
        }

        var completed: [UUID] = []
        let totalCount = pendingSubmissions.count

        for (index, stored) in pendingSubmissions.enumerated() {
            do {
                _ = try await service.submitExamResult(stored.examResult)
                completed.append(stored.id)
                try await persistence.delete(stored.id, from: "pending_exam_results")

                await notifyObservers(.syncing(
                    currentIndex: index + 1,
                    totalCount: totalCount,
                    currentSubmissionID: stored.id
                ))
            } catch {
                break
            }
        }

        pendingSubmissions.removeAll { completed.contains($0.id) }
        await notifyObservers(completed.isEmpty ? .idle(pendingCount: pendingSubmissions.count) :
                             .succeeded(syncedCount: completed.count))
        return completed
    }
}