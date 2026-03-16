// Services/ExamReadinessService.swift
import Foundation

protocol ExamReadinessServiceProtocol {
    func calculateReadiness(categoryProgress: [CategoryProgress]) -> ExamReadiness
    func getWeakAreas(readiness: ExamReadiness, allCategories: [QuestionCategory]) -> [QuestionCategory]
    func calculateOverallReadiness() async throws -> ExamReadinessScore
    func getCategoryReadiness() async throws -> [CategoryReadiness]
    func getWeakCategories(limit: Int) async throws -> [CategoryReadiness]
    func getTrendData(days: Int) async throws -> [ReadinessTrendPoint]
}

class ExamReadinessService: ExamReadinessServiceProtocol {
    
    func calculateReadiness(categoryProgress: [CategoryProgress]) -> ExamReadiness {
        guard !categoryProgress.isEmpty else {
            return ExamReadiness(
                overallScore: 0,
                categoryScores: [:],
                isReady: false,
                weakCategories: [],
                readinessLevel: .notReady,
                calculatedAt: Date()
            )
        }
        
        // Calculate score per category: (correct / attempted) * 100
        let categoryScores = categoryProgress.reduce(into: [String: Double]()) { scores, progress in
            let attempted = progress.totalQuestions
            guard attempted > 0 else { return }
            let percentage = (Double(progress.correctAnswers) / Double(attempted)) * 100
            scores[progress.categoryId] = percentage
        }
        
        // Overall score: weighted average (each category counts equally)
        let overallScore = categoryScores.values.isEmpty ? 0 : categoryScores.values.reduce(0, +) / Double(categoryScores.count)
        
        // Identify weak categories (< 70%)
        let weakCategories = categoryScores
            .filter { $0.value < 70 }
            .map { $0.key }
        
        let readinessLevel = ExamReadiness.ReadinessLevel(score: overallScore)
        let isReady = overallScore >= 70
        
        return ExamReadiness(
            overallScore: overallScore,
            categoryScores: categoryScores,
            isReady: isReady,
            weakCategories: weakCategories,
            readinessLevel: readinessLevel,
            calculatedAt: Date()
        )
    }
    
    func getWeakAreas(readiness: ExamReadiness, allCategories: [QuestionCategory]) -> [QuestionCategory] {
        allCategories.filter { readiness.weakCategories.contains($0.id) }
    }

    func calculateOverallReadiness() async throws -> ExamReadinessScore {
        ExamReadinessScore(
            overall: 0,
            percentageInt: 0,
            level: .notStarted,
            calculatedAt: Date(),
            weakCategoryCount: 0,
            categoriesAboveThreshold: 0
        )
    }

    func getCategoryReadiness() async throws -> [CategoryReadiness] {
        []
    }

    func getWeakCategories(limit: Int) async throws -> [CategoryReadiness] {
        []
    }

    func getTrendData(days: Int) async throws -> [ReadinessTrendPoint] {
        []
    }
}