import Foundation

// MARK: - Cache Entry Model

struct CacheEntry<T: Codable>: Codable {
    let key: String
    let value: T
    let createdAt: Date
    let expiresAt: Date?
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    init(key: String, value: T, ttl: TimeInterval? = nil) {
        self.key = key
        self.value = value
        self.createdAt = Date()
        if let ttl = ttl {
            self.expiresAt = Date().addingTimeInterval(ttl)
        } else {
            self.expiresAt = nil
        }
    }
}

// MARK: - AnyCodable (for generic expiry checks)

private struct CacheAnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let bool as Bool:
            try container.encode(bool)
        default:
            try container.encodeNil()
        }
    }
}

// MARK: - Cache Manager

final class CacheManager {
    static let shared = CacheManager()
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.growmeldai.cachemanager", attributes: .concurrent)
    
    private var cacheDirectory: URL {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDir = urls[0].appendingPathComponent("GrowMeldAI", isDirectory: true)
        if !fileManager.fileExists(atPath: cacheDir.path) {
            try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }
        return cacheDir
    }
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Public Interface
    
    func set<T: Codable>(_ value: T, forKey key: String, ttl: TimeInterval? = nil) {
        let entry = CacheEntry(key: key, value: value, ttl: ttl)
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            do {
                let data = try self.encoder.encode(entry)
                let url = self.url(forKey: key)
                try data.write(to: url, options: .atomic)
            } catch {
                print("[CacheManager] ✗ Failed to write cache for key '\(key)': \(error)")
            }
        }
    }
    
    func get<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        queue.sync {
            let url = url(forKey: key)
            guard fileManager.fileExists(atPath: url.path) else { return nil }
            do {
                let data = try Data(contentsOf: url)
                let entry = try decoder.decode(CacheEntry<T>.self, from: data)
                if entry.isExpired {
                    remove(forKey: key)
                    return nil
                }
                return entry.value
            } catch {
                print("[CacheManager] ✗ Failed to read cache for key '\(key)': \(error)")
                return nil
            }
        }
    }
    
    func remove(forKey key: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let url = self.url(forKey: key)
            try? self.fileManager.removeItem(at: url)
        }
    }
    
    func clearAll() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let dir = self.cacheDirectory
            guard let contents = try? self.fileManager.contentsOfDirectory(
                at: dir,
                includingPropertiesForKeys: nil
            ) else { return }
            for url in contents {
                try? self.fileManager.removeItem(at: url)
            }
        }
    }
    
    func clearExpired() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let dir = self.cacheDirectory
            guard let contents = try? self.fileManager.contentsOfDirectory(
                at: dir,
                includingPropertiesForKeys: nil
            ) else { return }
            for url in contents {
                guard let data = try? Data(contentsOf: url),
                      let entry = try? self.decoder.decode(CacheEntry<CacheAnyCodable>.self, from: data),
                      entry.isExpired else { continue }
                try? self.fileManager.removeItem(at: url)
            }
        }
    }
    
    func exists(forKey key: String) -> Bool {
        queue.sync {
            fileManager.fileExists(atPath: url(forKey: key).path)
        }
    }
    
    // MARK: - Helpers
    
    private func url(forKey key: String) -> URL {
        let safeKey = key
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        return cacheDirectory.appendingPathComponent("\(safeKey).cache")
    }
}