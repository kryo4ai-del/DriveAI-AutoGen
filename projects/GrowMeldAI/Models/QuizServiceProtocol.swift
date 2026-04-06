// Core/Services/QuizService.swift
protocol QuizServiceProtocol {
    func createQuiz(category: Category, mode: QuizMode) async throws -> Quiz
    func loadExamSession(_ sessionId: String) async throws -> ExamSession
}

@MainActor
class QuizService: QuizServiceProtocol {
    private let dataService: LocalDataServiceProtocol
    
    func createQuiz(category: Category, mode: QuizMode) async throws -> Quiz {
        let questions = try await dataService.loadQuestions(category: category)
        let shuffled = questions.shuffled().prefix(mode.questionCount)
        
        return Quiz(
            id: UUID().uuidString,
            questions: Array(shuffled),
            mode: mode,
            createdAt: Date()
        )
    }
}

// Core/Services/UserDataService.swift
protocol UserDataServiceProtocol {
    func loadUser() async throws -> User
    func saveUser(_ user: User) async throws
    func recordAnswer(questionId: String, category: Category, correct: Bool) async throws
}

@MainActor
class UserDataService: UserDataServiceProtocol {
    private let defaults = UserDefaults.standard
    private let key = "com.driveai.user"
    
    func loadUser() async throws -> User {
        guard let data = defaults.data(forKey: key) else {
            return User.default // new user
        }
        return try JSONDecoder().decode(User.self, from: data)
    }
    
    func saveUser(_ user: User) async throws {
        let data = try JSONEncoder().encode(user)
        defaults.set(data, forKey: key)
    }
    
    func recordAnswer(questionId: String, category: Category, correct: Bool) async throws {
        var user = try await loadUser()
        user.recordAnswer(questionId: questionId, category: category, correct: correct)
        try await saveUser(user)
    }
}