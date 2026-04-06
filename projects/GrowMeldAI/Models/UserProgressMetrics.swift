// In Subscription/Models/UserProgressMetrics.swift
struct UserProgressMetrics {
    let totalQuestionsAnswered: Int
    let totalQuestions: Int
    let masteryCategoryStats: [CategoryID: Double]
    let examDate: Date
    
    var completionPercentage: Int {
        guard totalQuestions > 0 else { return 0 }
        return (totalQuestionsAnswered * 100) / totalQuestions
    }
    
    var daysUntilExam: Int {
        Calendar.current.dateComponents([.day], from: .now, to: examDate).day ?? 0
    }
}