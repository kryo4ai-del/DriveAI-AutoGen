// Services/UserProgressService.swift
import Foundation

protocol UserProgressService {
    func fetchProgressForCategory(_ categoryID: String) async throws -> CategoryProgress
}

struct CategoryProgress {
    let correctAnswers: Int
    let totalAnswersAttempted: Int
}

// Services/LocalDataService.swift
protocol LocalDataService {
    func fetchAllCategories() async throws -> [QuestionCategory]
}

struct QuestionCategory {
    let id: String
    let name: String
}