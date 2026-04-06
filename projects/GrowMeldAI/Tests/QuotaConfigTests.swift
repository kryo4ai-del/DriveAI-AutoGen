import XCTest
@testable import DriveAI

final class QuotaConfigTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func test_default_config_returns_correct_limits() {
        let config = QuotaConfig.default
        
        XCTAssertEqual(config.dailyQuestionLimit, 5)
        XCTAssertEqual(config.weeklyQuestionLimit, 25)
        XCTAssertEqual(config.monthlyQuestionLimit, 100)
        XCTAssertEqual(config.premiumMultiplier, 3.0)
    }
    
    func test_limit_free_user_daily() {
        let config = QuotaConfig.default
        let limit = config.limit(for: .daily, isPremium: false)
        XCTAssertEqual(limit, 5)
    }
    
    func test_limit_premium_user_daily_applies_multiplier() {
        let config = QuotaConfig.default
        let limit = config.limit(for: .daily, isPremium: true)
        XCTAssertEqual(limit, 15) // 5 * 3.0
    }
    
    func test_limit_premium_user_weekly() {
        let config = QuotaConfig.default
        let limit = config.limit(for: .weekly, isPremium: true)
        XCTAssertEqual(limit, 75) // 25 * 3.0
    }
    
    func test_limit_premium_user_monthly() {
        let config = QuotaConfig.default
        let limit = config.limit(for: .monthly, isPremium: true)
        XCTAssertEqual(limit, 300) // 100 * 3.0
    }
    
    // MARK: - Custom Config
    
    func test_custom_config_with_different_multiplier() {
        let custom = QuotaConfig(
            dailyQuestionLimit: 10,
            weeklyQuestionLimit: 50,
            monthlyQuestionLimit: 200,
            premiumMultiplier: 2.5
        )
        
        let dailyPremium = custom.limit(for: .daily, isPremium: true)
        XCTAssertEqual(dailyPremium, 25) // 10 * 2.5
    }
    
    func test_limit_zero_multiplier() {
        let config = QuotaConfig(
            dailyQuestionLimit: 5,
            weeklyQuestionLimit: 25,
            monthlyQuestionLimit: 100,
            premiumMultiplier: 0.0
        )
        
        let limit = config.limit(for: .daily, isPremium: true)
        XCTAssertEqual(limit, 0)
    }
    
    // MARK: - Edge Cases
    
    func test_limit_handles_fractional_multiplier() {
        let config = QuotaConfig(
            dailyQuestionLimit: 5,
            weeklyQuestionLimit: 25,
            monthlyQuestionLimit: 100,
            premiumMultiplier: 1.5
        )
        
        let limit = config.limit(for: .daily, isPremium: true)
        XCTAssertEqual(limit, 7) // 5 * 1.5 = 7.5 → truncates to 7
    }
}

final class QuotaUsageTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func test_remaining_calculates_correctly() {
        let usage = QuotaUsage(
            period: .daily,
            used: 2,
            limit: 5,
            resetDate: Date()
        )
        
        XCTAssertEqual(usage.remaining, 3)
    }
    
    func test_remaining_zero_when_exhausted() {
        let usage = QuotaUsage(
            period: .daily,
            used: 5,
            limit: 5,
            resetDate: Date()
        )
        
        XCTAssertEqual(usage.remaining, 0)
    }
    
    func test_percentage_used_healthy() {
        let usage = QuotaUsage(
            period: .daily,
            used: 1,
            limit: 5,
            resetDate: Date()
        )
        
        XCTAssertEqual(usage.percentageUsed, 0.2)
    }
    
    func test_percentage_used_warning() {
        let usage = QuotaUsage(
            period: .daily,
            used: 4,
            limit: 5,
            resetDate: Date()
        )
        
        XCTAssertEqual(usage.percentageUsed, 0.8)
    }
    
    func test_is_exhausted_true() {
        let usage = QuotaUsage(
            period: .daily,
            used: 5,
            limit: 5,
            resetDate: Date()
        )
        
        XCTAssertTrue(usage.isExhausted)
    }
    
    func test_is_exhausted_false() {
        let usage = QuotaUsage(
            period: .daily,
            used: 4,
            limit: 5,
            resetDate: Date()
        )
        
        XCTAssertFalse(usage.isExhausted)
    }
    
    func test_approach_level_healthy() {
        let usage = QuotaUsage(
            period: .daily,
            used: 3,
            limit: 10,
            resetDate: Date()
        ) // 30% used
        
        XCTAssertEqual(usage.approachLevel, .healthy)
    }
    
    func test_approach_level_warning() {
        let usage = QuotaUsage(
            period: .daily,
            used: 4,
            limit: 5,
            resetDate: Date()
        ) // 80% used
        
        XCTAssertEqual(usage.approachLevel, .warning)
    }
    
    func test_approach_level_critical() {
        let usage = QuotaUsage(
            period: .daily,
            used: 5,
            limit: 5,
            resetDate: Date()
        ) // 100% used
        
        XCTAssertEqual(usage.approachLevel, .critical)
    }
    
    // MARK: - Edge Cases
    
    func test_percentage_used_with_zero_limit() {
        let usage = QuotaUsage(
            period: .daily,
            used: 0,
            limit: 0,
            resetDate: Date()
        )
        
        XCTAssertEqual(usage.percentageUsed, 0.0)
    }
    
    func test_remaining_never_negative() {
        let usage = QuotaUsage(
            period: .daily,
            used: 10,
            limit: 5,
            resetDate: Date()
        )
        
        XCTAssertEqual(usage.remaining, 0) // max(0, 5-10) = 0
    }
    
    func test_approach_level_exactly_70_percent() {
        let usage = QuotaUsage(
            period: .daily,
            used: 7,
            limit: 10,
            resetDate: Date()
        ) // Exactly 70%
        
        XCTAssertEqual(usage.approachLevel, .warning)
    }
    
    func test_approach_level_exactly_90_percent() {
        let usage = QuotaUsage(
            period: .daily,
            used: 9,
            limit: 10,
            resetDate: Date()
        ) // Exactly 90%
        
        XCTAssertEqual(usage.approachLevel, .critical)
    }
    
    // MARK: - Accessibility
    
    func test_healthy_accessibility_label() {
        XCTAssertEqual(
            LimitApproachLevel.healthy.accessibilityLabel,
            "Quota healthy"
        )
    }
    
    func test_warning_accessibility_label() {
        XCTAssertEqual(
            LimitApproachLevel.warning.accessibilityLabel,
            "Quota approaching limit"
        )
    }
    
    func test_critical_accessibility_label() {
        XCTAssertEqual(
            LimitApproachLevel.critical.accessibilityLabel,
            "Quota critically low"
        )
    }
}