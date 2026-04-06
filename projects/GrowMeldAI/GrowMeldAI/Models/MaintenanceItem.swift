struct MaintenanceItem: Identifiable {
    let categoryId: String
    let categoryName: String
    let lastPracticeDate: Date?
    let quizAccuracy: Double  // 0.0 - 1.0
    
    // Computed property: when user SHOULD review next
    var nextRecommendedDate: Date {
        guard let lastDate = lastPracticeDate else {
            // First-time category: recommend immediately
            return Date()
        }
        
        // Spaced repetition: accuracy affects interval
        let daysUntilReview: Int
        switch quizAccuracy {
        case 0.9...:  // 90%+
            daysUntilReview = 7    // Review in 1 week
        case 0.75..<0.9:  // 75-89%
            daysUntilReview = 3    // Review in 3 days
        case 0.6..<0.75:  // 60-74%
            daysUntilReview = 1    // Review tomorrow
        default:  // <60%
            daysUntilReview = 0    // Review now
        }
        
        return Calendar.current.date(
            byAdding: .day,
            value: daysUntilReview,
            to: lastDate
        ) ?? lastDate
    }
}