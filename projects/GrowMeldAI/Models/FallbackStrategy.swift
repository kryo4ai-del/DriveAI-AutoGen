import Foundation

/// Defines how fallback providers are selected
enum FallbackStrategy: Sendable {
    /// Use local pre-bundled data
    case local
    /// Return simplified/static responses
    case static
    /// Return previously cached responses
    case cached
    /// Combine multiple providers
    case cascading
    /// User is notified of limited functionality
    case degraded
}

/// Configuration for fallback behavior
struct FallbackConfiguration: Sendable {
    /// Maximum cache size in MB
    let maxCacheSizeMB: Int
    
    /// Health check interval in seconds
    let healthCheckInterval: TimeInterval
    
    /// Timeout for primary service calls in seconds
    let primaryServiceTimeout: TimeInterval
    
    /// Retry attempts before falling back
    let maxRetries: Int
    
    /// Whether to cache responses persistently
    let persistCache: Bool
    
    /// Preferred fallback strategy
    let strategy: FallbackStrategy
    
    static let `default` = FallbackConfiguration(
        maxCacheSizeMB: 50,
        healthCheckInterval: 60,
        primaryServiceTimeout: 5,
        maxRetries: 2,
        persistCache: true,
        strategy: .cascading
    )
    
    static let aggressive = FallbackConfiguration(
        maxCacheSizeMB: 10,
        healthCheckInterval: 30,
        primaryServiceTimeout: 3,
        maxRetries: 1,
        persistCache: false,
        strategy: .local
    )
}