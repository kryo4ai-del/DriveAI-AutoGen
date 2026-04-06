struct SpacedRepetitionCalculator {
    // Ebbinghaus curve intervals (days)
    private let reviewIntervals = [1, 3, 7, 14, 30]
    
    func calculateNextReviewDate(reviewCount: Int, accuracy: Double) -> Date {
        let index = min(reviewCount, reviewIntervals.count - 1)
        let baseDays = reviewIntervals[index]
        
        // Adjust based on accuracy (easier for weak categories)
        let adjustedDays: Int
        if accuracy < 0.5 {
            adjustedDays = max(1, baseDays / 2)  // Shorter interval for weak areas
        } else if accuracy > 0.9 {
            adjustedDays = baseDays * 2  // Longer interval for mastered
        } else {
            adjustedDays = baseDays
        }
        
        guard let nextDate = Calendar.current.date(
            byAdding: .day,
            value: adjustedDays,
            to: Date()
        ) else {
            // Fallback on calendar error (leap second edge case)
            return Date().addingTimeInterval(TimeInterval(adjustedDays * 86400))
        }
        
        return nextDate
    }
}