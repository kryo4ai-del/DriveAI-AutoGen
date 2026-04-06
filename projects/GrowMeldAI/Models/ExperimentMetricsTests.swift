import XCTest
@testable import DriveAI

final class ExperimentMetricsTests: XCTestCase {
    
    let mockCalculator = MockMetricsCalculator()
    
    func testVariantMetrics_AllCorrectAnswers() {
        let events = [
            mockEvent(eventType: .answerSubmitted, correct: true, time: 2.0),
            mockEvent(eventType: .answerSubmitted, correct: true, time: 3.0),
            mockEvent(eventType: .answerSubmitted, correct: true, time: 2.5)
        ]
        
        let metrics = VariantMetrics(
            variantId: "v1",
            events: events,
            calculator: mockCalculator
        )
        
        XCTAssertEqual(metrics.correctAnswerRate, 1.0)
        XCTAssertEqual(metrics.totalEvents, 3)
    }
    
    func testVariantMetrics_PartialCorrect() {
        let events = [
            mockEvent(eventType: .answerSubmitted, correct: true, time: 2.0),
            mockEvent(eventType: .answerSubmitted, correct: false, time: 3.0),
            mockEvent(eventType: .answerSubmitted, correct: true, time: 2.5)
        ]
        
        let metrics = VariantMetrics(
            variantId: "v1",
            events: events,
            calculator: mockCalculator
        )
        
        XCTAssertEqual(metrics.correctAnswerRate, 2.0 / 3.0, accuracy: 0.01)
    }
    
    func testVariantMetrics_IgnoresNonSubmittedEvents() {
        let events = [
            mockEvent(eventType: .questionViewed),  // ← Ignored for correctness
            mockEvent(eventType: .answerSubmitted, correct: true, time: 2.0),
            mockEvent(eventType: .feedbackShown)    // ← Ignored
        ]
        
        let metrics = VariantMetrics(
            variantId: "v1",
            events: events,
            calculator: mockCalculator
        )
        
        XCTAssertEqual(metrics.correctAnswerRate, 1.0)
        XCTAssertEqual(metrics.totalEvents, 3)  // All events count for total
    }
    
    func testVariantMetrics_AverageTimeCalculation() {
        let events = [
            mockEvent(eventType: .answerSubmitted, time: 1.0),
            mockEvent(eventType: .answerSubmitted, time: 3.0),
            mockEvent(eventType: .answerSubmitted, time: 2.0)
        ]
        
        let metrics = VariantMetrics(
            variantId: "v1",
            events: events,
            calculator: mockCalculator
        )
        
        XCTAssertEqual(metrics.avgTimeToAnswer, 2.0, accuracy: 0.01)
    }
    
    func testVariantMetrics_IgnoresInvalidTimings() {
        let events = [
            mockEvent(eventType: .answerSubmitted, time: 2.0),
            mockEvent(eventType: .answerSubmitted, time: -1.0),  // ← Invalid
            mockEvent(eventType: .answerSubmitted, time: 4.0)
        ]
        
        let metrics = VariantMetrics(
            variantId: "v1",
            events: events,
            calculator: mockCalculator
        )
        
        // Only 2.0 and 4.0 averaged
        XCTAssertEqual(metrics.avgTimeToAnswer, 3.0, accuracy: 0.01)
    }
    
    func testVariantMetrics_EngagementScore() {
        let events = [
            mockEvent(eventType: .answerSubmitted, correct: true),
            mockEvent(eventType: .answerSubmitted, correct: true),
            mockEvent(eventType: .answerSubmitted, correct: false)
        ]
        
        let metrics = VariantMetrics(
            variantId: "v1",
            events: events,
            calculator: mockCalculator
        )
        
        // engagement = totalEvents * correctRate = 3 * (2/3) = 2.0
        XCTAssertEqual(metrics.engagementScore, 2.0, accuracy: 0.01)
    }
    
    // MARK: - Helpers
    
    private func mockEvent(
        eventType: ExperimentEvent.EventType,
        correct: Bool? = nil,
        time: Double? = nil
    ) -> ExperimentEvent {
        var metadata: [String: AnyCodable] = [:]
        
        if let correct = correct {
            metadata["correct"] = .bool(correct)
        }
        
        if let time = time {
            metadata["timeToAnswer"] = .double(time)
        }
        
        return ExperimentEvent(
            id: UUID(),
            experimentId: "exp1",
            variantId: "v1",
            eventType: eventType,
            timestamp: Date(),
            metadata: metadata
        )
    }
}

// Mock calculator for testing metrics calculation
final class MockMetricsCalculator: MetricsCalculator {
    func calculateCorrectAnswerRate(_ events: [ExperimentEvent]) -> Double {
        let submitted = events.filter { $0.eventType == .answerSubmitted }
        guard !submitted.isEmpty else { return 0 }
        
        let correct = submitted.filter { $0.metadata["correct"]?.asBool() ?? false }.count
        return Double(correct) / Double(submitted.count)
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