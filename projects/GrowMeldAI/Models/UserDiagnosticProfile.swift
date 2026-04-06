// Models/DES/UserDiagnosticProfile.swift
import Foundation

struct UserDiagnosticProfile: Codable {
    let userId: UUID
    let createdAt: Date
    let lastUpdatedAt: Date
    
    var categoryProfiles: [String: CategoryDiagnosticProfile]  // categoryId → profile
    var misconceptions: [Misconception]
    var learningStyle: LearningStyle
    var examReadinessScore: Double  // 0.0-1.0
    
    // Computed properties
    var weakestCategories: [String] {
        categoryProfiles
            .sorted { $0.value.accuracyRate < $1.value.accuracyRate }
            .prefix(3)
            .map { $0.key }
    }
    
    var averageAccuracy: Double {
        guard !categoryProfiles.isEmpty else { return 0.0 }
        let total = categoryProfiles.values.reduce(0) { $0 + $1.accuracyRate }
        return total / Double(categoryProfiles.count)
    }
}

// MARK: - Category-Level Diagnostics

struct CategoryDiagnosticProfile: Codable {
    let categoryId: String
    let totalAttempts: Int
    let correctAnswers: Int
    let accuracyRate: Double  // 0.0-1.0
    let lastAttemptDate: Date?
    let performanceTrend: [Double]  // 7-day rolling avg (newest last)
    let averageTimePerQuestion: TimeInterval
    
    var trendDirection: TrendDirection {
        guard performanceTrend.count >= 2 else { return .stable }
        let recent = Array(performanceTrend.suffix(3))
        let average = recent.reduce(0, +) / Double(recent.count)
        let trend = recent.last! - recent.first!
        
        if trend > 0.05 { return .improving }
        if trend < -0.05 { return .declining }
        return .stable
    }
    
    var mastery: MasteryLevel {
        switch accuracyRate {
        case 0.90...: return .expert
        case 0.75..<0.90: return .proficient
        case 0.60..<0.75: return .developing
        default: return .beginner
        }
    }
}

enum TrendDirection: String, Codable {
    case improving, declining, stable
}

// MARK: - Misconception Registry

struct Misconception: Codable, Identifiable {
    let id: UUID
    let questionId: String
    let categoryId: String
    let misconceptionType: MisconceptionType
    let frequency: Int  // How many times detected
    let lastOccurrence: Date
    let suggestedExplanation: String
    
    enum MisconceptionType: String, Codable {
        case conceptualMisunderstanding  // Wrong rule interpretation
        case carelessError               // Right knowledge, wrong execution
        case knowledgeGap                // Unfamiliar concept
        case ruleConfusion               // Mixed up similar rules
    }
}

// MARK: - Learning Style

struct LearningStyle: Codable {
    let visualLearner: Bool        // Prefers images/diagrams
    let practicalLearner: Bool     // Learns by doing/repetition
    let timeScalar: Double         // 0.5 (fast) to 2.0 (slow)
    let retentionMode: RetentionMode
    
    enum RetentionMode: String, Codable {
        case spacedRepetition  // Needs review intervals
        case massed            // Prefers concentrated practice
        case mixed             // Flexible approach
    }
}

// MARK: - Performance Metrics

struct PerformanceMetrics: Codable {
    let categoryId: String
    let date: Date
    let totalAttempts: Int
    let correctAnswers: Int
    let averageTimePerQuestion: TimeInterval
    let sessionDuration: TimeInterval
    
    var accuracy: Double {
        guard totalAttempts > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalAttempts)
    }
}

// MARK: - Recommendation

struct Recommendation: Codable, Identifiable {
    let id: UUID = UUID()
    let type: RecommendationType
    let targetCategoryId: String?
    let targetQuestionId: String?
    let reasoning: String
    let priority: Int  // 1 (high) to 5 (low)
    let createdAt: Date
    let expiresAt: Date
    
    enum RecommendationType: String, Codable {
        case focusWeakCategory
        case reviewMisconception
        case spaceRepetition
        case categoryMastery
        case examPrepFinal
    }
}

// MARK: - Feedback Models

struct CalibratedFeedback: Codable {
    let isCorrect: Bool
    let explanation: String
    let emotionalTone: EmotionalTone
    let nextAction: String
    let streakMessage: String?
    let confidence: Double  // Model confidence in feedback relevance
    
    enum EmotionalTone: String, Codable {
        case celebratory    // High accuracy + momentum
        case encouraging    // Moderate success, keep going
        case supportive     // Struggling, but progress visible
        case challenging    // Needs push / overconfident
    }
}

// MARK: - Exam Readiness Assessment

struct ExamReadinessAssessment: Codable {
    let overallScore: Double  // 0.0-1.0
    let categoryReadiness: [String: Double]  // categoryId → readiness
    let estimatedDaysToReadiness: Int
    let estimatedPassProbability: Double  // 0.0-1.0
    let weakAreas: [String]  // Categories needing focus
    let recommendedDailyQuestions: Int
    let assessedAt: Date
}