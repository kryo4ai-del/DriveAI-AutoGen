// Services/QuestionDataService.swift
protocol QuestionDataService {
    func fetchQuestions(categoryID: String) async throws -> [Question]
    func fetchQuestion(id: String) async throws -> Question
    func fetchCategories() async throws -> [QuestionCategory]
    func searchQuestions(text: String) async throws -> [Question]
}

// Services/UserProgressService.swift

// Services/ExamSessionService.swift
protocol ExamSessionService {
    func createSession() async throws -> ExamSession
    func saveAnswer(_ answer: QuestionAnswer, to session: ExamSession) async throws
    func completeSession(_ session: ExamSession) async throws -> ExamResult
}