struct UserProgress: Codable {
    var totalQuestionsAnswered: Int = 0
    var correctAnswers: Int = 0
    var currentStreak: Int = 0  // Days with >= 1 correct answer
    var maxStreak: Int = 0
    var lastCorrectDate: Date?
    
    mutating func recordAnswer(category: QuestionCategory, isCorrect: Bool) {
        totalQuestionsAnswered += 1
        if isCorrect {
            correctAnswers += 1
            updateStreakOnCorrectAnswer()
        }
    }
    
    private mutating func updateStreakOnCorrectAnswer() {
        let now = Date()
        
        if let lastDate = lastCorrectDate, Calendar.current.isDate(now, inSameDayAs: lastDate) {
            // Already counted today, don't increment again
            return
        }
        
        // New day with correct answer
        currentStreak += 1
        maxStreak = max(maxStreak, currentStreak)
        lastCorrectDate = now
    }
    
    mutating func checkStreakBreak() {
        let daysSinceLastCorrect = Calendar.current.dateComponents(
            [.day],
            from: lastCorrectDate ?? Date(),
            to: Date()
        ).day ?? 0
        
        if daysSinceLastCorrect > 1 {
            currentStreak = 0
        }
    }
}