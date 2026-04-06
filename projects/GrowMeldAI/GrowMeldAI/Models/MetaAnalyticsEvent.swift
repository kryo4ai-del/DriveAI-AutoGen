enum MetaAnalyticsEvent: Codable {
  case viewedQuestion(categoryID: String, questionID: String)
  case answeredQuestion(categoryID: String, isCorrect: Bool, timeSeconds: Int)
  case completedQuiz(categoryID: String, score: Int, totalQuestions: Int)
  case startedExamSimulation
  case completedExam(passed: Bool, score: Int, totalQuestions: Int)
  case viewedCategory(categoryID: String)
  case viewedProfile
  case appOpened
  
  // Convert to Meta SDK event format
  func toFBEvent() -> FBSDKCoreKit.AppEvent {
    switch self {
    case .completedExam(let passed, let score, let total):
      return FBSDKCoreKit.AppEvent(
        name: "CompleteExam",
        parameters: [
          "passed": passed,
          "score": score,
          "total": total
        ]
      )
    case .answeredQuestion(let category, let isCorrect, let time):
      return FBSDKCoreKit.AppEvent(
        name: "AnswerQuestion",
        parameters: [
          "category": category,
          "correct": isCorrect,
          "time_seconds": time
        ]
      )
    // ... other cases
    }
  }
}