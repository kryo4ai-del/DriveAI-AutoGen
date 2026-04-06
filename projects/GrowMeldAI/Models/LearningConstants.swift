// Utilities/Constants.swift
enum LearningConstants {
    enum Thresholds {
        /// Confidence below this triggers review flag
        static let confidenceNeedsReviewMin: Double = 0.65
        
        /// Accuracy rate thresholds
        enum AccuracyTiers {
            static let strong: Double = 0.80
            static let weak: Double = 0.60
        }
        
        /// Practice recency thresholds
        enum RecencyDays {
            static let needsReviewTrigger: Int = 3
            static let excellentRecency: Int = 1
        }
    }
    
    enum TimeFactors {
        /// Number of days to reach 100% time multiplier weight
        static let readinessTimeFactorDays: Double = 30.0
        
        /// Ebbinghaus forgetting curve decay rate
        static let forgettingCurveDecay: Double = 5.0
    }
    
    enum DailyMinutes {
        static let minimum: Int = 15
        static let maximum: Int = 90
        static let baseRecommended: Int = 30
        static let perWeakCategoryAdditional: Int = 5
    }
    
    enum ExamUrgency {
        /// Exam days that trigger "final week" messaging
        enum Days {
            static let finalWeek: ClosedRange<Int> = 0...7
            static let twoWeeks: ClosedRange<Int> = 8...14
            static let monthPlus: ClosedRange<Int> = 15...Int.max
        }
    }
}

// Usage - much clearer!
var needsReview: Bool {
    confidenceScore < LearningConstants.Thresholds.confidenceNeedsReviewMin 
        || daysSinceLastPractice > LearningConstants.Thresholds.RecencyDays.needsReviewTrigger
}

var recommendedDailyMinutes: Int {
    let baseMinutes = LearningConstants.DailyMinutes.baseRecommended
    let weakCategories = categoriesNeedingReview.count
    let daysLeft = max(userProfile.daysUntilExam, 1)
    
    let recommended = baseMinutes + (weakCategories * LearningConstants.DailyMinutes.perWeakCategoryAdditional)
    return min(
        LearningConstants.DailyMinutes.maximum,
        max(LearningConstants.DailyMinutes.minimum, recommended / (daysLeft / 7))
    )
}

// Message generation becomes self-documenting
switch daysLeft {
case LearningConstants.ExamUrgency.Days.finalWeek:
    urgencyMessage = "🎯 Nur noch \(daysLeft) Tag\(daysLeft == 1 ? "" : "e")!"
case LearningConstants.ExamUrgency.Days.twoWeeks:
    urgencyMessage = "⚡ \(daysLeft) Tage bis zur Prüfung."
default:
    urgencyMessage = "📅 Du hast noch Zeit zum Lernen!"
}