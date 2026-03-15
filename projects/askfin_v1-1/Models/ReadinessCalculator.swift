import Foundation

@MainActor
class ReadinessCalculator: ObservableObject {
    private let dataService: LocalDataService
    private let examDateManager: ExamDateManager
    
    init(dataService: LocalDataService, examDateManager: ExamDateManager) {
        self.dataService = dataService
        self.examDateManager = examDateManager
    }
    
    func calculateReadiness() async -> ReadinessCalculationResult {
        do {
            let categoryScores = try await calculateCategoryScores()
            let weakAreas = identifyWeakAreas(from: categoryScores)
            let overallScore = computeWeightedScore(categoryScores)
            let daysToExam = examDateManager.daysUntilExam()
            let urgencyLevel = determineUrgency(daysToExam: daysToExam)
            
            let readinessScore = ReadinessScore(
                id: UUID(),
                overallScore: overallScore,
                categoryScores: categoryScores,
                calculatedAt: Date(),
                daysToExam: daysToExam,
                urgencyLevel: urgencyLevel
            )
            
            let recommendations = generateRecommendations(
                weakAreas: weakAreas,
                daysToExam: daysToExam
            )
            
            let strengths = identifyStrengths(from: categoryScores)
            
            return ReadinessCalculationResult(
                score: readinessScore,
                weakAreas: weakAreas,
                strengths: strengths,
                recommendations: recommendations
            )
        } catch {
            return fallbackResult()
        }
    }
    
    private func calculateCategoryScores() async throws -> [String: Double] {
        let allQuestions = try await dataService.fetchAllQuestions()
        let userAnswers = try await dataService.fetchUserAnswerHistory()
        
        var categoryScores: [String: Double] = [:]
        let categories = Set(allQuestions.map { $0.category })
        
        for category in categories {
            let categoryQuestions = allQuestions.filter { $0.category == category }
            let categoryAnswers = userAnswers.filter { answer in
                categoryQuestions.contains { $0.id == answer.questionId }
            }
            
            guard !categoryAnswers.isEmpty else {
                categoryScores[category] = 0
                continue
            }
            
            let correct = categoryAnswers.filter { $0.isCorrect }.count
            categoryScores[category] = (Double(correct) / Double(categoryAnswers.count)) * 100
        }
        
        return categoryScores
    }
    
    private func identifyWeakAreas(from scores: [String: Double]) -> [WeakArea] {
        let threshold = 70.0
        
        var weakAreas: [WeakArea] = scores
            .filter { $0.value < threshold }
            .map { category, score in
                let priority: WeakArea.Priority = {
                    if score < 50 { return .critical }
                    if score < 65 { return .high }
                    return .medium
                }()
                
                return WeakArea(
                    id: UUID(),
                    categoryId: category,
                    categoryName: category,
                    score: score,
                    questionsAnswered: 0,
                    correctAnswers: 0,
                    priority: priority
                )
            }
        
        weakAreas.sort { $0.priority < $1.priority }
        return Array(weakAreas.prefix(5))
    }
    
    private func computeWeightedScore(_ categoryScores: [String: Double]) -> Double {
        guard !categoryScores.isEmpty else { return 0 }
        
        let scores = Array(categoryScores.values)
        let average = scores.reduce(0, +) / Double(scores.count)
        let minimum = scores.min() ?? 0
        
        return (average * 0.8) + (minimum * 0.2)
    }
    
    private func determineUrgency(daysToExam: Int?) -> ReadinessScore.UrgencyLevel {
        guard let days = daysToExam else { return .comfortable }
        
        if days < 7 { return .critical }
        if days < 15 { return .high }
        if days < 31 { return .moderate }
        return .comfortable
    }
    
    private func generateRecommendations(
        weakAreas: [WeakArea],
        daysToExam: Int?
    ) -> [PrepRecommendation] {
        return weakAreas.enumerated().map { index, weakArea in
            let baseQuestions = weakArea.recommendedPracticeQuestions
            
            let adjustedQuestions: Int = {
                guard let days = daysToExam else { return baseQuestions }
                if days < 7 { return baseQuestions + 10 }
                if days < 14 { return baseQuestions + 5 }
                return baseQuestions
            }()
            
            return PrepRecommendation(
                id: UUID(),
                weakAreaId: weakArea.id,
                categoryId: weakArea.categoryId,
                suggestedQuestions: adjustedQuestions,
                estimatedMinutes: adjustedQuestions * 2,
                priority: weakArea.priority,
                actionText: generateActionText(for: weakArea, priority: index)
            )
        }
    }
    
    private func generateActionText(for weakArea: WeakArea, priority: Int) -> String {
        let emoji = priority == 0 ? "🎯 " : ""
        return "\(emoji)Master \(weakArea.categoryName) (\(Int(100 - weakArea.score))% improvement)"
    }
    
    private func identifyStrengths(from scores: [String: Double]) -> [String] {
        return scores
            .filter { $0.value >= 80 }
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }
    
    private func fallbackResult() -> ReadinessCalculationResult {
        ReadinessCalculationResult(
            score: ReadinessScore(
                id: UUID(),
                overallScore: 0,
                categoryScores: [:],
                calculatedAt: Date(),
                daysToExam: nil,
                urgencyLevel: .comfortable
            ),
            weakAreas: [],
            strengths: [],
            recommendations: []
        )
    }
}