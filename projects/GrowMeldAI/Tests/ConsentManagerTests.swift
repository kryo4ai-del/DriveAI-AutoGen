import XCTest
@testable import DriveAI

@MainActor
final class ConsentManagerTests: XCTestCase {
    var sut: ConsentManager!
    var mockStorage: MockConsentStorage!
    var mockUIProvider: MockConsentUIProvider!
    
    override func setUp() {
        super.setUp()
        mockStorage = MockConsentStorage()
        mockUIProvider = MockConsentUIProvider()
        sut = ConsentManager(storage: mockStorage, uiProvider: mockUIProvider)
    }
    
    // MARK: - Happy Path Tests
    
    func test_requestConsent_UserGrants_UpdatesStateAndPersists() async {
        // Arrange
        mockUIProvider.shouldGrantConsent = true
        
        // Act
        let granted = await sut.requestConsent()
        
        // Assert
        XCTAssertTrue(granted)
        XCTAssertTrue(sut.hasUserConsent)
        XCTAssertEqual(sut.consentStatus, .granted)
        XCTAssertTrue(mockStorage.saveWasCalled)
        XCTAssertEqual(mockStorage.savedStatus, .granted)
    }
    
    func test_requestConsent_UserDenies_UpdatesStateAndPersists() async {
        // Arrange
        mockUIProvider.shouldGrantConsent = false
        
        // Act
        let granted = await sut.requestConsent()
        
        // Assert
        XCTAssertFalse(granted)
        XCTAssertFalse(sut.hasUserConsent)
        XCTAssertEqual(sut.consentStatus, .denied)
        XCTAssertTrue(mockStorage.saveWasCalled)
        XCTAssertEqual(mockStorage.savedStatus, .denied)
    }
    
    func test_requestConsent_AlreadyGranted_SkipsUIAndReturnsTrue() async {
        // Arrange
        mockStorage.persistedStatus = .granted
        let managerWithPersistedState = ConsentManager(
            storage: mockStorage,
            uiProvider: mockUIProvider
        )
        
        // Act
        let granted = await managerWithPersistedState.requestConsent()
        
        // Assert
        XCTAssertTrue(granted)
        XCTAssertFalse(mockUIProvider.presentWasCalled)
        XCTAssertFalse(mockStorage.saveWasCalled)
    }
    
    func test_requestConsent_AlreadyDenied_SkipsUIAndReturnsFalse() async {
        // Arrange
        mockStorage.persistedStatus = .denied
        let managerWithPersistedState = ConsentManager(
            storage: mockStorage,
            uiProvider: mockUIProvider
        )
        
        // Act
        let granted = await managerWithPersistedState.requestConsent()
        
        // Assert
        XCTAssertFalse(granted)
        XCTAssertFalse(mockUIProvider.presentWasCalled)
    }
    
    // MARK: - State Transition Tests
    
    func test_revokeConsent_ClearsStateAndStorage() async {
        // Arrange
        mockUIProvider.shouldGrantConsent = true
        _ = await sut.requestConsent()
        XCTAssertTrue(sut.hasUserConsent)
        
        // Act
        await sut.revokeConsent()
        
        // Assert
        XCTAssertFalse(sut.hasUserConsent)
        XCTAssertEqual(sut.consentStatus, .denied)
        XCTAssertTrue(mockStorage.clearWasCalled)
    }
    
    func test_consentStatusPublisher_EmitsOnStateChange() async {
        // Arrange
        var receivedStatuses: [ConsentStatus] = []
        let subscription = sut.consentStatusPublisher.sink { status in
            receivedStatuses.append(status)
        }
        
        mockUIProvider.shouldGrantConsent = true
        
        // Act
        _ = await sut.requestConsent()
        
        // Assert
        XCTAssertEqual(receivedStatuses, [.granted])
        subscription.cancel()
    }
    
    func test_concurrentConsentRequests_OnlyOneUiPresented() async {
        // Arrange
        mockUIProvider.shouldGrantConsent = true
        mockUIProvider.delayMillis = 100 // Simulate user delay
        
        // Act
        let results = await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<3 {
                group.addTask { await self.sut.requestConsent() }
            }
            var results: [Bool] = []
            for await result in group {
                results.append(result)
            }
            return results
        }
        
        // Assert (first call shows UI, others skip)
        XCTAssertEqual(results, [true, true, true]) // All see granted state
        XCTAssertEqual(mockUIProvider.presentCallCount, 1) // But UI shown once
    }
    
    // MARK: - Storage Failure Tests
    
    func test_requestConsent_StorageSaveFailure_StillUpdatesState() async {
        // Arrange
        mockUIProvider.shouldGrantConsent = true
        mockStorage.shouldFailSave = true
        
        // Act
        let granted = await sut.requestConsent()
        
        // Assert
        XCTAssertTrue(granted) // Still succeeds for user
        XCTAssertTrue(sut.hasUserConsent) // State updated in memory
        XCTAssertTrue(mockStorage.saveWasCalled)
    }
    
    func test_revokeConsent_StorageClearFailure_StillClearsMemoryState() async {
        // Arrange
        mockUIProvider.shouldGrantConsent = true
        _ = await sut.requestConsent()
        
        mockStorage.shouldFailClear = true
        
        // Act
        await sut.revokeConsent()
        
        // Assert
        XCTAssertFalse(sut.hasUserConsent) // Still cleared in memory
        XCTAssertTrue(mockStorage.clearWasCalled)
    }
    
    // MARK: - Edge Cases
    
    func test_init_LoadsPersistedConsentOnInitialization() {
        // Arrange
        mockStorage.persistedStatus = .granted
        
        // Act
        let manager = ConsentManager(storage: mockStorage, uiProvider: mockUIProvider)
        
        // Assert
        XCTAssertEqual(manager.consentStatus, .granted)
        XCTAssertTrue(manager.hasUserConsent)
    }
    
    func test_init_DefaultsToUndeterminedIfNoPersistedState() {
        // Arrange
        mockStorage.persistedStatus = .undetermined
        
        // Act
        let manager = ConsentManager(storage: mockStorage, uiProvider: mockUIProvider)
        
        // Assert
        XCTAssertEqual(manager.consentStatus, .undetermined)
        XCTAssertFalse(manager.hasUserConsent)
    }
    
    func test_uiProviderCancelled_DeniesConsent() async {
        // Arrange
        mockUIProvider.shouldGrantConsent = false
        
        // Act
        let granted = await sut.requestConsent()
        
        // Assert
        XCTAssertFalse(granted)
        XCTAssertEqual(sut.consentStatus, .denied)
    }
}

// MARK: - Mocks

class MockConsentStorage: ConsentStorageProtocol {
    var persistedStatus: ConsentStatus = .undetermined
    var savedStatus: ConsentStatus?
    var saveWasCalled = false
    var clearWasCalled = false
    var shouldFailSave = false
    var shouldFailClear = false
    
    func load() -> ConsentStatus {
        persistedStatus
    }
    
    func save(_ status: ConsentStatus) -> Result<Void, ConsentStorageError> {
        saveWasCalled = true
        savedStatus = status
        return shouldFailSave ? .failure(.keychainUnavailable(.unknown(1))) : .success(())
    }
    
    func clear() -> Result<Void, ConsentStorageError> {
        clearWasCalled = true
        return shouldFailClear ? .failure(.keychainUnavailable(.unknown(1))) : .success(())
    }
}

@MainActor
class MockConsentUIProvider: ConsentUIProvider {
    var shouldGrantConsent = true
    var presentWasCalled = false
    var presentCallCount = 0
    var delayMillis: UInt64 = 0
    
    func presentConsentUI() async -> Bool {
        presentWasCalled = true
        presentCallCount += 1
        
        if delayMillis > 0 {
            try? await Task.sleep(nanoseconds: delayMillis * 1_000_000)
        }
        
        return shouldGrantConsent
    }
}