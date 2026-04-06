// Tests/Unit/Services/PersistenceManagerTests.swift
import XCTest
@testable import DriveAI

@MainActor
final class PersistenceManagerTests: XCTestCase {
    var sut: PersistenceManager!
    
    override func setUp() {
        super.setUp()
        sut = PersistenceManager()
        // Clean state before each test
        try? sut.clearAll()
    }
    
    override func tearDown() {
        try? sut.clearAll()
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func test_saveAndLoadUserProfile_succeeds() throws {
        // Given
        let profile = UserProfile(
            examDate: Date().addingTimeInterval(86400 * 30),
            totalQuestionsAnswered: 10,
            totalCorrect: 8
        )
        
        // When
        try sut.saveUserProfile(profile)
        let loaded = try sut.loadUserProfile()
        
        // Then
        XCTAssertEqual(loaded.totalQuestionsAnswered, 10)
        XCTAssertEqual(loaded.totalCorrect, 8)
        XCTAssertEqual(loaded.examDate.timeIntervalSinceReferenceDate,
                      profile.examDate.timeIntervalSinceReferenceDate,
                      accuracy: 1.0)  // Within 1 second
    }
    
    func test_saveUserProfile_overwritesPrevious() throws {
        // Given
        let profile1 = UserProfile(examDate: Date(), totalQuestionsAnswered: 5, totalCorrect: 3)
        let profile2 = UserProfile(examDate: Date(), totalQuestionsAnswered: 10, totalCorrect: 8)
        
        // When
        try sut.saveUserProfile(profile1)
        try sut.saveUserProfile(profile2)
        let loaded = try sut.loadUserProfile()
        
        // Then
        XCTAssertEqual(loaded.totalQuestionsAnswered, 10)
    }
    
    func test_saveCategoryStats() throws {
        // Given
        var profile = UserProfile(examDate: Date())
        profile.categoryStats["Verkehrszeichen"] = CategoryStat(
            category: "Verkehrszeichen",
            questionsAnswered: 20,
            correct: 18
        )
        
        // When
        try sut.saveUserProfile(profile)
        let loaded = try sut.loadUserProfile()
        
        // Then
        let stat = loaded.categoryStats["Verkehrszeichen"]
        XCTAssertEqual(stat?.questionsAnswered, 20)
        XCTAssertEqual(stat?.correct, 18)
        XCTAssertEqual(stat?.percentageScore, 0.9, accuracy: 0.01)
    }
    
    // MARK: - Edge Cases
    
    func test_loadUserProfile_whenNoneExists_throwsNoDataAvailable() {
        // Given
        try? sut.clearAll()
        
        // When + Then
        XCTAssertThrowsError(try sut.loadUserProfile()) { error in
            guard let appError = error as? AppError else {
                XCTFail("Wrong error type")
                return
            }
            if case .noDataAvailable = appError {} else {
                XCTFail("Expected noDataAvailable error")
            }
        }
    }
    
    func test_saveProfile_withLargeNumberOfCategories() throws {
        // Given
        var profile = UserProfile(examDate: Date())
        for i in 0..<100 {
            profile.categoryStats["Category_\(i)"] = CategoryStat(
                category: "Category_\(i)",
                questionsAnswered: i,
                correct: i / 2
            )
        }
        
        // When
        try sut.saveUserProfile(profile)
        let loaded = try sut.loadUserProfile()
        
        // Then
        XCTAssertEqual(loaded.categoryStats.count, 100)
        XCTAssertEqual(loaded.categoryStats["Category_99"]?.questionsAnswered, 99)
    }
    
    func test_dateEncodingDecoding_preservesISO8601Format() throws {
        // Given
        let originalDate = Date(timeIntervalSince1970: 1234567890)
        var profile = UserProfile(examDate: originalDate)
        profile.lastQuizDate = Date(timeIntervalSince1970: 1234567900)
        
        // When
        try sut.saveUserProfile(profile)
        let loaded = try sut.loadUserProfile()
        
        // Then
        XCTAssertEqual(
            loaded.examDate.timeIntervalSince1970,
            originalDate.timeIntervalSince1970,
            accuracy: 0.1
        )
        XCTAssertEqual(
            loaded.lastQuizDate?.timeIntervalSince1970,
            1234567900,
            accuracy: 0.1
        )
    }
    
    // MARK: - Concurrency Tests
    
    func test_concurrentWrites_doNotCorruptData() async throws {
        // Given
        let queue = DispatchQueue(label: "concurrent-test", attributes: .concurrent)
        
        // When: 10 concurrent write operations
        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    var profile = UserProfile(examDate: Date())
                    profile.totalQuestionsAnswered = i
                    profile.totalCorrect = i / 2
                    try self.sut.saveUserProfile(profile)
                }
            }
            try await group.waitForAll()
        }
        
        // Then: Final state should be valid
        let loaded = try sut.loadUserProfile()
        XCTAssertGreaterThanOrEqual(loaded.totalQuestionsAnswered, 0)
        XCTAssertLessThanOrEqual(loaded.totalQuestionsAnswered, 9)
    }
    
    // MARK: - Error Recovery
    
    func test_clearAll_removesPersistedData() throws {
        // Given
        var profile = UserProfile(examDate: Date())
        profile.totalQuestionsAnswered = 50
        try sut.saveUserProfile(profile)
        
        // When
        try sut.clearAll()
        
        // Then
        XCTAssertThrowsError(try sut.loadUserProfile())
    }
}