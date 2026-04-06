import XCTest
@testable import DriveAI

final class MonthlySubscriptionPlanTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func test_init_createsValidPlan() {
        let plan = MonthlySubscriptionPlan(
            price: 4.99,
            currency: "EUR",
            trialDays: 7,
            autoRenews: true
        )
        
        XCTAssertEqual(plan.price, 4.99)
        XCTAssertEqual(plan.currency, "EUR")
        XCTAssertEqual(plan.trialDays, 7)
        XCTAssertTrue(plan.autoRenews)
    }
    
    func test_trialExpiryDate_calculatesCorrectly() {
        let calendar = Calendar.current
        let now = Date()
        let plan = MonthlySubscriptionPlan(
            price: 4.99,
            currency: "EUR",
            trialDays: 7,
            createdAt: now
        )
        
        let expected = calendar.date(byAdding: .day, value: 7, to: now)!
        let components = calendar.dateComponents([.day], from: plan.trialExpiryDate, to: expected)
        
        XCTAssertEqual(components.day, 0)  // Same day
    }
    
    func test_daysRemainingInTrial_returnsCorrectCount() {
        let calendar = Calendar.current
        let now = Date()
        let plan = MonthlySubscriptionPlan(
            price: 4.99,
            currency: "EUR",
            trialDays: 7,
            createdAt: calendar.date(byAdding: .day, value: -5, to: now)!  // 5 days ago
        )
        
        XCTAssertEqual(plan.daysRemainingInTrial, 2)  // 2 days left
    }
    
    func test_displayPrice_formatsCorrectly() {
        let plan = MonthlySubscriptionPlan(
            price: 4.99,
            currency: "EUR"
        )
        
        let displayPrice = plan.displayPrice
        XCTAssertTrue(displayPrice.contains("4.99") || displayPrice.contains("4,99"))  // Locale-dependent
        XCTAssertTrue(displayPrice.contains("€") || displayPrice.contains("EUR"))
    }
    
    // MARK: - Edge Cases
    
    func test_trialDays_zeroValue() {
        let plan = MonthlySubscriptionPlan(
            price: 4.99,
            currency: "EUR",
            trialDays: 0
        )
        
        XCTAssertEqual(plan.daysRemainingInTrial, 0)
        XCTAssertTrue(plan.isTrialExpired)
    }
    
    func test_trialDays_maxValue() {
        let plan = MonthlySubscriptionPlan(
            price: 4.99,
            currency: "EUR",
            trialDays: 30
        )
        
        XCTAssertEqual(plan.trialDays, 30)
        XCTAssertLessThanOrEqual(plan.daysRemainingInTrial, 30)
    }
    
    func test_daysRemaining_afterExpiry() {
        let calendar = Calendar.current
        let plan = MonthlySubscriptionPlan(
            price: 4.99,
            currency: "EUR",
            trialDays: 7,
            createdAt: calendar.date(byAdding: .day, value: -10, to: Date())!  // 10 days ago
        )
        
        XCTAssertEqual(plan.daysRemainingInTrial, 0)  // clamped to 0
        XCTAssertTrue(plan.isTrialExpired)
    }
    
    func test_price_zeroValue() {
        let plan = MonthlySubscriptionPlan(
            price: 0,
            currency: "EUR",
            trialDays: 7
        )
        
        XCTAssertEqual(plan.price, 0)
        XCTAssertTrue(plan.displayPrice.contains("0"))
    }
    
    func test_price_largeValue() {
        let plan = MonthlySubscriptionPlan(
            price: 99.99,
            currency: "EUR"
        )
        
        XCTAssertEqual(plan.price, 99.99)
        XCTAssertTrue(plan.displayPrice.contains("99.99") || plan.displayPrice.contains("99,99"))
    }
    
    // MARK: - Codable
    
    func test_codable_roundTrip() throws {
        let original = MonthlySubscriptionPlan(
            id: UUID(),
            price: 4.99,
            currency: "EUR",
            trialDays: 7,
            autoRenews: true,
            createdAt: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(MonthlySubscriptionPlan.self, from: data)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.price, decoded.price)
        XCTAssertEqual(original.currency, decoded.currency)
        XCTAssertEqual(original.trialDays, decoded.trialDays)
    }
    
    func test_codable_dateWithoutMilliseconds() throws {
        let plan = MonthlySubscriptionPlan(
            price: 4.99,
            currency: "EUR",
            createdAt: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(plan)
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        
        // Verify no milliseconds in ISO8601 string
        XCTAssertFalse(jsonString.contains(".000Z"), "ISO8601 should not include milliseconds")
    }
    
    func test_codable_invalidDateFormat() throws {
        let jsonData = """
        {
            "id": "123e4567-e89b-12d3-a456-426614174000",
            "price": 4.99,
            "currency": "EUR",
            "trialDays": 7,
            "autoRenews": true,
            "created_at": "invalid-date"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        XCTAssertThrowsError(
            try decoder.decode(MonthlySubscriptionPlan.self, from: jsonData)
        )
    }
    
    // MARK: - Locale & Currency
    
    func test_displayPrice_chf() {
        let plan = MonthlySubscriptionPlan(
            price: 5.50,
            currency: "CHF"
        )
        
        let displayPrice = plan.displayPrice
        XCTAssertTrue(displayPrice.contains("5.50") || displayPrice.contains("5,50"))
        XCTAssertTrue(displayPrice.contains("CHF") || displayPrice.contains("Fr."))
    }
    
    func test_displayPrice_gbp() {
        let plan = MonthlySubscriptionPlan(
            price: 3.99,
            currency: "GBP"
        )
        
        let displayPrice = plan.displayPrice
        XCTAssertTrue(displayPrice.contains("3.99") || displayPrice.contains("3,99"))
    }
}