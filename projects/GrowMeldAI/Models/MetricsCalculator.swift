// Services/ABTesting/Core/MetricsCalculator.swift

protocol MetricsCalculator: Sendable {
    func calculateCorrectAnswerRate(_ events: [ExperimentEvent]) -> Double
    func calculateAverageTimeToAnswer(_ events: [ExperimentEvent]) -> TimeInterval
    func calculateEngagementScore(_ events: [ExperimentEvent]) -> Double
}

actor MetricsCalculatorImpl: MetricsCalculator {
    func calculateCorrectAnswerRate(_ events: [ExperimentEvent]) -> Double {
        let submittedEvents = events.filter { $0.eventType == .answerSubmitted }
        guard !submittedEvents.isEmpty else { return 0 }
        
        let correctCount = submittedEvents.filter { event in
            event.metadata["correct"]?.asBool() ?? false
        }.count
        
        return Double(correctCount) / Double(submittedEvents.count)
    }
    
    func calculateAverageTimeToAnswer(_ events: [ExperimentEvent]) -> TimeInterval {
        let validTimings = events.compactMap { event -> TimeInterval? in
            event.metadata["timeToAnswer"]?.asPositiveDouble()
        }
        
        guard !validTimings.isEmpty else { return 0 }
        return validTimings.reduce(0, +) / Double(validTimings.count)
    }
    
    func calculateEngagementScore(_ events: [ExperimentEvent]) -> Double {
        let correctRate = calculateCorrectAnswerRate(events)
        return Double(events.count) * max(correctRate, 0.0)
    }
}

// Simplify VariantMetrics

// Even cleaner: Use in aggregator

actor MetricsAggregator {
    private let dataService: ExperimentDataService
    private let calculator: MetricsCalculator
    
    func aggregateMetrics(for experimentId: String) async throws -> ExperimentMetrics {
        let events = try await dataService.fetchEvents(experimentId: experimentId)
        var variantMetrics: [String: VariantMetrics] = [:]
        
        for variantId in Set(events.map(\.variantId)) {
            let variantEvents = events.filter { $0.variantId == variantId }
            variantMetrics[variantId] = await VariantMetrics(
                variantId: variantId,
                events: variantEvents,
                calculator: calculator
            )
        }
        
        return ExperimentMetrics(
            experimentId: experimentId,
            variantMetrics: variantMetrics,
            generatedAt: Date()
        )
    }
}