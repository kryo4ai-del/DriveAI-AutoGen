import Foundation

// MARK: - Storage Protocol

protocol MemoryStorageProvider: Sendable {
    func read<T: Decodable>(key: String, type: T.Type) async throws -> T
    func write<T: Encodable>(key: String, value: T) async throws
    func delete(key: String) async throws
}

// MARK: - File System Storage Provider (Production)

actor FileSystemStorageProvider: MemoryStorageProvider {
    private let directory: URL

    init(directory: URL? = nil) {
        if let directory = directory {
            self.directory = directory
        } else {
            let appSupport = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first ?? FileManager.default.temporaryDirectory
            self.directory = appSupport.appendingPathComponent("MemoryStorage", isDirectory: true)
        }
        try? FileManager.default.createDirectory(
            at: self.directory,
            withIntermediateDirectories: true
        )
    }

    private func fileURL(for key: String) -> URL {
        let safeKey = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key
        return directory.appendingPathComponent("\(safeKey).json")
    }

    func write<T: Encodable>(key: String, value: T) async throws {
        let data = try JSONEncoder().encode(value)
        try data.write(to: fileURL(for: key), options: .atomic)
    }

    func read<T: Decodable>(key: String, type: T.Type) async throws -> T {
        let url = fileURL(for: key)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw StorageError.notFound(key: key)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func delete(key: String) async throws {
        let url = fileURL(for: key)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }
}

// MARK: - In-Memory Storage Provider (Testing)

actor InMemoryStorageProvider: MemoryStorageProvider {
    private var data: [String: Data] = [:]

    func write<T: Encodable>(key: String, value: T) async throws {
        data[key] = try JSONEncoder().encode(value)
    }

    func read<T: Decodable>(key: String, type: T.Type) async throws -> T {
        guard let encoded = data[key] else {
            throw StorageError.notFound(key: key)
        }
        return try JSONDecoder().decode(T.self, from: encoded)
    }

    func delete(key: String) async throws {
        data.removeValue(forKey: key)
    }
}

// MARK: - Storage Errors

enum StorageError: LocalizedError {
    case notFound(key: String)
    case encodingFailed(key: String, underlying: Error)
    case decodingFailed(key: String, underlying: Error)

    var errorDescription: String? {
        switch self {
        case .notFound(let key):
            return "No value found for key: \(key)"
        case .encodingFailed(let key, let error):
            return "Failed to encode value for key '\(key)': \(error.localizedDescription)"
        case .decodingFailed(let key, let error):
            return "Failed to decode value for key '\(key)': \(error.localizedDescription)"
        }
    }
}

// MARK: - Memory Service

@MainActor
final class MemoryService {
    private let storage: any MemoryStorageProvider

    init(storage: any MemoryStorageProvider) {
        self.storage = storage
    }

    func save<T: Encodable>(_ value: T, forKey key: String) async throws {
        try await storage.write(key: key, value: value)
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) async throws -> T {
        try await storage.read(key: key, type: type)
    }

    func remove(forKey key: String) async throws {
        try await storage.delete(key: key)
    }
}