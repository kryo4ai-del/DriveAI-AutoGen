import Foundation
import OSLog

// MARK: - CacheEntry

private struct CacheEntry: Codable {
    let response: String
    let timestamp: Date
    let sizeBytes: Int
}

// MARK: - AIResponseCache

final class AIResponseCache {

    // MARK: - Properties

    private var cache: [String: CacheEntry] = [:]
    private var totalBytes: Int = 0
    private let lock = NSLock()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GrowMeldAI", category: "AIResponseCache")

    // MARK: - Init

    init() {}

    // MARK: - Public Interface

    func response(for key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return cache[key]?.response
    }

    func store(response: String, for key: String) {
        lock.lock()
        defer { lock.unlock() }
        let sizeBytes = response.utf8.count
        let entry = CacheEntry(response: response, timestamp: Date(), sizeBytes: sizeBytes)
        cache[key] = entry
        totalBytes += sizeBytes
    }

    func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
        totalBytes = 0
    }

    // MARK: - Disk Persistence

    func saveToDiskAsync(path: URL) async throws {
        let snapshot: [String: CacheEntry] = {
            lock.lock()
            defer { lock.unlock() }
            return cache
        }()

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(snapshot)
        try data.write(to: path, options: .atomic)
        logger.info("Cache saved to disk at \(path.path)")
    }

    func loadFromDiskAsync(path: URL) async throws {
        let data = try Data(contentsOf: path)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let loaded = try decoder.decode([String: CacheEntry].self, from: data)

        lock.lock()
        defer { lock.unlock() }
        self.cache = loaded
        self.totalBytes = loaded.values.reduce(0) { $0 + $1.sizeBytes }
        logger.info("Cache loaded from disk: \(loaded.count) entries, \(self.totalBytes) bytes")
    }
}

// MARK: - AIResponseCache + Persistence Helpers

extension AIResponseCache {

    /// Schedules periodic cache persistence to the given path every `interval` seconds.
    /// The returned timer must be retained by the caller; invalidate it when done.
    @discardableResult
    func schedulePersistence(to path: URL, interval: TimeInterval = 60) -> Timer {
        let logger = self.logger
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task {
                do {
                    try await self.saveToDiskAsync(path: path)
                } catch {
                    logger.warning("Failed to persist cache: \(error.localizedDescription)")
                }
            }
        }
        return timer
    }
}