import Foundation

struct CachedLocationSelection: Codable {
    let location: Location
    let selectedAt: Date

    var isStale: Bool {
        Date().timeIntervalSince(selectedAt) > 30 * 24 * 3600
    }
}