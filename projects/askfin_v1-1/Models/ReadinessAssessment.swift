import Foundation

// MARK: - Core Assessment

struct ReadinessAssessment: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    let totalQuestions: Int
    let correctAnswers: Int
    let categoryResults: [CategoryResult]
    let overallScore: Double
    let readinessLevel: ReadinessLevel
    
    var passPercentage: Double {
        totalQuestions > 0 ? (Double(correctAnswers) / Double(totalQuestions)) * 100 : 0
    }
    
    init(
        totalQuestions: Int,
        correctAnswers: Int,
        categoryResults: [CategoryResult]
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.categoryResults = categoryResults.sorted { $0.accuracy < $1.accuracy }
        self.overallScore = Self.calculateScore(correctAnswers, totalQuestions)
        self.readinessLevel = ReadinessLevel(score: self.overallScore)
    }
    
    static func calculateScore(_ correct: Int, _ total: Int) -> Double {
        guard total > 0 else { return 0 }
        return (Double(correct) / Double(total)) * 100
    }
}

// MARK: - Category Result

struct CategoryResult: Identifiable, Codable {
    let id: UUID
    let categoryId: String
    let categoryName: String
    let questionsAsked: Int
    let correctAnswers: Int
    let difficulty: DifficultyBreakdown
    
    var accuracy: Double {
        guard questionsAsked > 0 else { return 0 }
        return (Double(correctAnswers) / Double(questionsAsked)) * 100
    }
    
    var needsImprovement: Bool {
        accuracy < 70
    }
}

struct DifficultyBreakdown: Codable {
    let easy: QuestionStats
    let medium: QuestionStats
    let hard: QuestionStats
    
    struct QuestionStats: Codable {
        let asked: Int
        let correct: Int
        
        var accuracy: Double {
            guard asked > 0 else { return 0 }
            return (Double(correct) / Double(asked)) * 100
        }
    }
}

// MARK: - Readiness Level
