// SOURCE/Services/Repository/QuestionsRepository.swift
import Foundation

protocol QuestionsRepository {
    func fetchAllQuestions() async throws -> [Question]
    func fetchQuestions(by category: QuestionCategory) async throws -> [Question]
    func fetchQuestion(by id: String) async throws -> Question?
    func saveProgress(_ progress: QuizProgress) async throws
    func loadProgress() async throws -> QuizProgress?
}
