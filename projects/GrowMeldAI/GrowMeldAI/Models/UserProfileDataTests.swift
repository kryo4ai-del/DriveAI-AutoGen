import XCTest
@testable import DriveAI

final class UserProfileDataTests: XCTestCase {
    
    // MARK: - Initialization
    
    func testNewProfileCreatesUniqueID() {
        let profile1 = UserProfileData.new(
            name: "Max Mustermann",
            examDate: Date().addingTimeInterval(86400 * 14)
        )
        let profile2 = UserProfileData.new(
            name: "Maria Schmidt",
            examDate: Date().addingTimeInterval(86400 * 14)
        )
        
        XCTAssertNotEqual(profile1.id, profile2.id, "Each new profile should have unique ID")
    }
    
    func testNewProfileSetsCurrentTimestamps() {
        let beforeCreation = Date()
        let profile = UserProfileData.new(
            name: "Test User",
            examDate: Date().addingTimeInterval(86400 * 14)
        )
        let afterCreation = Date()
        
        XCTAssertGreaterThanOrEqual(profile.createdAt, beforeCreation)
        XCTAssertLessThanOrEqual(profile.createdAt, afterCreation)
        XCTAssertEqual(profile.updatedAt, profile.createdAt)
    }
    
    // MARK: - Immutability
    
    func testWithPhotoReturnsNewInstance() {
        let original = UserProfileData.new(
            name: "Max",
            examDate: Date().addingTimeInterval(86400 * 14),
            photoURL: nil
        )
        let photoURL = URL(fileURLWithPath: "/tmp/photo.jpg")
        let updated = original.withPhoto(photoURL)
        
        XCTAssertNil(original.photoURL, "Original should remain unchanged")
        XCTAssertEqual(updated.photoURL, photoURL)
        XCTAssertEqual(original.id, updated.id, "ID should remain same")
    }
    
    func testWithPhotoUpdatesTimestamp() {
        let original = UserProfileData.new(
            name: "Max",
            examDate: Date().addingTimeInterval(86400 * 14)
        )
        
        // Wait to ensure time difference
        Thread.sleep(forTimeInterval: 0.01)
        
        let photoURL = URL(fileURLWithPath: "/tmp/photo.jpg")
        let updated = original.withPhoto(photoURL)
        
        XCTAssertGreaterThan(updated.updatedAt, original.updatedAt)
    }
    
    func testWithExamDatePreservesOtherFields() {
        let original = UserProfileData.new(
            name: "Max Mustermann",
            examDate: Date().addingTimeInterval(86400 * 14),
            licenseCategory: .b
        )
        let newDate = Date().addingTimeInterval(86400 * 30)
        let updated = original.withExamDate(newDate)
        
        XCTAssertEqual(updated.name, original.name)
        XCTAssertEqual(updated.licenseCategory, original.licenseCategory)
        XCTAssertEqual(updated.examDate, newDate)
    }
    
    // MARK: - Validation: Name
    
    func testValidateAcceptsValidName() throws {
        let profile = UserProfileData.new(
            name: "Max Mustermann",
            examDate: Date().addingTimeInterval(86400 * 14)
        )
        
        XCTAssertNoThrow(try profile.validate())
    }
    
    func testValidateAcceptsNameWithDiacritics() throws {
        let profiles = [
            UserProfileData.new(name: "José García", examDate: Date().addingTimeInterval(86400 * 14)),
            UserProfileData.new(name: "Müller", examDate: Date().addingTimeInterval(86400 * 14)),
            UserProfileData.new(name: "Jörg Schönberg", examDate: Date().addingTimeInterval(86400 * 14))
        ]
        
        for profile in profiles {
            XCTAssertNoThrow(try profile.validate(), "Should accept diacritics: \(profile.name)")
        }
    }
    
    func testValidateAcceptsNameWithHyphensAndApostrophes() throws {
        let profiles = [
            UserProfileData.new(name: "Anne-Marie", examDate: Date().addingTimeInterval(86400 * 14)),
            UserProfileData.new(name: "O'Brien", examDate: Date().addingTimeInterval(86400 * 14)),
            UserProfileData.new(name: "Jean-Pierre Martin", examDate: Date().addingTimeInterval(86400 * 14))
        ]
        
        for profile in profiles {
            XCTAssertNoThrow(try profile.validate(), "Should accept hyphens/apostrophes: \(profile.name)")
        }
    }
    
    func testValidateRejectsEmptyName() {
        let profile = UserProfileData(
            id: UUID(),
            name: "",
            examDate: Date().addingTimeInterval(86400 * 14),
            licenseCategory: .b,
            photoURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertThrowsError(try profile.validate()) { error in
            XCTAssertEqual(error as? ProfileValidationError, .emptyName)
        }
    }
    
    func testValidateRejectsWhitespaceOnlyName() {
        let profile = UserProfileData(
            id: UUID(),
            name: "   ",
            examDate: Date().addingTimeInterval(86400 * 14),
            licenseCategory: .b,
            photoURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertThrowsError(try profile.validate()) { error in
            XCTAssertEqual(error as? ProfileValidationError, .emptyName)
        }
    }
    
    func testValidateRejectsNameTooShort() {
        let profile = UserProfileData(
            id: UUID(),
            name: "A",
            examDate: Date().addingTimeInterval(86400 * 14),
            licenseCategory: .b,
            photoURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertThrowsError(try profile.validate()) { error in
            XCTAssertEqual(error as? ProfileValidationError, .nameTooShort)
        }
    }
    
    func testValidateAcceptsNameAtMinimumLength() throws {
        let profile = UserProfileData.new(
            name: "Ab",  // Exactly 2 characters
            examDate: Date().addingTimeInterval(86400 * 14)
        )
        
        XCTAssertNoThrow(try profile.validate())
    }
    
    func testValidateRejectsNumbersInName() {
        let profile = UserProfileData(
            id: UUID(),
            name: "Max123",
            examDate: Date().addingTimeInterval(86400 * 14),
            licenseCategory: .b,
            photoURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertThrowsError(try profile.validate()) { error in
            XCTAssertEqual(error as? ProfileValidationError, .invalidNameCharacters)
        }
    }
    
    func testValidateRejectsSpecialCharactersInName() {
        let invalidNames = ["Max@Mustermann", "Test!User", "Name#123", "User$"]
        
        for invalidName in invalidNames {
            let profile = UserProfileData(
                id: UUID(),
                name: invalidName,
                examDate: Date().addingTimeInterval(86400 * 14),
                licenseCategory: .b,
                photoURL: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            XCTAssertThrowsError(try profile.validate(), "Should reject: \(invalidName)")
        }
    }
    
    // MARK: - Validation: Exam Date
    
    func testValidateAcceptsExamDate14DaysInFuture() throws {
        let examDate = Date.minimumExamDate()
        let profile = UserProfileData(
            id: UUID(),
            name: "Max",
            examDate: examDate,
            licenseCategory: .b,
            photoURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertNoThrow(try profile.validate())
    }
    
    func testValidateRejectsExamDateBefore14Days() {
        let examDate = Date().addingTimeInterval(86400 * 7)  // Only 7 days away
        let profile = UserProfileData(
            id: UUID(),
            name: "Max",
            examDate: examDate,
            licenseCategory: .b,
            photoURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertThrowsError(try profile.validate()) { error in
            XCTAssertEqual(error as? ProfileValidationError, .examDateTooSoon)
        }
    }
    
    func testValidateRejectsExamDateInPast() {
        let examDate = Date().addingTimeInterval(-86400)  // Yesterday
        let profile = UserProfileData(
            id: UUID(),
            name: "Max",
            examDate: examDate,
            licenseCategory: .b,
            photoURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertThrowsError(try profile.validate())
    }
    
    func testValidateRejectsExamDateToday() {
        let examDate = Date()
        let profile = UserProfileData(
            id: UUID(),
            name: "Max",
            examDate: examDate,
            licenseCategory: .b,
            photoURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertThrowsError(try profile.validate())
    }
    
    // MARK: - Computed Properties
    
    func testDaysUntilExamCalculatesCorrectly() {
        let futureDate = Date().addingTimeInterval(86400 * 30)
        let profile = UserProfileData.new(
            name: "Max",
            examDate: futureDate
        )
        
        let daysUntilExam = profile.daysUntilExam
        XCTAssertGreaterThanOrEqual(daysUntilExam, 29)
        XCTAssertLessThanOrEqual(daysUntilExam, 30)
    }
    
    func testDaysUntilExamReturnsZeroForPastDate() {
        let pastDate = Date().addingTimeInterval(-86400)
        let profile = UserProfileData(
            id: UUID(),
            name: "Max",
            examDate: pastDate,
            licenseCategory: .b,
            photoURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(profile.daysUntilExam, 0)
    }
    
    func testIsExamSoonReturnsTrue() {
        let examDate = Date().addingTimeInterval(86400 * 3)
        let profile = UserProfileData(
            id: UUID(),
            name: "Max",
            examDate: examDate,
            licenseCategory: .b,
            photoURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertTrue(profile.isExamSoon)
    }
    
    func testIsExamSoonReturnsFalseWhenBeyond7Days() {
        let examDate = Date().addingTimeInterval(86400 * 30)
        let profile = UserProfileData(
            id: UUID(),
            name: "Max",
            examDate: examDate,
            licenseCategory: .b,
            photoURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertFalse(profile.isExamSoon)
    }
    
    // MARK: - Codable
    
    func testEncodingAndDecodingPreservesData() throws {
        let original = UserProfileData.new(
            name: "Max Mustermann",
            examDate: Date().addingTimeInterval(86400 * 14),
            licenseCategory: .b,
            photoURL: URL(fileURLWithPath: "/tmp/photo.jpg")
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(UserProfileData.self, from: encoded)
        
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.licenseCategory, original.licenseCategory)
        XCTAssertEqual(decoded.photoURL, original.photoURL)
    }
    
    func testEncodingPreservesTimestamps() throws {
        let original = UserProfileData.new(
            name: "Test",
            examDate: Date().addingTimeInterval(86400 * 14)
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(UserProfileData.self, from: encoded)
        
        // Compare with small tolerance for serialization rounding
        XCTAssertEqual(
            original.createdAt.timeIntervalSince1970,
            decoded.createdAt.timeIntervalSince1970,
            accuracy: 0.001
        )
    }
}

// MARK: - Helper Extensions for Tests

extension XCTestCase {
    func XCTAssertNoThrow<T>(_ expression: @autoclosure () throws -> T, _ message: @autoclosure () -> String = "") {
        do {
            _ = try expression()
        } catch {
            XCTFail("\(message()) - Unexpected error thrown: \(error)")
        }
    }
}