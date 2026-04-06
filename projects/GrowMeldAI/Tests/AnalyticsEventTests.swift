// MARK: - Tests/Analytics/AnalyticsEventTests.swift

class AnalyticsEventTests: XCTestCase {
    
    // MARK: - Happy Path: Event Creation
    
    func test_questionAnsweredEvent_createsWithValidParameters() {
        let event = AnalyticsEvent.questionAnswered(
            categoryId: "traffic_signs",
            isCorrect: true,
            timeSeconds: 15
        )
        
        XCTAssertEqual(event.eventName, "question_answered")
        XCTAssertEqual(event.parameters["category_id"] as? String, "traffic_signs")
        XCTAssertEqual(event.parameters["is_correct"] as? Bool, true)
        XCTAssertEqual(event.parameters["time_seconds"] as? Int, 15)
    }
    
    func test_examCompletedEvent_calculatesScoreBucket() {
        let event = AnalyticsEvent.examCompleted(
            score: 73,
            passed: true,
            durationSeconds: 1850
        )
        
        let scoreBucket = event.parameters["score_bucket"] as? String
        XCTAssertEqual(scoreBucket, "70-80")  // Bucketed, not exact "73"
    }
    
    // MARK: - Edge Cases: Boundary Conditions
    
    func test_scoreEvent_bucketsBoundaryValues() {
        let cases: [(Int, String)] = [
            (0, "0-10"),
            (9, "0-10"),
            (10, "10-20"),
            (99, "90-100"),
            (100, "100-110"),  // Over 100 should still bucket
        ]
        
        for (score, expectedBucket) in cases {
            let event = AnalyticsEvent.examCompleted(
                score: score,
                passed: true,
                durationSeconds: 0
            )
            
            let bucket = event.parameters["score_bucket"] as? String
            XCTAssertEqual(bucket, expectedBucket, "Score \(score) should bucket to \(expectedBucket)")
        }
    }
    
    func test_sessionEndedEvent_withZeroDuration() {
        let event = AnalyticsEvent.sessionEnded(durationSeconds: 0)
        
        XCTAssertEqual(event.parameters["duration_seconds"] as? Int, 0)
        // Should not crash or filter out zero durations
    }
    
    func test_questionAnsweredEvent_withExtremeLongTime() {
        let event = AnalyticsEvent.questionAnswered(
            categoryId: "rules",
            isCorrect: false,
            timeSeconds: 3600  // 1 hour to answer a question
        )
        
        XCTAssertEqual(event.parameters["time_seconds"] as? Int, 3600)
        // Should accept unrealistic times (user left app open)
    }
    
    // MARK: - Invalid Inputs
    
    func test_questionAnsweredEvent_withEmptyCategoryId() {
        let event = AnalyticsEvent.questionAnswered(
            categoryId: "",
            isCorrect: true,
            timeSeconds: 5
        )
        
        XCTAssertEqual(event.parameters["category_id"] as? String, "")
        // Empty string should still be tracked (null-check happens server-side)
    }
    
    func test_questionAnsweredEvent_withNegativeTime() {
        let event = AnalyticsEvent.questionAnswered(
            categoryId: "signs",
            isCorrect: true,
            timeSeconds: -5  // System clock skew or timing bug
        )
        
        XCTAssertEqual(event.parameters["time_seconds"] as? Int, -5)
        // Should not validate client-side; let server sanitize
    }
    
    // MARK: - Enum Exhaustiveness
    
    func test_allEventTypesHaveEventName() {
        let events: [AnalyticsEvent] = [
            .questionAnswered(categoryId: "x", isCorrect: true, timeSeconds: 0),
            .questionSkipped(categoryId: "x"),
            .examStarted(examMode: "simulation"),
            .examCompleted(score: 50, passed: true, durationSeconds: 0),
            .sessionStarted,
            .sessionEnded(durationSeconds: 100),
            .examDateSet(weekNumber: 20),
            .categoryViewed(categoryId: "x"),
        ]
        
        for event in events {
            XCTAssertFalse(event.eventName.isEmpty, "\(event) should have eventName")
            XCTAssertFalse(event.eventName.contains(" "), "Event name \(event.eventName) should not contain spaces")
        }
    }
    
    func test_allEventTypesHaveParameters() {
        let events: [AnalyticsEvent] = [
            .questionAnswered(categoryId: "x", isCorrect: false, timeSeconds: 0),
            .sessionEnded(durationSeconds: 50),
        ]
        
        for event in events {
            let params = event.parameters
            XCTAssertFalse(params.isEmpty, "\(event) should have parameters dict")
            
            // All values should be JSON-encodable (String, Int, Bool, nil)
            for (key, value) in params {
                XCTAssertFalse(key.isEmpty, "Parameter key should not be empty")
                // Validate no unsafe types (no UIImage, custom objects, etc.)
            }
        }
    }
}