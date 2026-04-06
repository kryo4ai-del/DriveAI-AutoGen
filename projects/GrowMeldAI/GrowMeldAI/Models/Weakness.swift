// Models/Weakness.swift
import Foundation

struct Weakness: Identifiable {
    let id: String
    let categoryName: String
    let failedQuestionCount: Int
    let totalAttempts: Int
    let lastFailedDate: Date
    let createdDate: Date
    let nextReviewDate: Date  // ← Persisted value, not computed
    
    // Pure computed properties only
    var failureRate: Double {
        totalAttempts > 0 ? Double(failedQuestionCount) / Double(totalAttempts) : 0
    }
    
    var recommendedFocusLevel: FocusLevel {
        switch (failedQuestionCount, failureRate) {
        case (0, _):
            return .green
        case (1...2, let rate) where rate < 0.3:
            return .yellow
        case (3...5, _):
            return .orange
        default:
            return .red
        }
    }
    
    var isOverdue: Bool {
        nextReviewDate <= Date()
    }
    
    var daysUntilReview: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: nextReviewDate).day ?? 0
    }
}