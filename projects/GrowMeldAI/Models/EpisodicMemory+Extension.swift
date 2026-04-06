import Foundation

// MARK: - EpisodicMemory Types

enum MemoryType: String, Codable {
    case event
    case observation
    case interaction
    case reflection
}

struct MemoryMetadata: Codable {
    let tags: [String]
    let summary: String
    let extra: [String: String]

    init(tags: [String] = [], summary: String = "", extra: [String: String] = [:]) {
        self.tags = tags
        self.summary = summary
        self.extra = extra
    }
}

struct EpisodicMemory: Codable, Identifiable {
    let id: String
    let type: MemoryType
    let timestamp: Date
    let categoryId: String?
    let metadata: MemoryMetadata
    let contextScore: Int

    init(id: String = UUID().uuidString,
         type: MemoryType,
         timestamp: Date = Date(),
         categoryId: String? = nil,
         metadata: MemoryMetadata = MemoryMetadata(),
         contextScore: Int = 0) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.categoryId = categoryId
        self.metadata = metadata
        self.contextScore = contextScore
    }
}

// MARK: - EpisodicMemoryError

enum EpisodicMemoryError: LocalizedError {
    case invalidMetadata
    case notFound(String)
    case persistenceFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidMetadata:
            return "Invalid or missing memory metadata."
        case .notFound(let id):
            return "EpisodicMemory not found: \(id)"
        case .persistenceFailed(let reason):
            return "Persistence failed: \(reason)"
        }
    }
}

// MARK: - EpisodicMemoryStore

final class EpisodicMemoryStore {
    static let shared = EpisodicMemoryStore()

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var cache: [EpisodicMemory] = []

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = docs.appendingPathComponent("episodic_memories.json")
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        load()
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let memories = try? decoder.decode([EpisodicMemory].self, from: data)
        else { return }
        cache = memories
    }

    private func persist() throws {
        let data = try encoder.encode(cache)
        try data.write(to: fileURL, options: .atomic)
    }

    func save(_ memory: EpisodicMemory) throws {
        if let index = cache.firstIndex(where: { $0.id == memory.id }) {
            cache[index] = memory
        } else {
            cache.append(memory)
        }
        try persist()
    }

    func fetchRecent(limit: Int = 20, offset: Int = 0) -> [EpisodicMemory] {
        let sorted = cache.sorted { $0.timestamp > $1.timestamp }
        let start = min(offset, sorted.count)
        let end = min(start + limit, sorted.count)
        return Array(sorted[start..<end])
    }

    func fetch(id: String) -> EpisodicMemory? {
        cache.first { $0.id == id }
    }

    func delete(id: String) throws {
        cache.removeAll { $0.id == id }
        try persist()
    }

    func deleteAll() throws {
        cache.removeAll()
        try persist()
    }
}

// MARK: - EpisodicMemory Extension

extension EpisodicMemory {
    func fetchRecent(limit: Int = 20, offset: Int = 0) -> [EpisodicMemory] {
        return EpisodicMemoryStore.shared.fetchRecent(limit: limit, offset: offset)
    }

    func save() throws {
        try EpisodicMemoryStore.shared.save(self)
    }

    static func fetchAll(limit: Int = 20, offset: Int = 0) -> [EpisodicMemory] {
        return EpisodicMemoryStore.shared.fetchRecent(limit: limit, offset: offset)
    }

    static func from(dictionary: [String: Any]) throws -> EpisodicMemory {
        guard let typeString = dictionary["type"] as? String,
              let type = MemoryType(rawValue: typeString)
        else {
            throw EpisodicMemoryError.invalidMetadata
        }

        guard let metadataDict = dictionary["metadata"] as? [String: Any],
              let metadataData = try? JSONSerialization.data(withJSONObject: metadataDict),
              let metadata = try? JSONDecoder().decode(MemoryMetadata.self, from: metadataData)
        else {
            throw EpisodicMemoryError.invalidMetadata
        }

        let id = dictionary["id"] as? String ?? UUID().uuidString
        let timestamp: Date
        if let ts = dictionary["timestamp"] as? TimeInterval {
            timestamp = Date(timeIntervalSince1970: ts)
        } else {
            timestamp = Date()
        }

        return EpisodicMemory(
            id: id,
            type: type,
            timestamp: timestamp,
            categoryId: dictionary["category_id"] as? String,
            metadata: metadata,
            contextScore: dictionary["context_score"] as? Int ?? 0
        )
    }
}