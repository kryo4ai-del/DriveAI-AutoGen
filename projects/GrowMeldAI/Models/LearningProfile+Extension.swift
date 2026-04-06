extension LearningProfile {
    var totalQuizzesAttempted: Int {
        categoryProfiles.values.reduce(0) { $0 + $1.questionsAttempted }
    }
    
    var overallAccuracy: Double {
        let totalCorrect = categoryProfiles.values.reduce(0) { $0 + $1.correctAnswers }
        let total = totalQuizzesAttempted
        guard total > 0 else { return 0 }
        return Double(totalCorrect) / Double(total)
    }
}