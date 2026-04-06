import Foundation

struct OutageContext {
    let estimatedDuration: TimeInterval?
    let timestamp: Date
    let affectedFeatures: [String]

    init(estimatedDuration: TimeInterval?, affectedFeatures: [String] = ["exam", "sync"]) {
        self.estimatedDuration = estimatedDuration
        self.timestamp = Date()
        self.affectedFeatures = affectedFeatures
    }
}