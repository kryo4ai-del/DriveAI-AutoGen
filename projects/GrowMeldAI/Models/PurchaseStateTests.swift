import XCTest
@testable import DriveAI

final class PurchaseStateTests: XCTestCase {
    
    // MARK: - State Transitions
    
    func testStateTransitionIdleToLoading() {
        let idle: PurchaseState = .idle
        let loading: PurchaseState = .loading(productId: "com.driveai.purchase.unlimited_exams")
        
        XCTAssertFalse(idle.isLoading)
        XCTAssertTrue(loading.isLoading)
    }
    
    func testStateTransitionLoadingToSuccess() {
        let loading: PurchaseState = .loading(productId: "prod-123")
        let success: PurchaseState = .success(feature: .unlimitedExams, transactionId: "txn-456")
        
        XCTAssertTrue(loading.isLoading)
        XCTAssertFalse(success.isLoading)
    }
    
    func testStateTransitionLoadingToError() {
        let loading: PurchaseState = .loading(productId: "prod-123")
        let error: PurchaseState = .error(.networkError)
        
        XCTAssertTrue(loading.isLoading)
        XCTAssertFalse(error.isLoading)
        XCTAssertNotNil(error.currentError)
    }
    
    // MARK: - Error State
    
    func testErrorStateExtractsError() {
        let purchaseError = PurchaseError.networkError
        let state: PurchaseState = .error(purchaseError)
        
        XCTAssertEqual(state.currentError, purchaseError)
    }
    
    func testNonErrorStateReturnsNilError() {
        let successState: PurchaseState = .success(feature: .unlimitedExams, transactionId: "123")
        XCTAssertNil(successState.currentError)
    }
    
    // MARK: - Loading States
    
    func testAllLoadingStatesConcertToIsLoadingTrue() {
        let loadingStates: [PurchaseState] = [
            .loading(productId: "123"),
            .restoring,
            .purchaseInitiated(productId: "456")
        ]
        
        for state in loadingStates {
            XCTAssertTrue(state.isLoading, "State \(state) should be loading")
        }
    }
    
    func testNonLoadingStatesReturnFalse() {
        let nonLoadingStates: [PurchaseState] = [
            .idle,
            .success(feature: .unlimitedExams, transactionId: "123"),
            .error(.networkError),
            .completed
        ]
        
        for state in nonLoadingStates {
            XCTAssertFalse(state.isLoading, "State \(state) should not be loading")
        }
    }
    
    // MARK: - Product ID Extraction
    
    func testProductIdExtractionFromLoadingState() {
        let state: PurchaseState = .loading(productId: "prod-unlimited")
        XCTAssertEqual(state.currentProductId, "prod-unlimited")
    }
    
    func testProductIdExtractionFromPurchaseInitiatedState() {
        let state: PurchaseState = .purchaseInitiated(productId: "prod-analytics")
        XCTAssertEqual(state.currentProductId, "prod-analytics")
    }
    
    func testProductIdReturnNilForOtherStates() {
        XCTAssertNil(PurchaseState.idle.currentProductId)
        XCTAssertNil(PurchaseState.restoring.currentProductId)
        XCTAssertNil(PurchaseState.completed.currentProductId)
    }
    
    // MARK: - Equatable Conformance
    
    func testEquatableComparison() {
        let state1: PurchaseState = .loading(productId: "123")
        let state2: PurchaseState = .loading(productId: "123")
        let state3: PurchaseState = .loading(productId: "456")
        
        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)
    }
}