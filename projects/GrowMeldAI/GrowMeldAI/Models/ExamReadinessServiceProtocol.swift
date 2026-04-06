import Foundation
import Combine

protocol ExamReadinessServiceProtocol {
    func calculateReadiness() -> ExamReadinessScore
    func updateScores(for categories: [String], correct: Int, total: Int)
}

final class ExamReadinessService: ExamReadinessServiceProtocol {
    private var categoryScores: [String: Double] = [:]
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let categoryScores = "examReadinessCategoryScores"
    }

    init() {
        loadScores()
    }

    func calculateReadiness() -> ExamReadinessScore {
        let totalScore = categoryScores.values.reduce(0, +) / Double(categoryScores.count)
        let breakdown = categoryScores.map { ExamReadinessScore.CategoryScore(category: $0.key, score: $0.value) }
        return ExamReadinessScore(score: totalScore, categoryBreakdown: breakdown)
    }

    func updateScores(for categories: [String], correct: Int, total: Int) {
        guard total > 0 else { return }

        let newScore = Double(correct) / Double(total)
        categories.forEach { category in
            categoryScores[category] = newScore
        }

        saveScores()
    }

    private func saveScores() {
        if let encoded = try? JSONEncoder().encode(categoryScores) {
            defaults.set(encoded, forKey: Keys.categoryScores)
        }
    }

    private func loadScores() {
        if let data = defaults.data(forKey: Keys.categoryScores),
           let decoded = try? JSONDecoder().decode([String: Double].self, from: data) {
            categoryScores = decoded
        }
    }
}