import XCTest
@testable import DriveAI

final class QuotaStateTests: XCTestCase {
    
    // MARK: - Initialization
    
    func testDefaultInitialization() {
        let quota = QuotaState()
        
        XCTAssertEqual(quota.dailyLimit, 20)
        XCTAssertEqual(quota.questionsConsumedToday, 0)
        XCTAssertFalse(quota.isExhausted)
        XCTAssertEqual(quota.remainingToday, 20)
    }
    
    func testInitializationWithValidValues() {
        let now = Date()
        let quota = QuotaState(
            dailyLimit: 30,
            questionsConsumedToday: 15,
            lastResetDate: now
        )
        
        XCTAssertEqual(quota.dailyLimit, 30)
        XCTAssertEqual(quota.questionsConsumedToday, 15)
        XCTAssertEqual(quota.remainingToday, 15)
        XCTAssertEqual(quota.lastResetDate, now)
    }
    
    func testNegativeDailyLimitClamped() {
        let quota = QuotaState(dailyLimit: -5)
        
        XCTAssertEqual(quota.dailyLimit, 1) // Clamped to minimum
    }
    
    func testNegativeConsumedClamped() {
        let quota = QuotaState(questionsConsumedToday: -10)
        
        XCTAssertEqual(quota.questionsConsumedToday, 0) // Clamped to zero
    }
    
    // MARK: - Calculations
    
    func testRemainingQuestions() {
        let quota = QuotaState(dailyLimit: 20, questionsConsumedToday: 7)
        
        XCTAssertEqual(quota.remainingToday, 13)
    }
    
    func testRemainingQuestionsWhenExhausted() {
        let quota = QuotaState(dailyLimit: 20, questionsConsumedToday: 20)
        
        XCTAssertEqual(quota.remainingToday, 0)
    }
    
    func testRemainingQuestionsNeverNegative() {
        let quota = QuotaState(dailyLimit: 20, questionsConsumedToday: 25)
        
        XCTAssertEqual(quota.remainingToday, 0) // Safe: never negative
    }
    
    func testQuotaPercentage() {
        let quota = QuotaState(dailyLimit: 20, questionsConsumedToday: 10)
        
        XCTAssertEqual(quota.quotaPercentage, 0.5, accuracy: 0.01)
    }
    
    func testQuotaPercentageAtZero() {
        let quota = QuotaState(dailyLimit: 20, questionsConsumedToday: 0)
        
        XCTAssertEqual(quota.quotaPercentage, 0.0, accuracy: 0.01)
    }
    
    func testQuotaPercentageAtFullCapacity() {
        let quota = QuotaState(dailyLimit: 20, questionsConsumedToday: 20)
        
        XCTAssertEqual(quota.quotaPercentage, 1.0, accuracy: 0.01)
    }
    
    func testQuotaPercentageAboveCapacity() {
        let quota = QuotaState(dailyLimit: 20, questionsConsumedToday: 25)
        
        XCTAssertEqual(quota.quotaPercentage, 1.25, accuracy: 0.01)
    }
    
    // MARK: - Status Checks
    
    func testIsExhaustedWhenAtLimit() {
        let quota = QuotaState(dailyLimit: 20, questionsConsumedToday: 20)
        
        XCTAssertTrue(quota.isExhausted)
    }
    
    func testIsNotExhaustedBeforeLimit() {
        let quota = QuotaState(dailyLimit: 20, questionsConsumedToday: 19)
        
        XCTAssertFalse(quota.isExhausted)
    }
    
    func testIsExhaustedWhenAboveLimit() {
        let quota = QuotaState(dailyLimit: 20, questionsConsumedToday: 21)
        
        XCTAssertTrue(quota.isExhausted)
    }
    
    func testIsNearLimitAt80Percent() {
        let quota = QuotaState(dailyLimit: 20, questionsConsumedToday: 16)
        
        XCTAssertTrue(quota.isNearLimit)
    }
    
    func testIsNotNearLimitBelow80Percent() {
        let quota = QuotaState(dailyLimit: 20, questionsConsumedToday: 15)
        
        XCTAssertFalse(quota.isNearLimit)
    }
    
    // MARK: - Codable
    
    func testEncodingAndDecoding() throws {
        let original = QuotaState(
            dailyLimit: 25,
            questionsConsumedToday: 10,
            lastResetDate: Date()
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(QuotaState.self, from: encoded)
        
        XCTAssertEqual(decoded.dailyLimit, original.dailyLimit)
        XCTAssertEqual(decoded.questionsConsumedToday, original.questionsConsumedToday)
    }
}