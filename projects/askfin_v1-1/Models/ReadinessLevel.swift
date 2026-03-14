// MARK: - Single Source of Truth for ExamReadiness Domain Models
// This file consolidates all duplicate type definitions (FK-012 fix)

import SwiftUI

// MARK: - ReadinessLevel Enum

/// Exam readiness level derived from percentage score.
/// Thresholds: notReady (0-29%), partiallyReady (30-59%), ready (60-89%), excellent (90-100%)
enum ReadinessLevel: String, Codable, CaseIterable, Equatable {
    case notReady = "notReady"
    case partiallyReady = "partiallyReady"
    case ready = "ready"
    case excellent = "excellent"
    
    /// Initialize from percentage (0-100)
    init(percentage: Int) {
        switch percentage {
        case 0..<30: self = .notReady
        case 30..<60: self = .partiallyReady
        case 60..<90: self = .ready
        default: self = .excellent
        }
    }
    
    var displayName: String {
        switch self {
        case .notReady: return "Not Ready"
        case .partiallyReady: return "Partially Ready"
        case .ready: return "Ready"
        case .excellent: return "Excellent"
        }
    }
    
    var color: Color {
        switch self {
        case .notReady: return .red
        case .partiallyReady: return .orange
        case .ready: return .green
        case .excellent: return .blue
        }
    }
    
    /// Hint text for user guidance (UX Psychology: elaborative interrogation)
    var hint: String {
        switch self {
        case .notReady:
            return "Focus on weak categories before attempting the exam."
        case .partiallyReady:
            return "Drill weak areas to improve readiness."
        case .ready:
            return "You're well-prepared. Final practice tests recommended."
        case .excellent:
            return "Excellent mastery! You're ready for the exam."
        }
    }
}

// MARK: - StrengthRating Enum

/// Category-level strength rating based on accuracy percentage.
/// Thresholds: weak (<50%), moderate (50-79%), strong (80-94%), excellent (95%+)
enum StrengthRating: String, Codable, CaseIterable, Equatable {
    case weak = "weak"           // <50%
    case moderate = "moderate"   // 50-79%
    case strong = "strong"       // 80-94%
    case excellent = "excellent" // 95%+
    
    /// Initialize from Double percentage (0.0-1.0)
    init(percentage: Double) {
        switch percentage {
        case 0..<0.5: self = .weak
        case 0.5..<0.8: self = .moderate
        case 0.8..<0.95: self = .strong
        default: self = .excellent
        }
    }
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .moderate: return .orange
        case .strong: return .green
        case .excellent: return .blue
        }
    }
}

// MARK: - CategoryReadiness Model

/// Single authoritative model for category-level readiness assessment.
/// **FK-012 Fix:** Unified from two conflicting definitions with consistent naming.
struct CategoryReadiness: Identifiable, Codable, Equatable {
    /// Unique category identifier (replaces `categoryId`)
    let id: String
    
    /// Human-readable category name (replaces `categoryName`)
    let name: String
    
    /// Total questions in this category
    let totalQuestions: Int
    
    /// Number of correct answers (replaces `answeredCorrectly`)
    let correctAnswers: Int
    
    /// Average score as percentage (0.0-1.0)
    let averageScore: Double
    
    /// Last date user studied this category
    let lastStudied: Date?
    
    /// Strength rating derived from accuracy (replaces `strengthRating`)
    let strength: StrengthRating
    
    /// Recommended focus level (1-5, where 5 is most urgent)
    let recommendedFocusLevel: Int
    
    /// Computed percentage (0-100) for UI display
    var percentage: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(correctAnswers) / Double(totalQuestions)) * 100)
    }
    
    /// Flag for weak categories (strength == .weak)
    var isWeakCategory: Bool {
        strength == .weak
    }
}

// MARK: - ExamReadinessScore Model

/// Single authoritative model for overall exam readiness assessment.
/// **FK-012 Fix:** Unified from two conflicting definitions with consistent naming.
struct ExamReadinessScore: Codable, Equatable {
    /// Overall weighted score (0.0-1.0)
    let overall: Double
    
    /// Overall score as percentage (0-100) (replaces `readinessPercentage`)
    let percentageInt: Int
    
    /// Derived readiness level
    let level: ReadinessLevel
    
    /// When this score was calculated
    let calculatedAt: Date
    
    /// Number of categories below 50% threshold
    let weakCategoryCount: Int
    
    /// Number of categories at or above 70% threshold
    let categoriesAboveThreshold: Int
    
    /// Flag indicating readiness to take exam (ready or excellent)
    var isReady: Bool {
        level == .ready || level == .excellent
    }
}

// MARK: - ReadinessTrendPoint Model

/// Historical snapshot of readiness score over time.
struct ReadinessTrendPoint: Identifiable, Codable, Equatable {
    /// Unique identifier
    let id: UUID
    
    /// Date of snapshot
    let date: Date
    
    /// Score at this date (0-100)
    let score: Int
    
    /// Readiness level at this date
    let level: ReadinessLevel
    
    /// Initialize with automatic UUID generation
    init(date: Date, score: Int, level: ReadinessLevel) {
        self.id = UUID()
        self.date = date
        self.score = score
        self.level = level
    }
}

// MARK: - Service Protocol (Single Contract)

/// Service protocol for exam readiness calculations and persistence.
/// **Note:** Implementation is `actor` for thread-safe concurrent access.
protocol ExamReadinessServiceProtocol: Sendable {
    func calculateOverallReadiness() async throws -> ExamReadinessScore
    func getCategoryReadiness() async throws -> [CategoryReadiness]
    func getWeakCategories(limit: Int) async throws -> [CategoryReadiness]
    func recordDailySnapshot() async throws
    func getTrendData(days: Int) async throws -> [ReadinessTrendPoint]
}