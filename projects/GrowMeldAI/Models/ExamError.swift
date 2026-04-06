func completeExamSession(_ session: inout ExamSession) throws {
    guard session.answers.allSatisfy({ $0.selectedIndex >= 0 }) else {
        throw ExamError.incompleteAnswers
    }
    
    session.completedAt = Date()
    
    // Validate timing
    guard session.elapsedTime <= session.duration else {
        throw ExamError.timeExceeded
    }
    
    // Calculate category breakdown
    var categoryBreakdown: [String: Int] = [:]
    for answer in session.answers {
        let categoryId = try dataService.fetchQuestion(by: answer.questionId).category.id
        categoryBreakdown[categoryId, default: 0] += answer.isCorrect ? 1 : 0
    }
    
    // Persist exam
    userDefaultsService.saveExamSession(session)
    
    // Update profile with exam result
    var profile = userDefaultsService.loadUserProfile()
    profile.completedSessions.append(session)
    profile.recordAnswer(questionId: "", correct: false, category: .trafficSigns) // Aggregate
    userDefaultsService.saveUserProfile(profile)
}

enum ExamError: LocalizedError {
    case incompleteAnswers
    case timeExceeded
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .incompleteAnswers:
            return "Nicht alle Fragen beantwortet"
        case .timeExceeded:
            return "Zeitlimit überschritten"
        case .databaseError(let msg):
            return "Fehler: \(msg)"
        }
    }
}