import Foundation

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
    
    // ✅ Make CacheEntry observable for NSCache
    private class CacheEntry {
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
        
        // ✅ Store entry directly (no nested encoding)
        memoryCache.setObject(entry, forKey: key as NSString)
        
        // ✅ Disk: encode entry once
        let fileURL = cacheDirectory.appendingPathComponent(sanitizedKey(key))
        let diskData = CodableWrapper(entry).encode()
        try diskData.write(to: fileURL)
    }
    
    func get<T: Codable>(_ key: String, type: T.Type) -> T? {
        // Try memory first
        if let entry = memoryCache.object(forKey: key as NSString),
           !entry.isExpired() {
            return try? JSONDecoder().decode(T.self, from: entry.data)
        }
        
        // Try disk
        let fileURL = cacheDirectory.appendingPathComponent(sanitizedKey(key))
        guard let fileData = try? Data(contentsOf: fileURL),
              let wrapper = try? CodableWrapper.decode(fileData) as? CacheEntry,
              !wrapper.isExpired()
        else { return nil }
        
        return try? JSONDecoder().decode(T.self, from: wrapper.data)
    }
    
    func remove(_ key: String) {
        memoryCache.removeObject(forKey: key as NSString)
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
                  let wrapper = try? CodableWrapper.decode(data) as? CacheEntry,
                  wrapper.isExpired()
            else { continue }
            
            try? fileManager.removeItem(at: url)
            memoryCache.removeObject(forKey: url.lastPathComponent as NSString)
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

// Helper for non-Codable CacheEntry
private struct CodableWrapper: Codable {
    let data: Data
    let timestamp: Date
    let ttl: TimeInterval?
    
    init(_ entry: CacheService.CacheEntry) {
        self.data = entry.data
        self.timestamp = entry.timestamp
        self.ttl = entry.ttl
    }
    
    func encode() -> Data {
        try! JSONEncoder().encode(self)
    }
    
    static func decode(_ data: Data) -> CodableWrapper? {
        try? JSONDecoder().decode(CodableWrapper.self, from: data)
    }
}