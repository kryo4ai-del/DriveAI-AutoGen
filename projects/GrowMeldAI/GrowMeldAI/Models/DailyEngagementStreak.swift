struct DailyEngagementStreak {
    let currentStreak: Int
    let longestStreak: Int
    let lastActiveDate: Date
    
    var isBroken: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: dateProvider.now())
        let lastActive = calendar.startOfDay(for: lastActiveDate)
        let daysSinceActive = calendar.dateComponents([.day], from: lastActive, to: today).day ?? 999
        return daysSinceActive > 1
    }
}

struct CategoryMastery {
    let categoryId: String
    let categoryName: String  // "Traffic signs", "Right-of-way"
    let questionsAnswered: Int
    let correctCount: Int
    let accuracy: Int
    let nextMilestone: Int?  // 90% accuracy = mastery badge
    
    var isMastered: Bool { accuracy >= 85 }
}
