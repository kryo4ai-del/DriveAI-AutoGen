import Foundation
import Combine

@MainActor
final class LearningQueueService: ObservableObject {
    @Published var learningQueue: [QueuedSign] = []
    @Published var error: QueueError?
    
    private let localDataService: LocalDataService
    private var loadTask: Task<Void, Never>?
    
    init(localDataService: LocalDataService) {
        self.localDataService = localDataService
        loadQueue()
    }
    
    /// Add a sign to the learning queue
    func addSign(_ queuedSign: QueuedSign) async throws {
        // Check for duplicates
        if learningQueue.contains(where: { $0.sign.id == queuedSign.sign.id }) {
            throw QueueError.signAlreadyQueued
        }
        
        learningQueue.append(queuedSign)
        
        do {
            try await localDataService.save(queuedSign)
        } catch {
            // Rollback on save failure
            learningQueue.removeAll { $0.id == queuedSign.id }
            throw QueueError.saveFailed(error.localizedDescription)
        }
    }
    
    /// Mark a sign as completed
    func completeSign(_ id: String) async throws {
        guard let index = learningQueue.firstIndex(where: { $0.id == id }) else {
            throw QueueError.signNotFound
        }
        
        learningQueue[index].isCompleted = true
        
        do {
            try await localDataService.update(learningQueue[index])
        } catch {
            learningQueue[index].isCompleted = false
            throw QueueError.updateFailed(error.localizedDescription)
        }
    }
    
    /// Remove a sign from the queue
    func removeSign(_ id: String) async throws {
        guard learningQueue.contains(where: { $0.id == id }) else {
            throw QueueError.signNotFound
        }
        
        learningQueue.removeAll { $0.id == id }
        
        do {
            try await localDataService.delete(queueId: id)
        } catch {
            // Attempt reload on failure
            loadQueue()
            throw QueueError.deleteFailed(error.localizedDescription)
        }
    }
    
    /// Get signs due for review
    func getSignsDueForReview() -> [QueuedSign] {
        learningQueue.filter { !$0.isCompleted && $0.scheduledReviewDate <= Date() }
    }
    
    /// Load queue from persistent storage
    private func loadQueue() {
        loadTask = Task {
            do {
                let loaded = try await localDataService.fetchQueuedSigns()
                self.learningQueue = loaded
                self.error = nil
            } catch {
                self.error = .loadFailed(error.localizedDescription)
            }
        }
    }
    
    deinit {
        loadTask?.cancel()
    }
}

enum QueueError: LocalizedError {
    case signAlreadyQueued
    case signNotFound
    case loadFailed(String)
    case saveFailed(String)
    case updateFailed(String)
    case deleteFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .signAlreadyQueued:
            return "Schild befindet sich bereits in der Lernwarteschlange"
        case .signNotFound:
            return "Schild nicht gefunden"
        case .loadFailed(let msg):
            return "Warteschlange konnte nicht geladen werden: \(msg)"
        case .saveFailed(let msg):
            return "Schild konnte nicht gespeichert werden: \(msg)"
        case .updateFailed(let msg):
            return "Schild konnte nicht aktualisiert werden: \(msg)"
        case .deleteFailed(let msg):
            return "Schild konnte nicht gelöscht werden: \(msg)"
        }
    }
}