// Services/Quiz/QuizService.swift
import Foundation

@MainActor
class QuizService {
    private let dataService: LocalDataService
    private var allQuestions: [Question] = []
    private var isInitialized = false
    
    init(dataService: LocalDataService = LocalDataService()) {
        self.dataService = dataService
    }
    
    func initialize() async throws {
        guard !isInitialized else { return }
        allQuestions = try await dataService.loadQuestionsFromBundle()
        isInitialized = true
    }
    
    // MARK: - Quiz Creation
    func createQuizSession(
        for category: QuestionCategory?,
        questionCount: Int = 10
    ) -> QuizSession {
        let filtered = category.map { cat in
            allQuestions.filter { $0.category == cat }
        } ?? allQuestions
        
        let shuffled = filtered.shuffled()
        let questions = Array(shuffled.prefix(questionCount))
        
        var session = QuizSession()
        session.category = category
        session.questions = questions
        session.selectedAnswers = Array(repeating: nil, count: questions.count)
        
        return session
    }
    
    func createExamSession() -> QuizSession {
        let shuffled = allQuestions.shuffled()
        let questions = Array(shuffled.prefix(30))
        
        var session = QuizSession()
        session.questions = questions
        session.selectedAnswers = Array(repeating: nil, count: 30)
        
        return session
    }
    
    // MARK: - Question Helpers
    func getQuestion(by id: String) -> Question? {
        allQuestions.first { $0.id == id }
    }
    
    func getQuestionsByCategory(_ category: QuestionCategory) -> [Question] {
        allQuestions.filter { $0.category == category }
    }
    
    func getCategoryStats(_ category: QuestionCategory) -> CategoryStats {
        let questions = getQuestionsByCategory(category)
        return CategoryStats(
            categoryName: category.displayName,
            totalQuestions: questions.count,
            easyCount: questions.filter { $0.difficulty == .easy }.count,
            mediumCount: questions.filter { $0.difficulty == .medium }.count,
            hardCount: questions.filter { $0.difficulty == .hard }.count
        )
    }
}
