// Features/Subscription/Tests/BillingCycleTests.swift

import XCTest
@testable import DriveAI

final class BillingCycleTests: XCTestCase {
    
    // MARK: - Renewal Date Calculation
    
    func testDaysPendingRenewalPositive() {
        let now = Date()
        let renewalDate = Calendar.current.date(byAdding: .day, value: 5, to: now)!
        
        let cycle = BillingCycle(
            id: UUID(),
            subscriptionId: UUID(),
            cycleNumber: 1,
            startDate: now,
            renewalDate: renewalDate,
            status: .pending,
            amountChargedEUR: 9.99,
            vatAmountEUR: 1.89,
            currencyCode: "EUR",
            paymentMethodId: nil,
            receiptUrl: nil,
            failureCount: 0,
            lastFailureReason: nil
        )
        
        XCTAssertEqual(cycle.daysPendingRenewal, 5)
    }
    
    func testDaysPendingRenewalZero() {
        let now = Date()
        let cycle = BillingCycle(
            id: UUID(),
            subscriptionId: UUID(),
            cycleNumber: 1,
            startDate: now,
            renewalDate: now,  // Same date
            status: .pending,
            amountChargedEUR: 9.99,
            vatAmountEUR: 1.89,
            currencyCode: "EUR",
            paymentMethodId: nil,
            receiptUrl: nil,
            failureCount: 0,
            lastFailureReason: nil
        )
        
        XCTAssertEqual(cycle.daysPendingRenewal, 0)
    }
    
    func testDaysPendingRenewalPassed() {
        let now = Date()
        let renewalDate = Calendar.current.date(byAdding: .day, value: -3, to: now)!
        
        let cycle = BillingCycle(
            id: UUID(),
            subscriptionId: UUID(),
            cycleNumber: 1,
            startDate: renewalDate,
            renewalDate: renewalDate,
            status: .chargeAttempted,  // Overdue
            amountChargedEUR: 9.99,
            vatAmountEUR: 1.89,
            currencyCode: "EUR",
            paymentMethodId: nil,
            receiptUrl: nil,
            failureCount: 1,
            lastFailureReason: nil
        )
        
        XCTAssertLessThan(cycle.daysPendingRenewal, 0)
    }
    
    // MARK: - Upcoming Renewal Detection
    
    func testIsUpcomingRenewalWithin7Days() {
        let now = Date()
        let renewalDate = Calendar.current.date(byAdding: .day, value: 5, to: now)!
        
        let cycle = BillingCycle(
            id: UUID(),
            subscriptionId: UUID(),
            cycleNumber: 1,
            startDate: now,
            renewalDate: renewalDate,
            status: .pending,
            amountChargedEUR: 9.99,
            vatAmountEUR: 1.89,
            currencyCode: "EUR",
            paymentMethodId: nil,
            receiptUrl: nil,
            failureCount: 0,
            lastFailureReason: nil
        )
        
        XCTAssertTrue(cycle.isUpcomingRenewal)
    }
    
    func testIsUpcomingRenewalExactly7Days() {
        let now = Date()
        let renewalDate = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        
        let cycle = BillingCycle(
            id: UUID(),
            subscriptionId: UUID(),
            cycleNumber: 1,
            startDate: now,
            renewalDate: renewalDate,
            status: .pending,
            amountChargedEUR: 9.99,
            vatAmountEUR: 1.89,
            currencyCode: "EUR",
            paymentMethodId: nil,
            receiptUrl: nil,
            failureCount: 0,
            lastFailureReason: nil
        )
        
        XCTAssertTrue(cycle.isUpcomingRenewal)
    }
    
    func testIsUpcomingRenewalBeyond7Days() {
        let now = Date()
        let renewalDate = Calendar.current.date(byAdding: .day, value: 10, to: now)!
        
        let cycle = BillingCycle(
            id: UUID(),
            subscriptionId: UUID(),
            cycleNumber: 1,
            startDate: now,
            renewalDate: renewalDate,
            status: .pending,
            amountChargedEUR: 9.99,
            vatAmountEUR: 1.89,
            currencyCode: "EUR",
            paymentMethodId: nil,
            receiptUrl: nil,
            failureCount: 0,
            lastFailureReason: nil
        )
        
        XCTAssertFalse(cycle.isUpcomingRenewal)
    }
    
    func testIsUpcomingRenewalNotPendingStatus() {
        let now = Date()
        let renewalDate = Calendar.current.date(byAdding: .day, value: 5, to: now)!
        
        let cycle = BillingCycle(
            id: UUID(),
            subscriptionId: UUID(),
            cycleNumber: 1,
            startDate: now,
            renewalDate: renewalDate,
            status: .charged,  // Already charged
            amountChargedEUR: 9.99,
            vatAmountEUR: 1.89,
            currencyCode: "EUR",
            paymentMethodId: nil,
            receiptUrl: nil,
            failureCount: 0,
            lastFailureReason: nil
        )
        
        XCTAssertFalse(cycle.isUpcomingRenewal)
    }
    
    // MARK: - Failure Tracking
    
    func testFailureCountIncrement() {
        var cycle = BillingCycle(
            id: UUID(),
            subscriptionId: UUID(),
            cycleNumber: 1,
            startDate: Date(),
            renewalDate: Date(),
            status: .chargeFailed,
            amountChargedEUR: 9.99,
            vatAmountEUR: 1.89,
            currencyCode: "EUR",
            paymentMethodId: nil,
            receiptUrl: nil,
            failureCount: 0,
            lastFailureReason: nil
        )
        
        // Simulate first failure
        cycle.failureCount += 1
        cycle.lastFailureReason = "Card declined"
        
        XCTAssertEqual(cycle.failureCount, 1)
        XCTAssertEqual(cycle.lastFailureReason, "Card declined")
    }
    
    func testMaxFailureCountBeforeSuspension() {
        let maxRetries = 3
        var cycle = BillingCycle(
            id: UUID(),
            subscriptionId: UUID(),
            cycleNumber: 1,
            startDate: Date(),
            renewalDate: Date(),
            status: .chargeFailed,
            amountChargedEUR: 9.99,
            vatAmountEUR: 1.89,
            currencyCode: "EUR",
            paymentMethodId: nil,
            receiptUrl: nil,
            failureCount: maxRetries,
            lastFailureReason: "Card declined"
        )
        
        XCTAssertEqual(cycle.failureCount, maxRetries)
        // Should trigger suspension
    }
}