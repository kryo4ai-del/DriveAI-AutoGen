import XCTest
@testable import DriveAI

final class PreferencesServiceTests: XCTestCase {
    var sut: PreferencesService!
    
    override func setUp() {
        super.setUp()
        sut = PreferencesService()
        // Clear preferences before each test
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
    }
    
    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func test_saveUserProfile_persists() throws {
        let profile = UserProfile(name: "John Doe", examDate: Date(), preferredLanguage: "de")
        
        try sut.saveUserProfile(profile)
        let loaded = try sut.loadUserProfile()
        
        XCTAssertNotNil(loaded, "Should retrieve saved profile")
        XCTAssertEqual(loaded?.name, "John Doe", "Profile name should match")
        XCTAssertEqual(loaded?.preferredLanguage, "de", "Language preference should be saved")
    }
    
    func test_loadUserProfile_returnsNil_whenNotSaved() throws {
        let loaded = try sut.loadUserProfile()
        
        XCTAssertNil(loaded, "Should return nil when no profile saved")
    }
    
    func test_saveAndLoadProfile_preservesExamDate() throws {
        let examDate = Date().addingTimeInterval(86400 * 30)  // 30 days from now
        var profile = UserProfile.default
        profile.examDate = examDate
        
        try sut.saveUserProfile(profile)
        let loaded = try sut.loadUserProfile()
        
        XCTAssertNotNil(loaded?.examDate, "Exam date should be preserved")
        XCTAssertEqual(loaded?.examDate?.timeIntervalSince1970, examDate.timeIntervalSince1970, accuracy: 1)
    }
    
    func test_overwriteProfile_replacesOldData() throws {
        let profile1 = UserProfile(name: "Alice", examDate: nil)
        let profile2 = UserProfile(name: "Bob", examDate: Date())
        
        try sut.saveUserProfile(profile1)
        try sut.saveUserProfile(profile2)
        
        let loaded = try sut.loadUserProfile()
        XCTAssertEqual(loaded?.name, "Bob", "Second save should overwrite first")
    }
    
    // MARK: - Edge Cases
    
    func test_saveProfile_withEmptyName() throws {
        let profile = UserProfile(name: "", examDate: Date())
        
        try sut.saveUserProfile(profile)
        let loaded = try sut.loadUserProfile()
        
        XCTAssertNotNil(loaded, "Should save even with empty name")
        XCTAssertEqual(loaded?.name, "", "Should preserve empty name")
    }
    
    func test_saveProfile_withFarFutureDate() throws {
        let farFuture = Date().addingTimeInterval(86400 * 365 * 10)  // 10 years
        var profile = UserProfile.default
        profile.examDate = farFuture
        
        try sut.saveUserProfile(profile)
        let loaded = try sut.loadUserProfile()
        
        XCTAssertNotNil(loaded?.examDate, "Should handle far future dates")
    }
    
    func test_saveProfile_withMinimalData() throws {
        let profile = UserProfile(name: "X", examDate: Date())
        
        try sut.saveUserProfile(profile)
        let loaded = try sut.loadUserProfile()
        
        XCTAssertEqual(loaded?.name, "X", "Should save minimal profiles")
    }
    
    // MARK: - Concurrency Tests
    
    func test_saveProfile_concurrentWrites() async throws {
        let profiles = (1...5).map { i in
            var p = UserProfile.default
            p.name = "User \(i)"
            return p
        }
        
        let results = try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
            for profile in profiles {
                group.addTask {
                    try self.sut.saveUserProfile(profile)
                }
            }
            try await group.waitForAll()
        }
        
        let loaded = try sut.loadUserProfile()
        XCTAssertNotNil(loaded, "Should handle concurrent saves")
    }
    
    // MARK: - Default Values Test
    
    func test_userProfileDefault_hasValidValues() {
        let profile = UserProfile.default
        
        XCTAssertEqual(profile.name, "", "Default name should be empty")
        XCTAssertNil(profile.examDate, "Default exam date should be nil")
        XCTAssertEqual(profile.preferredLanguage, "de", "Default language should be German")
        XCTAssertTrue(profile.notificationsEnabled, "Notifications should default to enabled")
    }
}