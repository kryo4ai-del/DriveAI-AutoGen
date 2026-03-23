import Foundation
import Combine

@MainActor
class TrendAnalyzer: ObservableObject {
    private let dataService: LocalDataService
    
    init(dataService: LocalDataService) {
        self.dataService = dataService
    }
    
    func analyzeTrends() async -> [PerformanceTrend] {
        do {
            let userAnswers = try await dataService.fetchUserAnswerHistory()
            let questions = try await dataService.fetchAllQuestions()
            
            let categorized = Dictionary(grouping: userAnswers) { (answer: UserAnswer) -> String in
                let question = questions.first(where: { $0.id.uuidString == answer.questionId })
                return question?.categoryId ?? "Unknown"
            }
            
            return categorized.map { category, answers in
                let sortedAnswers = answers.sorted { $0.answeredAt < $1.answeredAt }
                let dataPoints = generateDataPoints(from: sortedAnswers)
                let trend = determineTrend(from: dataPoints)
                
                return PerformanceTrend(
                    id: UUID(),
                    categoryId: category,
                    categoryName: category,
                    dataPoints: dataPoints,
                    trend: trend
                )
            }
        } catch {
            return []
        }
    }
    
    private func generateDataPoints(from answers: [UserAnswer]) -> [TrendPoint] {
        let windowSize = 10
        var dataPoints: [TrendPoint] = []
        
        for i in stride(from: 0, to: answers.count, by: windowSize) {
            let end = min(i + windowSize, answers.count)
            let window = answers[i..<end]
            
            let score = (Double(window.filter { $0.isCorrect }.count) / Double(window.count)) * 100
            
            dataPoints.append(TrendPoint(
                score: score,
                date: window.last?.answeredAt ?? Date(),
                questionCount: window.count
            ))
        }
        
        return dataPoints
    }
    
    private func determineTrend(from points: [TrendPoint]) -> PerformanceTrend.TrendDirection {
        guard points.count >= 3 else { return .stable }
        
        let recent = points.suffix(3).map { $0.score }
        let older = points.dropLast(3).map { $0.score }
        
        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let olderAvg = older.isEmpty ? recentAvg : older.reduce(0, +) / Double(older.count)
        
        let difference = recentAvg - olderAvg
        
        if difference > 5 { return .improving }
        if difference < -5 { return .declining }
        return .stable
    }
}