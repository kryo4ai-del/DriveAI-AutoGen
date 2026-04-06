import XCTest
@testable import DriveAI

@MainActor
class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var mockDataService: MockLocalDataService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        sut = HomeViewModel(dataService: mockDataService)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        mockDataService = nil
    }
    
    // MARK: - Happy Path Tests
    
    func testLoadSuccessLoadsCategories() async {
        // Arrange
        let mockCategories = [
            Category(id: "1", name: "Verkehrsschilder", questionCount: 50),
            Category(id: "2", name: "Vorfahrtsregeln", questionCount: 40)
        ]
        mockDataService.mockCategories = mockCategories
        
        // Act
        await sut.load()
        
        // Assert
        guard case .loaded(let categories) = sut.state else {
            XCTFail("Expected loaded state")
            return
        }
        XCTAssertEqual(categories.count, 2)
        XCTAssertEqual(categories[0].name, "Verkehrsschilder")
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testLoadingSetsIsLoadingTrue() async {
        // Arrange
        mockDataService.mockCategories = []
        
        // Act & Assert (during load)
        let loadTask = Task {
            await sut.load()
        }
        
        // Small delay to catch mid-load state
        try? await Task.sleep(nanoseconds: 100_000)
        XCTAssertTrue(sut.isLoading)
        
        await loadTask.value
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Exam Date Tests (Fixes BUG-002)
    
    func testExamDateNotSetReturnsNegativeDays() {
        // Arrange: Don't set exam date
        sut.examDate = nil
        
        // Act
        let days = sut.examCountdownDays
        
        // Assert
        XCTAssertEqual(days, -1)
    }
    
    func testExamDateValidReturnsCorrectCountdown() {
        // Arrange
        let calendar = Calendar.current
        let today = Date()
        let examDate = calendar.date(byAdding: .day, value: 10, to: today)!
        sut.examDate = examDate
        
        // Act
        let days = sut.examCountdownDays
        
        // Assert
        XCTAssert(abs(days - 10) <= 1, "Expected ~10 days, got \(days)")
    }
    
    func testExamReadinessStatusReturnsCorrectMessage() {
        // Arrange: Test each readiness bracket
        let testCases: [(dayOffset: Int, expectedSubstring: String)] = [
            (0, "Finale Woche"),
            (5, "Finale Woche"),
            (10, "Stark vorbereitet"),
            (20, "Gute Vorbereitung"),
            (45, "Zeit zum Lernen")
        ]
        
        for (dayOffset, expectedSubstring) in testCases {
            // Arrange
            let calendar = Calendar.current
            let examDate = calendar.date(byAdding: .day, value: dayOffset, to: Date())!
            sut.examDate = examDate
            
            // Act
            let status = sut.examReadinessStatus
            
            // Assert
            XCTAssert(
                status.contains(expectedSubstring),
                "For \(dayOffset) days: expected '\(expectedSubstring)', got '\(status)'"
            )
        }
    }
    
    func testExamReadinessStatusWhenDateNotSetReturnsDefault() {
        // Arrange
        sut.examDate = nil
        
        // Act
        let status = sut.examReadinessStatus
        
        // Assert
        XCTAssertEqual(status, "📅 Prüfungsdatum nicht gesetzt")
    }
    
    func testSetExamDatePersistsToUserDefaults() {
        // Arrange
        let testDate = Date(timeIntervalSince1970: 1000000)
        
        // Act
        sut.setExamDate(testDate)
        
        // Assert
        let savedTimestamp = UserDefaults.standard.double(forKey: "examDateTimestamp")
        XCTAssertEqual(savedTimestamp, testDate.timeIntervalSince1970)
    }
    
    // MARK: - Error Handling Tests
    
    func testLoadFailureWithDataServiceErrorSetsError() async {
        // Arrange
        mockDataService.shouldFail = true
        mockDataService.mockError = .corruptedDatabase("DB corrupted")
        
        // Act
        await sut.load()
        
        // Assert
        XCTAssertNotNil(sut.error)
        if case .dataServiceError(let srvError) = sut.error,
           case .corruptedDatabase = srvError {
            // ✅ Pass
        } else {
            XCTFail("Expected dataServiceError with corruptedDatabase")
        }
    }
    
    func testLoadErrorSetsStateToError() async {
        // Arrange
        mockDataService.shouldFail = true
        mockDataService.mockError = .categoryNotFound(id: "1")
        
        // Act
        await sut.load()
        
        // Assert
        guard case .error = sut.state else {
            XCTFail("Expected error state")
            return
        }
    }
    
    func testClearErrorResetsErrorState() async {
        // Arrange
        mockDataService.shouldFail = true
        mockDataService.mockError = .corruptedDatabase("DB error")
        await sut.load()
        XCTAssertNotNil(sut.error)
        
        // Act
        sut.clearError()
        
        // Assert
        XCTAssertNil(sut.error)
    }
    
    // MARK: - Edge Cases
    
    func testLoadWithEmptyCategoriesList() async {
        // Arrange
        mockDataService.mockCategories = []
        
        // Act
        await sut.load()
        
        // Assert
        guard case .loaded(let categories) = sut.state else {
            XCTFail("Should load even with empty list")
            return
        }
        XCTAssertEqual(categories.count, 0)
    }
    
    func testAccessibilityExamStatusFormattedCorrectly() {
        // Arrange
        let calendar = Calendar.current
        let examDate = calendar.date(byAdding: .day, value: 5, to: Date())!
        sut.examDate = examDate
        
        // Act
        let status = sut.accessibilityExamStatus
        
        // Assert
        XCTAssert(status.contains("5"))
        XCTAssert(status.contains("Tage"))
    }
}