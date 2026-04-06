import Foundation
struct ProgressMetrics {
    var totalQuestionsAttempted: Int
    var correctAnswers: Int
    var currentStreak: Int
    var longestStreak: Int
    var categoryProgress: [CategoryMetrics]
    var lastActivityDate: Date
  }
  
  struct CategoryMetrics {
    var categoryId: UUID
    var categoryName: String
    var questionsAttempted: Int
    var correctAnswers: Int
    var percentageCorrect: Double
  }