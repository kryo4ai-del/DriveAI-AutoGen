import Foundation

protocol LLMQuestionSolverServiceProtocol {
    func generateAnswerHint(for question: String, completion: @escaping (Result<String, Error>) -> Void)
    func provideExplanation(for question: String, answer: String, completion: @escaping (Result<String, Error>) -> Void)
    func suggestQuestions(for userProfile: UserProfile, completion: @escaping (Result<[Question], Error>) -> Void)
}