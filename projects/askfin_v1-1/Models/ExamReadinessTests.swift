import XCTest
@testable import DriveAI

final class ExamReadinessTests: XCTestCase {
    
    // MARK: - Score Calculation Tests
    
    func testReadinessScoreCalculation_ValidInput() throws {
        // Arrange: 50% category strength + 50% time factor
        let categories = [
            makeCategory(completionPercentage: 80),
            makeCategory(completionPercentage: 60) // Avg: 70%
        ]
        let examDate = Calendar.current.date(byAdding: .day, value: 45, to: Date())!
        
        // Act
        let readiness = try ExamReadiness(
            examDate: examDate,
            readinessScore: calculateScore(categories: categories, examDate: examDate),
            categories: categories
        )
        
        // Assert
        let avgCompletion = 70 // (80 + 60) / 2
        let timeFactor = (45 * 100) / 90 // ~50
        let expectedScore = Int((Double(avgCompletion) * 0.5) + (Double(timeFactor) * 0.5))
        
        XCTAssertEqual(readiness.readinessScore, expectedScore)
        XCTAssertGreaterThanOrEqual(readiness.readinessScore, 0)
        XCTAssertLessThanOrEqual(readiness.readinessScore, 100)
    }
    
    func testReadinessScoreCalculation_ClampsTo100() throws {
        // Arrange: All categories 100%, exam in 100+ days
        let categories = [
            makeCategory(completionPercentage: 100),
            makeCategory(completionPercentage: 100)
        ]
        let examDate = Calendar.current.date(byAdding: .day, value: 120, to: Date())!
        
        // Act
        let readiness = try ExamReadiness(
            examDate: examDate,
            readinessScore: calculateScore(categories: categories, examDate: examDate),
            categories: categories
        )
        
        // Assert
        XCTAssertLessThanOrEqual(readiness.readinessScore, 100)
    }
    
    func testReadinessScoreCalculation_MinimumZero() throws {
        // Arrange: 0% categories, exam in 1 day
        let categories = [
            makeCategory(completionPercentage: 0),
            makeCategory(completionPercentage: 0)
        ]
        let examDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        // Act
        let readiness = try ExamReadiness(
            examDate: examDate,
            readinessScore: calculateScore(categories: categories, examDate: examDate),
            categories: categories
        )
        
        // Assert
        XCTAssertGreaterThanOrEqual(readiness.readinessScore, 0)
    }
    
    func testReadinessScoreCalculation_EmptyCategories() throws {
        // Arrange
        let categories: [CategoryReadiness] = []
        let examDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        
        // Act & Assert
        let readiness = try ExamReadiness(
            examDate: examDate,
            readinessScore: 0,
            categories: categories
        )
        
        XCTAssertEqual(readiness.readinessScore, 0)
        XCTAssertEqual(readiness.totalCategories, 0)
    }
    
    // MARK: - Readiness Level Tests
    
    func testReadinessLevel_NotReady() throws {
        let categories = [makeCategory(completionPercentage: 30)]
        let readiness = try ExamReadiness(
            examDate: Date().addingTimeInterval(86400 * 30),
            readinessScore: 35,
            categories: categories
        )
        
        XCTAssertEqual(readiness.readinessLevel, .notReady)
        XCTAssertEqual(readiness.readinessLevel.label, "Noch nicht bereit")
    }
    
    func testReadinessLevel_OnTrack() throws {
        let categories = [makeCategory(completionPercentage: 60)]
        let readiness = try ExamReadiness(
            examDate: Date().addingTimeInterval(86400 * 45),
            readinessScore: 50,
            categories: categories
        )
        
        XCTAssertEqual(readiness.readinessLevel, .onTrack)
        XCTAssertEqual(readiness.readinessLevel.label, "Im Plan")
    }
    
    func testReadinessLevel_Exceeding() throws {
        let categories = [makeCategory(completionPercentage: 90)]
        let readiness = try ExamReadiness(
            examDate: Date().addingTimeInterval(86400 * 60),
            readinessScore: 85,
            categories: categories
        )
        
        XCTAssertEqual(readiness.readinessLevel, .exceeding)
        XCTAssertEqual(readiness.readinessLevel.label, "Hervorragend")
    }
    
    // MARK: - Exam Date Validation Tests
    
    func testExamDateValidation_RejectsPassDate() throws {
        let categories = [makeCategory(completionPercentage: 50)]
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        XCTAssertThrowsError(
            try ExamReadiness(
                examDate: pastDate,
                readinessScore: 50,
                categories: categories
            )
        ) { error in
            XCTAssertEqual(error as? ExamReadinessError, .invalidExamDate)
        }
    }
    
    func testExamDateValidation_AcceptsToday() throws {
        let categories = [makeCategory(completionPercentage: 50)]
        let today = Calendar.current.startOfDay(for: Date())
        
        let readiness = try ExamReadiness(
            examDate: today,
            readinessScore: 50,
            categories: categories
        )
        
        XCTAssertEqual(readiness.daysUntilExam, 0)
    }
    
    func testExamDateValidation_CalculatesDaysCorrectly() throws {
        let categories = [makeCategory(completionPercentage: 50)]
        let futureDate = Calendar.current.date(byAdding: .day, value: 45, to: Date())!
        
        let readiness = try ExamReadiness(
            examDate: futureDate,
            readinessScore: 50,
            categories: categories
        )
        
        XCTAssertEqual(readiness.daysUntilExam, 45)
    }
    
    // MARK: - Category Ready Count Tests
    
    func testReadyCategoryCount_CountsOnlyStrong() throws {
        let categories = [
            makeCategory(completionPercentage: 80), // Strong
            makeCategory(completionPercentage: 70), // Fair (>= 70)
            makeCategory(completionPercentage: 60), // Fair
            makeCategory(completionPercentage: 30)  // Weak
        ]
        
        let readiness = try ExamReadiness(
            examDate: Date().addingTimeInterval(86400 * 30),
            readinessScore: 60,
            categories: categories
        )
        
        XCTAssertEqual(readiness.readyCategoryCount, 2) // 80%, 70%
    }
    
    // MARK: - Average Strength Tests
    
    func testAverageStrength_Weak() throws {
        let categories = [
            makeCategory(completionPercentage: 20),
            makeCategory(completionPercentage: 35)
        ]
        
        let readiness = try ExamReadiness(
            examDate: Date().addingTimeInterval(86400 * 30),
            readinessScore: 30,
            categories: categories
        )
        
        XCTAssertEqual(readiness.averageStrength, .weak)
    }
    
    func testAverageStrength_Fair() throws {
        let categories = [
            makeCategory(completionPercentage: 50),
            makeCategory(completionPercentage: 60)
        ]
        
        let readiness = try ExamReadiness(
            examDate: Date().addingTimeInterval(86400 * 30),
            readinessScore: 55,
            categories: categories
        )
        
        XCTAssertEqual(readiness.averageStrength, .fair)
    }
    
    func testAverageStrength_Strong() throws {
        let categories = [
            makeCategory(completionPercentage: 90),
            makeCategory(completionPercentage: 80)
        ]
        
        let readiness = try ExamReadiness(
            examDate: Date().addingTimeInterval(86400 * 30),
            readinessScore: 85,
            categories: categories
        )
        
        XCTAssertEqual(readiness.averageStrength, .strong)
    }
    
    // MARK: - Helpers
    
    private func makeCategory(completionPercentage: Int) -> CategoryReadiness {
        CategoryReadiness(
            id: UUID().uuidString,
            categoryName: "Test Category",
            completionPercentage: completionPercentage,
            strength: CategoryStrength(percentage: completionPercentage),
            estimatedHoursRemaining: 5.0,
            totalQuestionsInCategory: 20,
            correctAttempts: (completionPercentage * 20) / 100
        )
    }
    
    private func calculateScore(categories: [CategoryReadiness], examDate: Date) -> Int {
        guard !categories.isEmpty else { return 0 }
        let avgCompletion = categories.map { $0.completionPercentage }.reduce(0, +) / categories.count
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0
        let timeFactor = min(100, (daysRemaining * 100) / 90)
        return Int((Double(avgCompletion) * 0.5) + (Double(timeFactor) * 0.5))
    }
}