import XCTest
@testable import DriveAI

final class MaintenanceItemTests: XCTestCase {
    
    // MARK: - Next Recommended Date Calculation
    
    func testNextRecommendedDate_NeverPracticed_ReturnsToday() {
        // Given: Category with no practice history
        let item = MaintenanceItem(
            id: "traffic-signs",
            categoryId: "traffic-signs",
            categoryName: "Verkehrszeichen",
            lastPracticeDate: nil,
            quizAccuracy: 0.0,
            totalQuestionsAnswered: 0,
            correctAnswers: 0
        )
        
        // When: Computing nextRecommendedDate
        let nextDate = item.nextRecommendedDate
        
        // Then: Should be today (startOfDay)
        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertEqual(nextDate, today)
    }
    
    func testNextRecommendedDate_HighAccuracy_7DaysOut() {
        // Given: 95% accuracy
        let lastPractice = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let item = MaintenanceItem(
            id: "right-of-way",
            categoryId: "right-of-way",
            categoryName: "Vorfahrtsregeln",
            lastPracticeDate: lastPractice,
            quizAccuracy: 0.95,
            totalQuestionsAnswered: 20,
            correctAnswers: 19
        )
        
        // When: Computing nextRecommendedDate
        let nextDate = item.nextRecommendedDate
        
        // Then: Should be 7 days from last practice
        let expected = Calendar.current.date(byAdding: .day, value: 7, to: lastPractice)!
        let expectedStartOfDay = Calendar.current.startOfDay(for: expected)
        XCTAssertEqual(nextDate, expectedStartOfDay)
    }
    
    func testNextRecommendedDate_MediumAccuracy_3DaysOut() {
        // Given: 80% accuracy
        let lastPractice = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let item = MaintenanceItem(
            id: "signs",
            categoryId: "signs",
            categoryName: "Zeichen",
            lastPracticeDate: lastPractice,
            quizAccuracy: 0.80,
            totalQuestionsAnswered: 10,
            correctAnswers: 8
        )
        
        // When: Computing nextRecommendedDate
        let nextDate = item.nextRecommendedDate
        
        // Then: Should be 3 days from last practice
        let expected = Calendar.current.date(byAdding: .day, value: 3, to: lastPractice)!
        let expectedStartOfDay = Calendar.current.startOfDay(for: expected)
        XCTAssertEqual(nextDate, expectedStartOfDay)
    }
    
    func testNextRecommendedDate_LowAccuracy_Tomorrow() {
        // Given: 65% accuracy
        let lastPractice = Date()
        let item = MaintenanceItem(
            id: "fines",
            categoryId: "fines",
            categoryName: "Bußgelder",
            lastPracticeDate: lastPractice,
            quizAccuracy: 0.65,
            totalQuestionsAnswered: 10,
            correctAnswers: 7
        )
        
        // When: Computing nextRecommendedDate
        let nextDate = item.nextRecommendedDate
        
        // Then: Should be tomorrow
        let expected = Calendar.current.date(byAdding: .day, value: 1, to: lastPractice)!
        let expectedStartOfDay = Calendar.current.startOfDay(for: expected)
        XCTAssertEqual(nextDate, expectedStartOfDay)
    }
    
    func testNextRecommendedDate_VeryLowAccuracy_Today() {
        // Given: 50% accuracy
        let lastPractice = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let item = MaintenanceItem(
            id: "equipment",
            categoryId: "equipment",
            categoryName: "Ausrüstung",
            lastPracticeDate: lastPractice,
            quizAccuracy: 0.50,
            totalQuestionsAnswered: 10,
            correctAnswers: 5
        )
        
        // When: Computing nextRecommendedDate
        let nextDate = item.nextRecommendedDate
        
        // Then: Should be today (no delay)
        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertEqual(nextDate, today)
    }
    
    // MARK: - Status Calculation
    
    func testStatus_LessThan1DayOverdue_Active() {
        // Given: Last practiced 6 hours ago with 92% accuracy
        let lastPractice = Calendar.current.date(byAdding: .hour, value: -6, to: Date())!
        let item = MaintenanceItem(
            id: "test",
            categoryId: "test",
            categoryName: "Test",
            lastPracticeDate: lastPractice,
            quizAccuracy: 0.92,
            totalQuestionsAnswered: 25,
            correctAnswers: 23
        )
        
        // When: Computing status
        let status = item.status
        
        // Then: Should be active
        XCTAssertEqual(status, .active)
    }
    
    func testStatus_1to3DaysOverdue_NeedsMaintenance() {
        // Given: Last practiced 2 days ago with 70% accuracy
        let lastPractice = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let item = MaintenanceItem(
            id: "test",
            categoryId: "test",
            categoryName: "Test",
            lastPracticeDate: lastPractice,
            quizAccuracy: 0.70,
            totalQuestionsAnswered: 10,
            correctAnswers: 7
        )
        
        // When: Computing status
        let status = item.status
        
        // Then: Should be needsMaintenance
        XCTAssertEqual(status, .needsMaintenance)
    }
    
    func testStatus_MoreThan3DaysOverdue_Dormant() {
        // Given: Last practiced 5 days ago
        let lastPractice = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let item = MaintenanceItem(
            id: "test",
            categoryId: "test",
            categoryName: "Test",
            lastPracticeDate: lastPractice,
            quizAccuracy: 0.75,
            totalQuestionsAnswered: 10,
            correctAnswers: 8
        )
        
        // When: Computing status
        let status = item.status
        
        // Then: Should be dormant
        XCTAssertEqual(status, .dormant)
    }
    
    func testStatus_NeverPracticed_Dormant() {
        // Given: Category with no practice history
        let item = MaintenanceItem(
            id: "test",
            categoryId: "test",
            categoryName: "Test",
            lastPracticeDate: nil,
            quizAccuracy: 0.0,
            totalQuestionsAnswered: 0,
            correctAnswers: 0
        )
        
        // When: Computing status
        let status = item.status
        
        // Then: Should be dormant
        XCTAssertEqual(status, .dormant)
    }
    
    // MARK: - Days Since Last Practice
    
    func testDaysSinceLastPractice_DifferentDays_CalculatesCorrectly() {
        // Given: Various dates
        let testCases: [(daysAgo: Int, expected: Int)] = [
            (0, 0),    // Today
            (1, 1),    // Yesterday
            (7, 7),    // 1 week ago
            (30, 30),  // 1 month ago
        ]
        
        for (daysAgo, expected) in testCases {
            let lastPractice = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
            let item = MaintenanceItem(
                id: "test-\(daysAgo)",
                categoryId: "test",
                categoryName: "Test",
                lastPracticeDate: lastPractice,
                quizAccuracy: 0.8,
                totalQuestionsAnswered: 10,
                correctAnswers: 8
            )
            
            // When: Computing days
            let actual = item.daysSinceLastPractice
            
            // Then: Should match expected (allowing for midnight boundary)
            XCTAssertEqual(actual, expected, "Failed for \(daysAgo) days ago")
        }
    }
    
    func testDaysSinceLastPractice_NeverPracticed_ReturnsMax() {
        // Given: No practice history
        let item = MaintenanceItem(
            id: "test",
            categoryId: "test",
            categoryName: "Test",
            lastPracticeDate: nil,
            quizAccuracy: 0.0,
            totalQuestionsAnswered: 0,
            correctAnswers: 0
        )
        
        // When: Computing days
        let days = item.daysSinceLastPractice
        
        // Then: Should return Int.max
        XCTAssertEqual(days, Int.max)
    }
    
    // MARK: - Accuracy Percentage
    
    func testAccuracy_FormatsAsInteger() {
        // Given: Quiz accuracy of 0.826 (82.6%)
        let item = MaintenanceItem(
            id: "test",
            categoryId: "test",
            categoryName: "Test",
            lastPracticeDate: Date(),
            quizAccuracy: 0.826,
            totalQuestionsAnswered: 20,
            correctAnswers: 17
        )
        
        // When: Computing accuracy percentage
        let percent = item.accuracy
        
        // Then: Should be 82 (rounded down)
        XCTAssertEqual(percent, 82)
    }
    
    func testAccuracy_NoQuestionsAnswered_ReturnsZero() {
        // Given: No questions answered
        let item = MaintenanceItem(
            id: "test",
            categoryId: "test",
            categoryName: "Test",
            lastPracticeDate: nil,
            quizAccuracy: 0.0,
            totalQuestionsAnswered: 0,
            correctAnswers: 0
        )
        
        // When: Computing accuracy
        let percent = item.accuracy
        
        // Then: Should be 0
        XCTAssertEqual(percent, 0)
    }
}