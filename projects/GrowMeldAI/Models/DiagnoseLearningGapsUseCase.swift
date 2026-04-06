protocol DiagnoseLearningGapsUseCase {
    func execute(for examResult: ExamResult) async throws -> [LearningGap]
}

class DiagnoseLearningGapsUseCaseImpl: DiagnoseLearningGapsUseCase {
    private let repository: DiagnosticRepository
    
    func execute(for examResult: ExamResult) async throws -> [LearningGap] {
        // 1. Analyze incorrect answers
        let incorrectTopics = examResult.incorrectAnswers.map(\.topic)
        
        // 2. Fetch historical performance per topic
        let historicalData = try await repository.fetchHistoricalPerformance()
        
        // 3. Calculate gap severity using success rate + attempt count
        let gaps = incorrectTopics.compactMap { topic in
            let performance = historicalData[topic]
            let successRate = Double(performance?.correctCount ?? 0) / Double(performance?.totalAttempts ?? 1)
            let severity = calculateSeverity(successRate, performance?.attemptCount ?? 0)
            
            return LearningGap(
                id: UUID(),
                topicID: topic,
                topic: topic,
                description: "Du hast \(performance?.incorrectCount ?? 1) Fehler in diesem Bereich",
                gapSeverity: severity,
                lastReviewedDate: performance?.lastReviewedDate,
                attemptCount: performance?.attemptCount ?? 1,
                successRate: successRate
            )
        }
        
        return gaps.sorted { $0.gapSeverity < $1.gapSeverity }
    }
    
    private func calculateSeverity(_ successRate: Double, _ attemptCount: Int) -> GapSeverity {
        if successRate < 0.5 { return .critical }
        if successRate < 0.75 { return .moderate }
        return .minor
    }
}