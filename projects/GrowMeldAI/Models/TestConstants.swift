enum TestConstants {
    static let shortDelay: UInt64 = 10_000_000      // 10ms
    static let mediumDelay: UInt64 = 100_000_000    // 100ms
    static let longDelay: UInt64 = 1_000_000_000    // 1s
    static let permissionTimeout: UInt64 = 10_000_000_000  // 10s
}

// Usage:
try await Task.sleep(nanoseconds: TestConstants.shortDelay)