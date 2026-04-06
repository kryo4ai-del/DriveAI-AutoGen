struct ExamSession: Identifiable {
    let id: String = UUID().uuidString
    let startTime: Date
    let timeLimit: TimeInterval = 3600 // 60 minutes
    var questions: [Question] = []
    var answers: [(questionId: String, selectedIndex: Int)] = []
    var endTime: Date?
    
    var isComplete: Bool {
        answers.count == questions.count && endTime != nil
    }
    
    var timeRemaining: TimeInterval {
        let elapsed = (endTime ?? Date()).timeIntervalSince(startTime)
        return max(0, timeLimit - elapsed)
    }
    
    var isTimeExpired: Bool {
        timeRemaining <= 0
    }
    
    var score: (correct: Int, total: Int) {
        guard isComplete else { return (0, questions.count) }
        
        let correct = answers.reduce(0) { acc, answer in
            guard let question = questions.first(where: { $0.id == answer.questionId }) else {
                return acc
            }
            return answer.selectedIndex == question.correctAnswerIndex ? acc + 1 : acc
        }
        
        return (correct, questions.count)
    }
    
    var isPassed: Bool {
        guard isComplete, questions.count > 0 else { return false }
        let percentage = Double(score.correct) / Double(questions.count)
        return percentage >= 0.9 // 90% pass threshold (per German spec)
    }
    
    mutating func recordAnswer(questionId: String, selectedIndex: Int) throws {
        guard !isTimeExpired else { throw ExamError.timeExpired }
        guard !isComplete else { throw ExamError.alreadyComplete }
        
        answers.append((questionId: questionId, selectedIndex: selectedIndex))
    }
}

enum ExamError: LocalizedError {
    case timeExpired
    case alreadyComplete
    case invalidQuestion
    
    var errorDescription: String? {
        switch self {
        case .timeExpired:
            return "Die Zeit ist abgelaufen"
        case .alreadyComplete:
            return "Die Prüfung ist bereits abgeschlossen"
        case .invalidQuestion:
            return "Ungültige Frage"
        }
    }
}