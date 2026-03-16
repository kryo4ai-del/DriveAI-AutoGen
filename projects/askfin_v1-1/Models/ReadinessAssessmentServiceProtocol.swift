import Foundation

@MainActor
protocol ReadinessAssessmentServiceProtocol: AnyObject {
    func selectQuestionsForAssessment(count: Int) async throws -> [Question]
    func processAssessment(
        questions: [Question],
        answers: [UUID: String]
    ) async throws -> ReadinessAssessment
    func generateRecommendations(
        from assessment: ReadinessAssessment
    ) async throws -> (weakAreas: [WeakArea], recommendations: [Recommendation])
}

@MainActor
final class ReadinessAssessmentService: ReadinessAssessmentServiceProtocol {
    private let dataService: LocalDataServiceProtocol
    private let lock = NSLock()
    
    init(dataService: LocalDataServiceProtocol) {
        self.dataService = dataService
    }
    
    // MARK: - Question Selection (Balanced Distribution)
    
    func selectQuestionsForAssessment(count: Int = 10) async throws -> [Question] {
        let allQuestions = try await dataService.fetchAllQuestions()
        
        guard !allQuestions.isEmpty else {
            throw AssessmentError.noQuestionsAvailable
        }
        
        // Balanced distribution: 30% easy, 40% medium, 30% hard
        let easyCount = Int(Double(count) * 0.3)
        let mediumCount = Int(Double(count) * 0.4)
        let hardCount = count - easyCount - mediumCount
        
        let easyQuestions = allQuestions
            .filter { $0.difficulty == .easy }
            .shuffled()
            .prefix(easyCount)
        
        let mediumQuestions = allQuestions
            .filter { $0.difficulty == .medium }
            .shuffled()
            .prefix(mediumCount)
        
        let hardQuestions = allQuestions
            .filter { $0.difficulty == .hard }
            .shuffled()
            .prefix(hardCount)
        
        return (easyQuestions + mediumQuestions + hardQuestions).shuffled()
    }
    
    // MARK: - Assessment Processing (Thread-Safe)
    
    func processAssessment(
        questions: [Question],
        answers: [UUID: String]
    ) async throws -> ReadinessAssessment {
        guard !questions.isEmpty else {
            throw AssessmentError.invalidQuestions
        }
        
        var correctCount = 0
        var categoryData: [String: CategoryData] = [:]
        
        // Initialize categories
        for question in questions {
            lock.lock()
            if categoryData[question.categoryId] == nil {
                categoryData[question.categoryId] = CategoryData(
                    categoryName: question.categoryName
                )
            }
            lock.unlock()
        }
        
        // Process answers sequentially (safer than parallel for mutations)
        for question in questions {
            let userAnswer = answers[question.id] ?? ""
            let isCorrect = userAnswer == question.correctAnswer
            
            if isCorrect {
                correctCount += 1
            }
            
            lock.lock()
            categoryData[question.categoryId]?.recordAnswer(
                isCorrect: isCorrect,
                difficulty: question.difficulty
            )
            lock.unlock()
        }
        
        // Build category results
        let results = categoryData
            .map { categoryId, data in
                CategoryResult(
                    id: UUID(),
                    categoryId: categoryId,
                    categoryName: data.categoryName,
                    questionsAsked: data.totalAsked,
                    correctAnswers: data.totalCorrect,
                    difficulty: DifficultyBreakdown(
                        easy: data.easyStats,
                        medium: data.mediumStats,
                        hard: data.hardStats
                    )
                )
            }
            .sorted { $0.accuracy < $1.accuracy }
        
        return ReadinessAssessment(
            totalQuestions: questions.count,
            correctAnswers: correctCount,
            categoryResults: results
        )
    }
    
    // MARK: - Recommendations Generation
    
    func generateRecommendations(
        from assessment: ReadinessAssessment
    ) async throws -> (weakAreas: [WeakArea], recommendations: [Recommendation]) {
        let weakAreas = assessment.categoryResults
            .filter { $0.needsImprovement }
            .enumerated()
            .map { index, result in
                WeakArea(
                    id: UUID(),
                    categoryId: result.categoryId,
                    categoryName: result.categoryName,
                    score: result.accuracy,
                    questionsAnswered: result.questionsAsked,
                    correctAnswers: result.correctAnswers,
                    priority: index == 0 ? .critical : (index < 3 ? .high : .medium)
                )
            }

        let recommendations = weakAreas.enumerated().map { index, area in
            Recommendation(
                id: UUID(),
                title: "Improve \(area.categoryName)",
                description: "Your score is \(String(format: "%.0f", area.score))%. Practice more to reach 70%.",
                categoryId: area.categoryId,
                categoryName: area.categoryName,
                estimatedMinutes: max(10, Int((70 - area.score) / 10) * 10),
                actionType: .practiceCategory,
                priority: index + 1
            )
        }

        return (weakAreas, recommendations)
    }
    
    // MARK: - Private Helpers
    
    private func calculateSuggestedQuestions(accuracy: Double) -> Int {
        let gap = 100 - accuracy
        return min(25, max(10, Int(gap / 5) * 5))
    }
}

// MARK: - Category Data Tracker (Thread-Safe)

private struct CategoryData {
    let categoryName: String
    var easyStats = DifficultyBreakdown.QuestionStats(asked: 0, correct: 0)
    var mediumStats = DifficultyBreakdown.QuestionStats(asked: 0, correct: 0)
    var hardStats = DifficultyBreakdown.QuestionStats(asked: 0, correct: 0)
    
    var totalAsked: Int {
        easyStats.asked + mediumStats.asked + hardStats.asked
    }
    
    var totalCorrect: Int {
        easyStats.correct + mediumStats.correct + hardStats.correct
    }
    
    mutating func recordAnswer(isCorrect: Bool, difficulty: Question.Difficulty) {
        switch difficulty {
        case .easy:
            easyStats = DifficultyBreakdown.QuestionStats(
                asked: easyStats.asked + 1,
                correct: easyStats.correct + (isCorrect ? 1 : 0)
            )
        case .medium:
            mediumStats = DifficultyBreakdown.QuestionStats(
                asked: mediumStats.asked + 1,
                correct: mediumStats.correct + (isCorrect ? 1 : 0)
            )
        case .hard:
            hardStats = DifficultyBreakdown.QuestionStats(
                asked: hardStats.asked + 1,
                correct: hardStats.correct + (isCorrect ? 1 : 0)
            )
        }
    }
}

// MARK: - Error Handling
