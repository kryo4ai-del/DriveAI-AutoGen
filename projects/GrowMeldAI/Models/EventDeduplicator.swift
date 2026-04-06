import Foundation

struct EventDeduplicator: Sendable {
    private actor DeduplicationStore {
        private var seenHashes: [String: Date] = [:]
        private let ttlSeconds: Double = 5.0

        func isDuplicate(_ hash: String) -> Bool {
            let now = Date()
            seenHashes = seenHashes.filter {
                now.timeIntervalSince($0.value) < ttlSeconds
            }

            guard seenHashes[hash] == nil else {
                return true
            }

            seenHashes[hash] = now
            return false
        }
    }

    private let store = DeduplicationStore()

    func isDuplicate(_ hash: String) async -> Bool {
        await store.isDuplicate(hash)
    }
}