// Tests/Freemium/Models/FreemiumStateTests.swift

import XCTest
@testable import DriveAI

class FreemiumStateTests: XCTestCase {
    
    // MARK: - canAnswerQuestion Property
    
    func test_canAnswerQuestion_unlimited_returnsTrue() {
        let state: FreemiumState = .unlimited(premiumUntil: .distantFuture)
        XCTAssertTrue(state.canAnswerQuestion)
    }
    
    func test_canAnswerQuestion_trialActive_returnsTrue() {
        let state: FreemiumState = .trialActive(daysRemaining: 5, questionsUsed: 10)
        XCTAssertTrue(state.canAnswerQuestion)
    }
    
    func test_canAnswerQuestion_freeTierActive_returnsTrue() {
        let state: FreemiumState = .freeTierActive(questionsRemaining: 3)
        XCTAssertTrue(state.canAnswerQuestion)
    }
    
    func test_canAnswerQuestion_freeTierExhausted_returnsFalse() {
        let state: FreemiumState = .freeTierExhausted
        XCTAssertFalse(state.canAnswerQuestion)
    }
    
    func test_canAnswerQuestion_trialExpired_returnsFalse() {
        let state: FreemiumState = .trialExpired
        XCTAssertFalse(state.canAnswerQuestion)
    }
    
    // MARK: - limitApproach Property
    
    func test_limitApproach_unlimited_safe() {
        let state: FreemiumState = .unlimited(premiumUntil: nil)
        XCTAssertEqual(state.limitApproach, .safe)
    }
    
    func test_limitApproach_freeTierSafe_returnsCorrectLevel() {
        let state: FreemiumState = .freeTierActive(questionsRemaining: 5)
        XCTAssertEqual(state.limitApproach, .safe)
    }
    
    func test_limitApproach_freeTierWarning_withThreeRemaining() {
        let state: FreemiumState = .freeTierActive(questionsRemaining: 3)
        XCTAssertEqual(state.limitApproach, .warning)
    }
    
    func test_limitApproach_freeTierCritical_withOneRemaining() {
        let state: FreemiumState = .freeTierActive(questionsRemaining: 1)
        XCTAssertEqual(state.limitApproach, .critical)
    }
    
    func test_limitApproach_freeTierCritical_withZeroRemaining() {
        let state: FreemiumState = .freeTierActive(questionsRemaining: 0)
        XCTAssertEqual(state.limitApproach, .critical)
    }
    
    func test_limitApproach_exhausted_critical() {
        let state: FreemiumState = .freeTierExhausted
        XCTAssertEqual(state.limitApproach, .critical)
    }
    
    func test_limitApproach_trialExpired_critical() {
        let state: FreemiumState = .trialExpired
        XCTAssertEqual(state.limitApproach, .critical)
    }
    
    func test_limitApproach_trialCritical_onLastDay() {
        let state: FreemiumState = .trialActive(daysRemaining: 1, questionsUsed: 50)
        XCTAssertEqual(state.limitApproach, .critical)
    }
    
    func test_limitApproach_trialWarning_withinThreeDays() {
        let state: FreemiumState = .trialActive(daysRemaining: 3, questionsUsed: 20)
        XCTAssertEqual(state.limitApproach, .warning)
    }
    
    // MARK: - progressPercentage Property
    
    func test_progressPercentage_unlimited_zero() {
        let state: FreemiumState = .unlimited(premiumUntil: nil)
        XCTAssertEqual(state.progressPercentage, 0)
    }
    
    func test_progressPercentage_freeTierHalf() {
        // Assuming default config: 5 questions/day
        let state: FreemiumState = .freeTierActive(questionsRemaining: 2) // 2/5 = 40%, but remaining
        // Note: progressPercentage likely represents remaining, so 2/5 = 0.4
        let percentage = state.progressPercentage
        XCTAssertEqual(percentage, 0.4, accuracy: 0.01)
    }
    
    func test_progressPercentage_freeTierEmpty() {
        let state: FreemiumState = .freeTierActive(questionsRemaining: 0)
        XCTAssertEqual(state.progressPercentage, 0)
    }
    
    func test_progressPercentage_trialMidway() {
        // Assuming default: 14-day trial
        let state: FreemiumState = .trialActive(daysRemaining: 7, questionsUsed: 10)
        XCTAssertEqual(state.progressPercentage, 0.5, accuracy: 0.01)
    }
    
    func test_progressPercentage_trialLastDay() {
        let state: FreemiumState = .trialActive(daysRemaining: 1, questionsUsed: 100)
        XCTAssertEqual(state.progressPercentage, 0.071, accuracy: 0.01)
    }
    
    // MARK: - displayLabel Property
    
    func test_displayLabel_unlimited() {
        let state: FreemiumState = .unlimited(premiumUntil: nil)
        XCTAssertEqual(state.displayLabel, "Premium")
    }
    
    func test_displayLabel_trialActive() {
        let state: FreemiumState = .trialActive(daysRemaining: 5, questionsUsed: 10)
        XCTAssertTrue(state.displayLabel.contains("5"))
        XCTAssertTrue(state.displayLabel.contains("Trial"))
    }
    
    func test_displayLabel_freeTierActive() {
        let state: FreemiumState = .freeTierActive(questionsRemaining: 3)
        XCTAssertTrue(state.displayLabel.contains("3"))
        XCTAssertTrue(state.displayLabel.contains("Fragen"))
    }
    
    func test_displayLabel_exhausted() {
        let state: FreemiumState = .freeTierExhausted
        XCTAssertTrue(state.displayLabel.contains("Limit"))
    }
    
    // MARK: - Equatable Conformance
    
    func test_equatable_sameVariantSameValues_equal() {
        let state1: FreemiumState = .freeTierActive(questionsRemaining: 3)
        let state2: FreemiumState = .freeTierActive(questionsRemaining: 3)
        XCTAssertEqual(state1, state2)
    }
    
    func test_equatable_sameVariantDifferentValues_notEqual() {
        let state1: FreemiumState = .freeTierActive(questionsRemaining: 3)
        let state2: FreemiumState = .freeTierActive(questionsRemaining: 2)
        XCTAssertNotEqual(state1, state2)
    }
    
    func test_equatable_differentVariants_notEqual() {
        let state1: FreemiumState = .freeTierActive(questionsRemaining: 5)
        let state2: FreemiumState = .freeTierExhausted
        XCTAssertNotEqual(state1, state2)
    }
}