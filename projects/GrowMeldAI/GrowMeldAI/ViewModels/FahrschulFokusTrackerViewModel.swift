// FahrschulFokusTrackerViewModel.swift
import Foundation
import Combine

final class FahrschulFokusTrackerViewModel: ObservableObject {
    @Published private(set) var model: FahrschulFokusTrackerModel
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    private let persistenceService: TopicPersistenceService

    init(persistenceService: TopicPersistenceService = UserDefaultsTopicPersistenceService()) {
        self.persistenceService = persistenceService
        self.model = FahrschulFokusTrackerModel()

        loadTopics()
    }

    func updateMasteryLevel(for topicId: UUID, newLevel: ExamTopic.MasteryLevel) {
        guard let index = model.topics.firstIndex(where: { $0.id == topicId }) else { return }

        var updatedTopics = model.topics
        updatedTopics[index].masteryLevel = newLevel
        model.topics = updatedTopics

        saveTopics()
    }

    func resetAllTopics() {
        model.topics = FahrschulFokusTrackerModel.defaultTopics
        saveTopics()
    }

    private func loadTopics() {
        isLoading = true
        defer { isLoading = false }

        do {
            let loadedTopics = try persistenceService.loadTopics()
            if !loadedTopics.isEmpty {
                model.topics = loadedTopics
            }
        } catch {
            self.error = error
            print("Failed to load topics: \(error)")
        }
    }

    private func saveTopics() {
        do {
            try persistenceService.saveTopics(model.topics)
        } catch {
            self.error = error
            print("Failed to save topics: \(error)")
        }
    }
}

protocol TopicPersistenceService {
    func loadTopics() throws -> [ExamTopic]
    func saveTopics(_ topics: [ExamTopic]) throws
}

final class UserDefaultsTopicPersistenceService: TopicPersistenceService {
    private enum Keys {
        static let topicsData = "fokusTrackerTopicsData"
    }

    func loadTopics() throws -> [ExamTopic] {
        guard let data = UserDefaults.standard.data(forKey: Keys.topicsData) else {
            return []
        }
        return try JSONDecoder().decode([ExamTopic].self, from: data)
    }

    func saveTopics(_ topics: [ExamTopic]) throws {
        let data = try JSONEncoder().encode(topics)
        UserDefaults.standard.set(data, forKey: Keys.topicsData)
    }
}