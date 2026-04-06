import Foundation

/// Protocol for injecting Date() — enables testing
protocol DateProviding {
    func now() -> Date
}

/// Production implementation
struct SystemDateProvider: DateProviding {
    func now() -> Date {
        Date()
    }
}

/// Test helper
struct MockDateProvider: DateProviding {
    let mockDate: Date
    
    func now() -> Date {
        mockDate
    }
}

// Global accessor for convenience
struct DateProvider {
    static var current: DateProviding = SystemDateProvider()
}