import Foundation

// MARK: - Mastery Level

enum MasteryLevel: String, Codable {
    case beginner
    case developing
    case proficient
    case expert
}

// MARK: - Trend Direction

enum TrendDirection: String, Codable {
    case improving, declining, stable
}

// MARK: - Category Diagnostic Profile

struct CategoryDiagnosticProfile: Codable {
    let categoryId: String
    let totalAttempts: Int
    let correctAnswers: Int
    let accuracyRate: Double
    let lastAttemptDate: Date?
    let performanceTrend: [Double]
    let averageTimePerQuestion: TimeInterval

    var trendDirection: TrendDirection {
        guard performanceTrend.count >= 2 else { return .stable }
        let recent = Array(performanceTrend.suffix(3))
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

// MARK: - Misconception

struct Misconception: Codable, Identifiable {
    let id: UUID
    let questionId: String
    let categoryId: String
    let misconceptionType: MisconceptionType
    let frequency: Int
    let lastOccurrence: Date
    let suggestedExplanation: String

    enum MisconceptionType: String, Codable {
        case conceptualMisunderstanding
        case carelessError
        case knowledgeGap
        case ruleConfusion
    }
}

// MARK: - Learning Style

struct LearningStyle: Codable {
    let visualLearner: Bool
    let practicalLearner: Bool
    let timeScalar: Double
    let retentionMode: RetentionMode

    enum RetentionMode: String, Codable {
        case spacedRepetition
        case massed
        case mixed
    }
}

// MARK: - User Diagnostic Profile

struct UserDiagnosticProfile: Codable {
    let userId: UUID
    let createdAt: Date
    let lastUpdatedAt: Date

    var categoryProfiles: [String: CategoryDiagnosticProfile]
    var misconceptions: [Misconception]
    var learningStyle: LearningStyle
    var examReadinessScore: Double

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
    let id: UUID
    let type: RecommendationType
    let targetCategoryId: String?
    let targetQuestionId: String?
    let reasoning: String
    let priority: Int
    let createdAt: Date
    let expiresAt: Date

    init(
        id: UUID = UUID(),
        type: RecommendationType,
        targetCategoryId: String? = nil,
        targetQuestionId: String? = nil,
        reasoning: String,
        priority: Int,
        createdAt: Date,
        expiresAt: Date
    ) {
        self.id = id
        self.type = type
        self.targetCategoryId = targetCategoryId
        self.targetQuestionId = targetQuestionId
        self.reasoning = reasoning
        self.priority = priority
        self.createdAt = createdAt
        self.expiresAt = expiresAt
    }

    enum RecommendationType: String, Codable {
        case focusWeakCategory
        case reviewMisconception
        case spaceRepetition
        case calibration
    }
}

// MARK: - Calibrated Feedback

struct CalibratedFeedback: Codable {
    let questionId: String
    let categoryId: String
    let feedbackText: String
    let confidenceScore: Double
    let generatedAt: Date
}

// MARK: - Exam Readiness Assessment

struct ExamReadinessAssessment: Codable {
    let userId: UUID
    let assessedAt: Date
    let overallScore: Double
    let categoryScores: [String: Double]
    let readinessLevel: ReadinessLevel
    let recommendedStudyHours: Double

    enum ReadinessLevel: String, Codable {
        case notReady
        case almostReady
        case ready
        case wellPrepared
    }
}