@MainActor
final class ComplianceViewModelTests: XCTestCase {
    var sut: ComplianceViewModel!
    var mockDataService: MockComplianceDataService!
    
    override func setUp() {
        mockDataService = MockComplianceDataService()
        sut = ComplianceViewModel(dataService: mockDataService)
    }
    
    func testUpdateConsentPersistsSetting() async {
        // When
        sut.updateConsent(.examResultsStorage, enabled: false)
        
        // Then
        XCTAssertFalse(sut.storeExamResults)
        XCTAssertTrue(mockDataService.lastSavedSettings.storeExamResults == false)
    }
    
    func testExportDataShowsSuccessCard() async {
        // Given
        mockDataService.mockExportURL = URL(fileURLWithPath: "/tmp/export.json")
        
        // When
        await sut.exportData()
        
        // Then
        XCTAssertTrue(sut.showExportSuccess)
        XCTAssertNotNil(sut.lastExportDate)
    }
    
    func testMultipleExportCallsAreIgnored() async {
        // When
        _ = [1, 2, 3].map { _ in Task { await sut.exportData() } }
        
        // Then
        XCTAssertEqual(mockDataService.exportCallCount, 1)
    }
}