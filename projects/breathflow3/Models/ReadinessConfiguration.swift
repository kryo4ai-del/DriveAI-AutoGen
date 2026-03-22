// Domain/Configuration/ReadinessConfiguration.swift
import Foundation

struct ReadinessConfiguration: Sendable {
    let masteryThreshold: Double
    let almostReadyThreshold: Double
    let targetSessions: Int
    let minimumSessionsForReady: Int
    let minimumSessionsForAlmostReady: Int
    
    static let `default` = ReadinessConfiguration(
        masteryThreshold: 85.0,
        almostReadyThreshold: 70.0,
        targetSessions: 5,
        minimumSessionsForReady: 3,
        minimumSessionsForAlmostReady: 2
    )
    
    // Test variant for aggressive readiness
    static let aggressive = ReadinessConfiguration(
        masteryThreshold: 80.0,
        almostReadyThreshold: 60.0,
        targetSessions: 3,
        minimumSessionsForReady: 2,
        minimumSessionsForAlmostReady: 1
    )
}