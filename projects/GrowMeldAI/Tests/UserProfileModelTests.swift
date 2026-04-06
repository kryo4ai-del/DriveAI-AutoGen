import XCTest
@testable import DriveAI

class UserProfileModelTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testEmptyProfileInitialization() {
        let profile = UserProfile.empty()
        
        XCTAssertNotNil(profile.id)
        XCTAssertEqual(profile.displayName, "")
        XCTAssertNil(profile.examDate)
        XCTAssertEqual(profile.totalScore, 0)
        XCTAssertEqual(profile.attemptCount, 0)
        XCTAssertEqual(profile.currentStreak, 0)
        XCTAssertTrue(profile.categoryProgress.isEmpty)
        XCTAssertTrue(profile.examAttempts.isEmpty)
    }
    
    func testProfileInitializationWithValidData() {
        let examDate = Calendar.current.date(byAdding: .day, value: 30, to: .now)!
        let profile = UserProfile(
            displayName: "Max Mustermann",
            examDate: examDate
        )
        
        XCTAssertEqual(profile.displayName, "Max Mustermann")
        XCTAssertEqual(profile.examDate, examDate)
    }
    
    // MARK: - Display Name Validation
    
    func testDisplayNameTrimsWhitespace() {
        var profile = UserProfile()
        profile.displayName = "  John Doe  "
        
        XCTAssertEqual(profile.displayName, "John Doe")
    }
    
    func testEmptyDisplayNameDefaultsToBenutzer() {
        var profile = UserProfile()
        profile.displayName = ""
        
        XCTAssertEqual(profile.displayName, "Benutzer")
    }
    
    func testWhitespaceOnlyDisplayNameDefaultsToBenutzer() {
        var profile = UserProfile()
        profile.displayName = "   "
        
        XCTAssertEqual(profile.displayName, "Benutzer")
    }
    
    func testDisplayNameValidation_WithSpecialCharacters() {
        var profile = UserProfile()
        profile.displayName = "Müller-Schäfer"
        
        XCTAssertEqual(profile.displayName, "Müller-Schäfer")
    }
    
    // MARK: - Exam Date Validation
    
    func testFutureDateAccepted() {
        var profile = UserProfile()
        let futureDate = Calendar.current.date(byAdding: .day, value: 30, to: .now)!
        
        profile.examDate = futureDate
        
        XCTAssertEqual(profile.examDate, futureDate)
    }
    
    func testPastDateRejected() {
        var profile = UserProfile()
        let pastDate = Calendar.current.date(byAdding: .day, value: -10, to: .now)!
        
        profile.examDate = pastDate
        
        XCTAssertNil(profile.examDate)
    }
    
    func testCurrentDateRejected() {
        var profile = UserProfile()
        let today = Calendar.current.startOfDay(for: .now)
        
        profile.examDate = today
        
        XCTAssertNil(profile.examDate)
    }
    
    func testExamDateCanBeCleared() {
        var profile = UserProfile(
            examDate: Calendar.current.date(byAdding: .day, value: 30, to: .now)!
        )
        
        profile.examDate = nil
        
        XCTAssertNil(profile.examDate)
    }
    
    // MARK: - Score Validation
    
    func testTotalScoreCannotBeNegative() {
        var profile = UserProfile()
        profile.totalScore = -10
        
        XCTAssertEqual(profile.totalScore, 0)
    }
    
    func testTotalScoreIncrement() {
        var profile = UserProfile()
        profile.totalScore = 50
        
        XCTAssertEqual(profile.totalScore, 50)
    }
    
    // MARK: - Attempt Count Validation
    
    func testAttemptCountCannotBeNegative() {
        var profile = UserProfile()
        profile.attemptCount = -5
        
        XCTAssertEqual(profile.attemptCount, 0)
    }
    
    func testAttemptCountIncrement() {
        var profile = UserProfile()
        profile.attemptCount = 10
        
        XCTAssertEqual(profile.attemptCount, 10)
    }
    
    // MARK: - Streak Validation
    
    func testStreakCannotBeNegative() {
        var profile = UserProfile()
        profile.currentStreak = -3
        
        XCTAssertEqual(profile.currentStreak, 0)
    }
    
    func testStreakCanBeZero() {
        var profile = UserProfile()
        profile.currentStreak = 5
        profile.currentStreak = 0
        
        XCTAssertEqual(profile.currentStreak, 0)
    }
    
    // MARK: - Equatable
    
    func testProfilesAreEqual() {
        let id = UUID()
        let profile1 = UserProfile(id: id, displayName: "Test")
        let profile2 = UserProfile(id: id, displayName: "Test")
        
        XCTAssertEqual(profile1, profile2)
    }
    
    func testProfilesAreNotEqual_DifferentID() {
        let profile1 = UserProfile(displayName: "Test")
        let profile2 = UserProfile(displayName: "Test")
        
        XCTAssertNotEqual(profile1, profile2)
    }
    
    // MARK: - Codable
    
    func testProfileEncodingAndDecoding() throws {
        let original = UserProfile(
            displayName: "Testuser",
            examDate: Calendar.current.date(byAdding: .day, value: 30, to: .now)!
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(UserProfile.self, from: data)
        
        XCTAssertEqual(decoded.displayName, original.displayName)
        XCTAssertEqual(decoded.examDate, original.examDate)
        XCTAssertEqual(decoded.id, original.id)
    }
}