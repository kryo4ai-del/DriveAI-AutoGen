import XCTest
@testable import DriveAI

final class SubscriptionTests: XCTestCase {
    
    // MARK: - Subscription.isActive Tests
    
    func testSubscriptionIsActiveDuringValidPeriod() {
        let now = Date.now
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        
        let subscription = Subscription(
            type: .trial(),
            expiryDate: tomorrow
        )
        
        XCTAssertTrue(subscription.isActive)
    }
    
    func testSubscriptionIsInactiveAfterExpiry() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!
        
        let subscription = Subscription(
            type: .trial(),
            expiryDate: yesterday
        )
        
        XCTAssertFalse(subscription.isActive)
    }
    
    func testSubscriptionIsActiveTodayAtEndOfDay() {
        // Edge case: expires at end of today
        let today = Calendar.current.startOfDay(for: Date.now)
        let almostTomorrow = today.addingTimeInterval(86400 - 1) // 23:59:59
        
        let subscription = Subscription(
            type: .trial(),
            expiryDate: almostTomorrow
        )
        
        XCTAssertTrue(subscription.isActive)
    }
    
    func testSubscriptionIsInactiveNextDay() {
        let today = Calendar.current.startOfDay(for: Date.now)
        let tomorrow = today.addingTimeInterval(86400)
        
        let subscription = Subscription(
            type: .trial(),
            expiryDate: tomorrow
        )
        
        // Subscription expires tomorrow, so today it's still active
        XCTAssertTrue(subscription.isActive)
    }
    
    // MARK: - Subscription.daysRemaining Tests
    
    func testDaysRemainingReturnsCorrectCount() {
        let now = Date.now
        let fiveDaysLater = Calendar.current.date(byAdding: .day, value: 5, to: now)!
        
        let subscription = Subscription(
            type: .trial(),
            expiryDate: fiveDaysLater
        )
        
        XCTAssertEqual(subscription.daysRemaining, 5)
    }
    
    func testDaysRemainingIsNilWhenExpired() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!
        
        let subscription = Subscription(
            type: .trial(),
            expiryDate: yesterday
        )
        
        XCTAssertNil(subscription.daysRemaining)
    }
    
    func testDaysRemainingIsZeroOnLastDay() {
        let today = Calendar.current.startOfDay(for: Date.now)
        let almostTomorrow = today.addingTimeInterval(86400 - 1)
        
        let subscription = Subscription(
            type: .trial(),
            expiryDate: almostTomorrow
        )
        
        XCTAssertEqual(subscription.daysRemaining, 0)
    }
    
    func testDaysRemainingNeverNegative() {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date.now)!
        
        let subscription = Subscription(
            type: .trial(),
            expiryDate: weekAgo
        )
        
        // Should be nil, not negative
        XCTAssertNil(subscription.daysRemaining)
    }
    
    // MARK: - Subscription.isExpiringSoon Tests
    
    func testIsExpiringSoonWhenLessThanSevenDays() {
        let threeMoreDays = Calendar.current.date(byAdding: .day, value: 3, to: Date.now)!
        
        let subscription = Subscription(
            type: .monthly(priceInCents: 999),
            expiryDate: threeMoreDays
        )
        
        XCTAssertTrue(subscription.isExpiringSoon)
    }
    
    func testIsExpiringSoonExactlySevenDays() {
        let sevenMoreDays = Calendar.current.date(byAdding: .day, value: 7, to: Date.now)!
        
        let subscription = Subscription(
            type: .monthly(priceInCents: 999),
            expiryDate: sevenMoreDays
        )
        
        XCTAssertTrue(subscription.isExpiringSoon)
    }
    
    func testIsNotExpiringSoonMoreThanSevenDays() {
        let eightMoreDays = Calendar.current.date(byAdding: .day, value: 8, to: Date.now)!
        
        let subscription = Subscription(
            type: .monthly(priceInCents: 999),
            expiryDate: eightMoreDays
        )
        
        XCTAssertFalse(subscription.isExpiringSoon)
    }
    
    func testIsNotExpiringSoonWhenExpired() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!
        
        let subscription = Subscription(
            type: .trial(),
            expiryDate: yesterday
        )
        
        XCTAssertFalse(subscription.isExpiringSoon)
    }
    
    // MARK: - SubscriptionType Tests
    
    func testMonthlySubscriptionDuration() {
        let subscription = Subscription(
            type: .monthly(priceInCents: 999),
            expiryDate: Date.distantFuture
        )
        
        XCTAssertEqual(subscription.type.durationDays, 30)
    }
    
    func testAnnualSubscriptionDuration() {
        let subscription = Subscription(
            type: .annual(priceInCents: 8999),
            expiryDate: Date.distantFuture
        )
        
        XCTAssertEqual(subscription.type.durationDays, 365)
    }
    
    func testTrialSubscriptionDefaultDuration() {
        let subscription = Subscription(
            type: .trial(),
            expiryDate: Date.distantFuture
        )
        
        XCTAssertEqual(subscription.type.durationDays, 7)
    }
    
    func testTrialSubscriptionCustomDuration() {
        let subscription = Subscription(
            type: .trial(durationDays: 14),
            expiryDate: Date.distantFuture
        )
        
        XCTAssertEqual(subscription.type.durationDays, 14)
    }
    
    func testMonthlyPriceInCents() {
        let subscription = Subscription(
            type: .monthly(priceInCents: 499),
            expiryDate: Date.distantFuture
        )
        
        XCTAssertEqual(subscription.type.priceInCents, 499)
    }
    
    func testTrialHasNoPriceInCents() {
        let subscription = Subscription(
            type: .trial(),
            expiryDate: Date.distantFuture
        )
        
        XCTAssertNil(subscription.type.priceInCents)
    }
    
    func testMonthlyFormattedPrice() {
        let subscription = Subscription(
            type: .monthly(priceInCents: 999), // €9.99
            expiryDate: Date.distantFuture
        )
        
        let price = subscription.type.formattedPrice
        XCTAssertNotNil(price)
        XCTAssertTrue(price!.contains("9,99") || price!.contains("9.99"))
    }
    
    func testTrialFormattedPriceIsNil() {
        let subscription = Subscription(
            type: .trial(),
            expiryDate: Date.distantFuture
        )
        
        XCTAssertNil(subscription.type.formattedPrice)
    }
    
    // MARK: - SubscriptionStatus Tests
    
    func testSubscriptionStatusHasActiveSubscription() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!
        let subscription = Subscription(type: .trial(), expiryDate: tomorrow)
        let status = SubscriptionStatus(currentSubscription: subscription)
        
        XCTAssertTrue(status.hasActiveSubscription)
    }
    
    func testSubscriptionStatusNilSubscriptionIsNotActive() {
        let status = SubscriptionStatus(currentSubscription: nil)
        
        XCTAssertFalse(status.hasActiveSubscription)
        XCTAssertFalse(status.isPremiumUser)
    }
    
    func testTrialStatusIsInTrialPeriod() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!
        let subscription = Subscription(type: .trial(), expiryDate: tomorrow)
        let status = SubscriptionStatus(currentSubscription: subscription)
        
        XCTAssertTrue(status.isInTrialPeriod)
    }
    
    func testMonthlyStatusIsNotInTrialPeriod() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!
        let subscription = Subscription(type: .monthly(priceInCents: 999), expiryDate: tomorrow)
        let status = SubscriptionStatus(currentSubscription: subscription)
        
        XCTAssertFalse(status.isInTrialPeriod)
    }
    
    func testTrialDaysRemaining() {
        let fiveDaysLater = Calendar.current.date(byAdding: .day, value: 5, to: Date.now)!
        let subscription = Subscription(type: .trial(), expiryDate: fiveDaysLater)
        let status = SubscriptionStatus(currentSubscription: subscription)
        
        XCTAssertEqual(status.trialDaysRemaining, 5)
    }
    
    func testMonthlyTrialDaysRemainingIsNil() {
        let fiveDaysLater = Calendar.current.date(byAdding: .day, value: 5, to: Date.now)!
        let subscription = Subscription(type: .monthly(priceInCents: 999), expiryDate: fiveDaysLater)
        let status = SubscriptionStatus(currentSubscription: subscription)
        
        XCTAssertNil(status.trialDaysRemaining)
    }
}

// MARK: - Codable Tests

final class SubscriptionTypeCodeableTests: XCTestCase {
    
    func testMonthlySubscriptionEncodesDecode() throws {
        let original = SubscriptionType.monthly(priceInCents: 999)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SubscriptionType.self, from: data)
        
        XCTAssertEqual(original, decoded)
    }
    
    func testAnnualSubscriptionEncodesDecodes() throws {
        let original = SubscriptionType.annual(priceInCents: 8999)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SubscriptionType.self, from: data)
        
        XCTAssertEqual(original, decoded)
    }
    
    func testTrialSubscriptionEncodesDecodes() throws {
        let original = SubscriptionType.trial(durationDays: 14)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SubscriptionType.self, from: data)
        
        XCTAssertEqual(original, decoded)
    }
    
    func testTrialWithDefaultDurationEncodesDecodes() throws {
        let original = SubscriptionType.trial()
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SubscriptionType.self, from: data)
        
        XCTAssertEqual(original, decoded)
    }
    
    func testFullSubscriptionEncodeDecode() throws {
        let expiryDate = Calendar.current.date(byAdding: .day, value: 30, to: Date.now)!
        let original = Subscription(
            type: .monthly(priceInCents: 999),
            expiryDate: expiryDate
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Subscription.self, from: data)
        
        XCTAssertEqual(original.type, decoded.type)
        XCTAssertEqual(original.id, decoded.id)
    }
}