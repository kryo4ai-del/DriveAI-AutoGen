// Models/AIModelStatus.swift
import Foundation

enum AIModelStatus {
    case available
    case degraded(reason: String)
    case unavailable
}

enum AIFallbackTier: Int, Comparable {
    case cached = 1
    case heuristic = 2
    case staticContent = 3

    static func < (lhs: AIFallbackTier, rhs: AIFallbackTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct FallbackExplanation {
    let questionId: Int
    let tier: AIFallbackTier  // cached, heuristic, static
    let content: String
    let isAuthoritative: Bool
    let generatedAt: Date
}

typealias FallbackTier = AIFallbackTier