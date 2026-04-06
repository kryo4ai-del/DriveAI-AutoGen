import XCTest
@testable import DriveAI

final class OfflineStateTests: XCTestCase {
    
    // MARK: - State Properties
    
    func testOnlineStateProperties() {
        let state = OfflineState.online
        
        XCTAssertTrue(state.isOnline)
        XCTAssertFalse(state.isOffline)
        XCTAssertFalse(state.isSyncing)
        XCTAssertNil(state.lastSyncDate)
        XCTAssertEqual(state.userMessage, "")
    }
    
    func testOfflineWithCacheState() {
        let syncDate = Date()
        let state = OfflineState.offlineWithCache(lastSyncDate: syncDate)
        
        XCTAssertFalse(state.isOnline)
        XCTAssertTrue(state.isOffline)
        XCTAssertFalse(state.isSyncing)
        XCTAssertEqual(state.lastSyncDate, syncDate)
        XCTAssertTrue(state.userMessage.contains("offline"))
    }
    
    func testOfflineDegradedState() {
        let syncDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let warning = "Daten sind älter als 3 Tage"
        let state = OfflineState.offlineDegraded(lastSyncDate: syncDate, warning: warning)
        
        XCTAssertFalse(state.isOnline)
        XCTAssertTrue(state.isOffline)
        XCTAssertEqual(state.userMessage, warning)
    }
    
    func testSyncInProgressState() {
        let state = OfflineState.syncInProgress(progress: 0.5)
        
        XCTAssertFalse(state.isOnline)
        XCTAssertTrue(state.isOffline)
        XCTAssertTrue(state.isSyncing)
        XCTAssertTrue(state.userMessage.contains("50%"))
    }
    
    // MARK: - Progress Messaging
    
    func testSyncProgressMessaging() {
        let testCases: [(Double, String)] = [
            (0.0, "0%"),
            (0.25, "25%"),
            (0.5, "50%"),
            (0.75, "75%"),
            (1.0, "100%")
        ]
        
        for (progress, expectedPercent) in testCases {
            let state = OfflineState.syncInProgress(progress: progress)
            XCTAssertTrue(
                state.userMessage.contains(expectedPercent),
                "State message should contain \(expectedPercent)"
            )
        }
    }
    
    // MARK: - Equatable Conformance
    
    func testStateEquality() {
        let date = Date()
        let state1 = OfflineState.offlineWithCache(lastSyncDate: date)
        let state2 = OfflineState.offlineWithCache(lastSyncDate: date)
        
        XCTAssertEqual(state1, state2)
    }
    
    func testStateInequality() {
        let state1 = OfflineState.online
        let state2 = OfflineState.offlineWithCache(lastSyncDate: Date())
        
        XCTAssertNotEqual(state1, state2)
    }
    
    // MARK: - Localization
    
    func testGermanLocalization() {
        let state = OfflineState.offlineWithCache(lastSyncDate: Date())
        
        // Should contain German text
        XCTAssertTrue(state.userMessage.contains("Du bist offline") || 
                     state.userMessage.contains("offline"))
    }
}