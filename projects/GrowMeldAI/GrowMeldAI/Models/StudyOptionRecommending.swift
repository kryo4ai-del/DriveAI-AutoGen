// Services/StudyOptionRecommender.swift
import Foundation

protocol StudyOptionRecommending {
    func recommendPrimaryOption(
        overallScore: Int,
        daysUntilExam: Int,
        weakestCategories: [CategoryProgress]
    ) -> StudyOption?
}

final class StudyOptionRecommender: StudyOptionRecommending {
    func recommendPrimaryOption(
        overallScore: Int,
        daysUntilExam: Int,
        weakestCategories: [CategoryProgress]
    ) -> StudyOption? {
        guard let weakest = weakestCategories.first else {
            return .examSimulation
        }
        
        // Score-based recommendation
        if overallScore < 60 {
            return .strengthenWeakCategory(
                categoryName: weakest.categoryName,
                currentScore: weakest.score
            )
        }
        
        // Time-constrained recommendation
        if daysUntilExam < 14 {
            return .quickDrill(questionCount: 5, estimatedMinutes: 2)
        }
        
        // Default: focused review
        return .focusedReview(
            category: weakest.categoryName,
            lastReviewedDate: weakest.lastReviewedDate ?? Date()
        )
    }
}