// Models/UI/CategoryWithProgress.swift
import Foundation

struct CategoryWithProgress {
    let category: Category
    let progress: UserProgress.CategoryProgress
    
    var percentage: Double {
        progress.percentage
    }
    
    var remainingQuestions: Int {
        category.questionCount - progress.questionsAttempted
    }
}