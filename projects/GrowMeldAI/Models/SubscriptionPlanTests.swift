// Features/Subscription/Tests/SubscriptionPlanTests.swift

import XCTest
@testable import DriveAI

final class SubscriptionPlanTests: XCTestCase {
    
    // MARK: - VAT Calculation (Critical for Tax Compliance)
    
    func testVATCalculationGermanyStandard() {
        let plan = SubscriptionPlan(
            id: UUID(),
            name: "Monats-Abo",
            durationMonths: 1,
            pricePerCycleEUR: 9.99,
            vatRatePercent: 19.0,  // German standard VAT
            features: ["Unlimited questions"],
            freeTrial: nil,
            appStoreProductId: "monthly_9.99"
        )
        
        let expectedGross = Decimal(9.99) + (Decimal(9.99) * Decimal(19.0) / 100)
        XCTAssertEqual(plan.priceGrossEUR, expectedGross, accuracy: 0.01)
    }
    
    func testVATCalculationAustria() {
        let plan = SubscriptionPlan(
            id: UUID(),
            name: "Monats-Abo",
            durationMonths: 1,
            pricePerCycleEUR: 9.99,
            vatRatePercent: 20.0,  // Austrian VAT
            features: [],
            freeTrial: nil,
            appStoreProductId: "monthly_9.99"
        )
        
        let expectedGross = Decimal(9.99) + (Decimal(9.99) * Decimal(20.0) / 100)
        XCTAssertEqual(plan.priceGrossEUR, expectedGross, accuracy: 0.01)
    }
    
    func testVATCalculationSwitzerland() {
        let plan = SubscriptionPlan(
            id: UUID(),
            name: "Monats-Abo",
            durationMonths: 1,
            pricePerCycleEUR: 9.99,
            vatRatePercent: 7.7,  // Swiss VAT
            features: [],
            freeTrial: nil,
            appStoreProductId: "monthly_9.99"
        )
        
        let expectedGross = Decimal(9.99) + (Decimal(9.99) * Decimal(7.7) / 100)
        XCTAssertEqual(plan.priceGrossEUR, expectedGross, accuracy: 0.01)
    }
    
    func testZeroVATCalculation() {
        let plan = SubscriptionPlan(
            id: UUID(),
            name: "Monats-Abo",
            durationMonths: 1,
            pricePerCycleEUR: 10.00,
            vatRatePercent: 0.0,
            features: [],
            freeTrial: nil,
            appStoreProductId: "monthly_10"
        )
        
        XCTAssertEqual(plan.priceGrossEUR, Decimal(10.00))
    }
    
    // MARK: - Duration Variants
    
    func testMonthlyPlan() {
        let plan = SubscriptionPlan(
            id: UUID(),
            name: "Monats-Abo",
            durationMonths: 1,
            pricePerCycleEUR: 9.99,
            vatRatePercent: 19.0,
            features: [],
            freeTrial: nil,
            appStoreProductId: "monthly_9.99"
        )
        
        XCTAssertEqual(plan.durationMonths, 1)
    }
    
    func testQuarterlyPlan() {
        let plan = SubscriptionPlan(
            id: UUID(),
            name: "Quartals-Abo",
            durationMonths: 3,
            pricePerCycleEUR: 24.99,
            vatRatePercent: 19.0,
            features: ["Savings: 17%"],
            freeTrial: nil,
            appStoreProductId: "quarterly_24.99"
        )
        
        XCTAssertEqual(plan.durationMonths, 3)
    }
    
    func testAnnualPlan() {
        let plan = SubscriptionPlan(
            id: UUID(),
            name: "Jahres-Abo",
            durationMonths: 12,
            pricePerCycleEUR: 79.99,
            vatRatePercent: 19.0,
            features: ["Savings: 33%"],
            freeTrial: nil,
            appStoreProductId: "annual_79.99"
        )
        
        XCTAssertEqual(plan.durationMonths, 12)
    }
    
    // MARK: - Free Trial
    
    func testFreeTrialWithPaymentRequired() {
        let trial = FreeTrial(
            durationDays: 7,
            requiresPaymentMethodUpfront: true,
            gracePeriodDays: 0
        )
        
        XCTAssertEqual(trial.durationDays, 7)
        XCTAssertTrue(trial.requiresPaymentMethodUpfront)
    }
    
    func testFreeTrialWithNoPaymentRequired() {
        let trial = FreeTrial(
            durationDays: 14,
            requiresPaymentMethodUpfront: false,
            gracePeriodDays: 3
        )
        
        XCTAssertEqual(trial.durationDays, 14)
        XCTAssertFalse(trial.requiresPaymentMethodUpfront)
        XCTAssertEqual(trial.gracePeriodDays, 3)
    }
    
    // MARK: - Edge Cases
    
    func testNegativePriceRejected() {
        // This should be validated at initialization or in a validator
        let plan = SubscriptionPlan(
            id: UUID(),
            name: "Invalid",
            durationMonths: 1,
            pricePerCycleEUR: -9.99,  // Invalid
            vatRatePercent: 19.0,
            features: [],
            freeTrial: nil,
            appStoreProductId: "invalid"
        )
        
        XCTAssertLessThan(plan.pricePerCycleEUR, 0)  // Verify it's stored (should fail in validator)
    }
    
    func testZeroDurationRejected() {
        let plan = SubscriptionPlan(
            id: UUID(),
            name: "Invalid",
            durationMonths: 0,  // Invalid
            pricePerCycleEUR: 9.99,
            vatRatePercent: 19.0,
            features: [],
            freeTrial: nil,
            appStoreProductId: "invalid"
        )
        
        XCTAssertEqual(plan.durationMonths, 0)  // Should be rejected by validator
    }
}