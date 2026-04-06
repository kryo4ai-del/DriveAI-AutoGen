import Foundation

struct ResilienceConfiguration {
    // Cache TTL policies
    struct CacheTTL {
        static let questions: TimeInterval = 86400      // 24 hours
        static let examProgress: TimeInterval = 300     // 5 minutes
        static let userProfile: TimeInterval = 3600     // 1 hour
        static let categories: TimeInterval = 43200     // 12 hours
    }
    
    // Retry policies
    struct Retry {
        static let maxAttempts: Int = 3
        static let initialDelay: TimeInterval = 1.0
        static let maxDelay: TimeInterval = 30.0
        static let backoffMultiplier: Double = 2.0
    }
    
    // Network monitoring
    struct Network {
        static let pathMonitorQueue = DispatchQueue(
            label: "com.driveai.network-monitor",
            qos: .utility
        )
    }
    
    // File I/O
    struct Storage {
        static let fileQueue = DispatchQueue(
            label: "com.driveai.cache-file",
            attributes: .concurrent,
            qos: .utility
        )
        static let cacheMaxSize: Int = 100 * 1024 * 1024  // 100MB
    }
}