import Foundation

enum ASOConstants {
    // Event retention
    static let maxEventQueueSize = 1000
    static let eventBatchSize = 50
    static let eventExpirationDays = 30
    
    // Performance thresholds
    static let maxEventEmissionMs: Double = 10.0
    static let eventQueueWarningThreshold = 800
    
    // Persistence
    static let eventsCacheKey = "aso.events.cache"
    static let metricsKey = "aso.user.metrics"
    static let funnelKey = "aso.conversion.funnel"
    
    // Privacy
    static let gdprDeletionGracePeriod: TimeInterval = 24 * 60 * 60 // 24 hours
    static let analyticsConsentKey = "aso.analytics.consent"
    
    // Session
    static let sessionTimeoutSeconds: TimeInterval = 30 * 60 // 30 minutes
}