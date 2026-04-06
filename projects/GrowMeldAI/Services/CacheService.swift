import Foundation
import Combine

@MainActor
final class CacheService: ObservableObject {
    private let memoryCache = NSCache<NSString, CacheEntry>()
    private let fileManager = FileManager.default

    private lazy var cacheDirectory: URL = {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDir = paths[0].appendingPathComponent("net.driveai.cache")
        try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        return cacheDir
    }()

    private final class CacheEntry: NSObject {
        let data: Data
        let timestamp: Date
        let ttl: TimeInterval?

        init(data: Data, timestamp: Date, ttl: TimeInterval?) {
            self.data = data
            self.timestamp = timestamp
            self.ttl = ttl
        }

        func isExpired() -> Bool {
            guard let ttl = ttl else { return false }
            return Date().timeIntervalSince(timestamp) > ttl
        }
    }

    // MARK: - Public API

    func set<T: Codable>(
        _ value: T,
        forKey key: String,
        ttl: TimeInterval? = nil
    ) throws {
        let encoded = try JSONEncoder().encode(value)
        let entry = CacheEntry(data: encoded, timestamp: Date(), ttl: ttl)
        memoryCache.setObject(entry, forKey: (key as NSString))

        let fileURL = cacheDirectory.appendingPathComponent(sanitizedKey(key))
        let wrapper = DiskEntry(data: encoded, timestamp: Date(), ttl: ttl)
        let diskData = try JSONEncoder().encode(wrapper)
        try diskData.write(to: fileURL)
    }

    func get<T: Codable>(_ key: String, type: T.Type) -> T? {
        if let entry = memoryCache.object(forKey: (key as NSString)),
           !entry.isExpired() {
            return try? JSONDecoder().decode(T.self, from: entry.data)
        }

        let fileURL = cacheDirectory.appendingPathComponent(sanitizedKey(key))
        guard let fileData = try? Data(contentsOf: fileURL),
              let wrapper = try? JSONDecoder().decode(DiskEntry.self, from: fileData),
              !wrapper.isExpired()
        else { return nil }

        let entry = CacheEntry(data: wrapper.data, timestamp: wrapper.timestamp, ttl: wrapper.ttl)
        memoryCache.setObject(entry, forKey: (key as NSString))

        return try? JSONDecoder().decode(T.self, from: wrapper.data)
    }

    func remove(_ key: String) {
        memoryCache.removeObject(forKey: (key as NSString))
        let fileURL = cacheDirectory.appendingPathComponent(sanitizedKey(key))
        try? fileManager.removeItem(at: fileURL)
    }

    @discardableResult
    func clearExpired() -> Int {
        guard let urls = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: nil
        ) else { return 0 }

        var removedCount = 0
        for url in urls {
            guard let data = try? Data(contentsOf: url),
                  let wrapper = try? JSONDecoder().decode(DiskEntry.self, from: data),
                  wrapper.isExpired()
            else { continue }

            try? fileManager.removeItem(at: url)
            memoryCache.removeObject(forKey: (url.lastPathComponent as NSString))
            removedCount += 1
        }
        return removedCount
    }

    private func sanitizedKey(_ key: String) -> String {
        key
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
            .replacingOccurrences(of: ":", with: "_")
    }
}

private struct DiskEntry: Codable {
    let data: Data
    let timestamp: Date
    let ttl: TimeInterval?

    func isExpired() -> Bool {
        guard let ttl = ttl else { return false }
        return Date().timeIntervalSince(timestamp) > ttl
    }
}