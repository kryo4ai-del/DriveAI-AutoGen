struct ProgressTransaction {
    let questionID: UUID
    let categoryKey: String
    let isCorrect: Bool
    
    func apply(to profile: inout UserProfile) {
        profile.totalQuestionsAnswered += 1
        if isCorrect { profile.totalCorrectAnswers += 1 }
        
        var stats = profile.categoryStats[categoryKey] 
            ?? CategoryProgress(categoryName: categoryKey)
        stats.questionsAnswered += 1
        stats.questionsAnsweredToday += 1
        if isCorrect { stats.correctAnswers += 1 }
        
        profile.categoryStats[categoryKey] = stats
        profile.lastActiveDate = Date()
    }
}

// Usage
let transaction = ProgressTransaction(
    questionID: question.id,
    categoryKey: category.rawValue,
    isCorrect: isCorrect
)
var profile = userProfile
transaction.apply(to: &profile)
self.userProfile = profile