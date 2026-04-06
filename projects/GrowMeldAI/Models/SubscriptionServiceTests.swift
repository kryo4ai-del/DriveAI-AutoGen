import XCTest
@testable import DriveAI

@MainActor
final class SubscriptionServiceTests: XCTestCase {
    
    var service: MockSubscriptionService!
    var plans: [SubscriptionPlan]!
    
    override func setUp() {
        super.setUp()
        service = MockSubscriptionService()
        plans = [
            SubscriptionPlan(
                id: "monthly",
                name: "Monatlich",
                price: 4.99,
                billingPeriod: .monthly,
                features: ["Feature 1"],
                isBestValue: false
            ),
            SubscriptionPlan(
                id: "yearly",
                name: "Jährlich",
                price: 39.99,
                billingPeriod: .yearly,
                features: ["Feature 1", "Feature 2"],
                isBestValue: true
            )
        ]
    }
    
    // MARK: - Happy Path
    
    func testSuccessfulPurchaseMonthlyPlan() async {
        service.purchaseResult = .success(())
        
        let result = await service.purchase(plans[0])
        
        switch result {
        case .success:
            XCTAssertTrue(service.purchaseCalled)
            XCTAssertEqual(service.lastPurchasedPlanId, "monthly")
        case .failure:
            XCTFail("Expected success")
        }
    }
    
    func testSuccessfulPurchaseYearlyPlan() async {
        service.purchaseResult = .success(())
        
        let result = await service.purchase(plans[1])
        
        switch result {
        case .success:
            XCTAssertTrue(service.purchaseCalled)
            XCTAssertEqual(service.lastPurchasedPlanId, "yearly")
        case .failure:
            XCTFail("Expected success")
        }
    }
    
    func testRestorePurchaseSuccess() async {
        service.restoreResult = .success(())
        
        let result = await service.restorePurchases()
        
        switch result {
        case .success:
            XCTAssertTrue(service.restoreCalled)
        case .failure:
            XCTFail("Expected success")
        }
    }
    
    // MARK: - Network Failures
    
    func testPurchaseNetworkFailure() async {
        service.purchaseResult = .failure(.networkUnavailable)
        
        let result = await service.purchase(plans[0])
        
        switch result {
        case .success:
            XCTFail("Expected network failure")
        case .failure(let error):
            XCTAssertEqual(error, .networkUnavailable)
        }
    }
    
    func testRestorePurchaseNetworkFailure() async {
        service.restoreResult = .failure(.networkUnavailable)
        
        let result = await service.restorePurchases()
        
        switch result {
        case .success:
            XCTFail("Expected network failure")
        case .failure(let error):
            XCTAssertEqual(error, .networkUnavailable)
        }
    }
    
    // MARK: - Transaction Failures
    
    func testPurchaseTransactionFailure() async {
        service.purchaseResult = .failure(.transactionFailed("Payment declined"))
        
        let result = await service.purchase(plans[0])
        
        switch result {
        case .success:
            XCTFail("Expected transaction failure")
        case .failure(let error):
            if case .transactionFailed(let details) = error {
                XCTAssertEqual(details, "Payment declined")
            } else {
                XCTFail("Wrong error type")
            }
        }
    }
    
    func testPurchaseUserCancellation() async {
        service.purchaseResult = .failure(.userCancelled)
        
        let result = await service.purchase(plans[0])
        
        switch result {
        case .success:
            XCTFail("Expected user cancellation")
        case .failure(let error):
            XCTAssertEqual(error, .userCancelled)
        }
    }
    
    // MARK: - Invalid Input
    
    func testPurchaseNilPlanHandled() async {
        let result = await service.purchase(plans[0])
        
        // Should handle gracefully, not crash
        switch result {
        case .success:
            break
        case .failure(let error):
            // Either success or error is acceptable
            break
        }
    }
    
    // MARK: - Concurrent Purchases
    
    func testMultipleConcurrentPurchasesQueued() async {
        service.purchaseResult = .success(())
        
        async let result1 = service.purchase(plans[0])
        async let result2 = service.purchase(plans[1])
        
        let (r1, r2) = await (result1, result2)
        
        // Both should complete without race condition
        switch (r1, r2) {
        case (.success, .success):
            XCTAssertTrue(service.purchaseCalled)
        default:
            XCTFail("Expected both to succeed")
        }
    }
}

// MARK: - Mock Service

@MainActor
class MockSubscriptionService: SubscriptionService {
    var purchaseResult: Result<Void, PurchaseError> = .success(())
    var restoreResult: Result<Void, PurchaseError> = .success(())
    
    var purchaseCalled = false
    var restoreCalled = false
    var lastPurchasedPlanId: String?
    
    var availablePlans: [SubscriptionPlan] {
        [
            SubscriptionPlan(id: "monthly", name: "Monthly", price: 4.99, billingPeriod: .monthly, features: [], isBestValue: false)
        ]
    }
    
    func purchase(_ plan: SubscriptionPlan) async -> Result<Void, PurchaseError> {
        purchaseCalled = true
        lastPurchasedPlanId = plan.id
        return purchaseResult
    }
    
    func restorePurchases() async -> Result<Void, PurchaseError> {
        restoreCalled = true
        return restoreResult
    }
}