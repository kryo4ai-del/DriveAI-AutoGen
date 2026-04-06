// DriveAI/Data/Repositories/SyncRepository.swift
import Foundation
import Combine

@MainActor
final class SyncRepository: SyncRepositoryProtocol {
    @Published var syncState: SyncState = .idle

    private let apiClient: PlantIdAPIClient
    private let localRepository: any QuestionRepositoryProtocol
    private let userDefaults: UserDefaults
    private let lastSyncKey = "lastSyncedAt"
    private var syncTask: Task<Void, Never>?

    init(apiClient: PlantIdAPIClient,
         localRepository: any QuestionRepositoryProtocol,
         userDefaults: UserDefaults = .standard) {
        self.apiClient = apiClient
        self.localRepository = localRepository
        self.userDefaults = userDefaults
    }

    func syncCatalog(force: Bool = false) async throws {
        // Cancel any ongoing sync
        syncTask?.cancel()

        syncTask = Task {
            await performSync(force: force)
        }

        // Wait for the task to complete or be cancelled
        try Task.checkCancellation()
        try await syncTask?.value
    }

    private func performSync(force: Bool) async {
        // Skip if synced recently (unless forced)
        if !force, let last = lastSyncDate(), Date().timeIntervalSince(last) < 3600 {
            syncState = .success(lastSyncedAt: last)
            return
        }

        syncState = .syncing(progress: 0)

        do {
            let response = try await apiClient.syncCatalog(since: lastSyncDate())

            // Save to local storage
            let questions = response.questions.map { $0.toDomain() }
            let categories = response.categories.map { $0.toDomain() }

            try await localRepository.saveSyncedQuestions(questions)
            try await localRepository.saveSyncedCategories(categories)

            // Update sync timestamp
            userDefaults.set(Date(), forKey: lastSyncKey)

            let syncedAt = ISO8601DateFormatter().date(from: response.syncedAt) ?? Date()
            syncState = .success(lastSyncedAt: syncedAt)

        } catch {
            syncState = .failure(error: error)
            throw error
        }
    }

    private func lastSyncDate() -> Date? {
        userDefaults.object(forKey: lastSyncKey) as? Date
    }
}