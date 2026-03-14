// Tests/ExamReadiness/ReadinessCalculationServiceTests.swift
class ReadinessCalculationServiceTests: XCTestCase {
    var sut: ReadinessCalculationService!
    var mockDataService: MockLocalDataService!
    
    override func setUp() {
        mockDataService = MockLocalDataService()
        sut = ReadinessCalculationService(dataService: mockDataService)
    }
    
    func test_calculateCategoryReadiness_returnsCorrectPercentage() {
        // Arrange
        mockDataService.userAnswers = [
            Answer(isCorrect: true),
            Answer(isCorrect: true),
            Answer(isCorrect: false),
            Answer(isCorrect: false),
        ]
        
        // Act
        let result = sut.calculateCategoryReadiness(categoryId: "signs")
        
        // Assert
        XCTAssertEqual(result.percentage, 50)
        XCTAssertEqual(result.level, .intermediate)
    }
    
    func test_generateFullReport_calculatesOverallScoreAsAverage() {
        // Arrange: 3 categories with 60%, 80%, 100% readiness
        // Act
        let report = sut.generateFullReport()
        // Assert: average = 80%
        XCTAssertEqual(report.overallScore, 80)
    }
}