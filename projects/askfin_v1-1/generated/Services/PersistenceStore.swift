import Foundation

protocol PersistenceStore {
    func loadCompetences() -> [TopicArea: TopicCompetence]
    func loadSpacingQueue() -> [TopicArea: SpacingItem]
    func save(competences: [TopicArea: TopicCompetence])
    func save(spacingQueue: [TopicArea: SpacingItem])
}

final class UserDefaultsStore: PersistenceStore {
    private let defaults = UserDefaults.standard
    private let encoder  = JSONEncoder()
    private let decoder  = JSONDecoder()

    private enum Key {
        static let competences  = "driveai.competences"
        static let spacingQueue = "driveai.spacingQueue"
    }

    func loadCompetences() -> [TopicArea: TopicCompetence] {
        decode([TopicArea: TopicCompetence].self, forKey: Key.competences) ?? [:]
    }

    func loadSpacingQueue() -> [TopicArea: SpacingItem] {
        decode([TopicArea: SpacingItem].self, forKey: Key.spacingQueue) ?? [:]
    }

    func save(competences: [TopicArea: TopicCompetence]) {
        encode(competences, forKey: Key.competences)
    }

    func save(spacingQueue: [TopicArea: SpacingItem]) {
        encode(spacingQueue, forKey: Key.spacingQueue)
    }

    private func decode<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    private func encode<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}