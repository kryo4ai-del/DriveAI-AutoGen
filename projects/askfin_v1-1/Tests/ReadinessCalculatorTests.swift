// Tests/ExamReadiness/ReadinessCalculatorTests.swift
@MainActor
final class ReadinessCalculatorTests: XCTestCase {
    var calculator: ReadinessCalculator!
    var mockDataService: MockDataService!
    var mockExamDateManager: MockExamDateManager!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockDataService()
        mockExamDateManager = MockExamDateManager()
        calculator = ReadinessCalculator(
            dataService: mockDataService,
            examDateManager: mockExamDateManager
        )
    }
    
    func testWeakAreaIdentification() async {
        // Given
        let scores = ["Math": 45.0, "Science": 75.0, "History": 50.0]
        
        // When
        let weakAreas = calculator.identifyWeakAreas(from: scores)
        
        // Then
        XCTAssertEqual(weakAreas.count, 2)
        XCTAssertEqual(weakAreas[0].priority, .critical)
    }
}