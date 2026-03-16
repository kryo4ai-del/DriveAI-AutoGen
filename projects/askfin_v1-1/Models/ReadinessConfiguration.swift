import Foundation

struct ScoringWeights {
    let categoryPerformance: Double
    let streak: Double
    let timeInvested: Double
    let recentTrend: Double
}

// Configuration/ReadinessConfiguration.swift
struct ReadinessConfiguration {
    static let passThreshold: Int = 75
    static let excellentThreshold: Int = 90
    static let goodThreshold: Int = 75
    static let moderateThreshold: Int = 60
    static let poorThreshold: Int = 40
    
    static let scoringWeights = ScoringWeights(
        categoryPerformance: 0.40,
        streak: 0.25,
        timeInvested: 0.20,
        recentTrend: 0.15
    )
    
    static let cacheTimeToLive: TimeInterval = 300
    static let maxRecommendations: Int = 5
    static let questionsPerMinute: Double = 0.5
}

// Usage
// [FK-019 sanitized] let gap = ReadinessConfiguration.passThreshold - metric.correctPercentage