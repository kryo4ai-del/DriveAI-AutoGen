// Models/UI/CategoryWithProgress.swift
import Foundation

struct CategoryWithProgress {
    let category: QuizCategory
    let progress: QuizUserProgress.CategoryProgress
    
    var percentage: Double {
        progress.percentage
    }
    
    var remainingQuestions: Int {
        category.questionCount - progress.questionsAttempted
    }
}