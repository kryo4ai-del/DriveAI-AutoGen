class StorageServiceTests: XCTestCase {
    var storageService: StorageService!
    
    override func setUp() {
        super.setUp()
        storageService = StorageService()
        try? storageService.clearAllData()  // Clean slate
    }
    
    override func tearDown() {
        try? storageService.clearAllData()
        super.tearDown()
    }
    
    func testSaveAndLoadUserProfile() throws {
        var profile = UserProfile.default
        profile.totalCorrect = 42
        profile.examsCompleted = 1
        
        try storageService.saveUserProfile(profile)
        let loaded = storageService.loadUserProfile()
        
        XCTAssertEqual(loaded?.totalCorrect, 42)
        XCTAssertEqual(loaded?.examsCompleted, 1)
    }
    
    func testLoadUserProfileReturnsNilWhenEmpty() {
        let loaded = storageService.loadUserProfile()
        XCTAssertNil(loaded)
    }
    
    func testSaveQuestionStats() throws {
        var stats = QuestionStats(questionId: "q1")
        stats.timesAnswered = 3
        stats.timesCorrect = 2
        
        try storageService.saveQuestionStats(stats)
        let loaded = storageService.loadQuestionStats(questionId: "q1")
        
        XCTAssertEqual(loaded?.timesAnswered, 3)
        XCTAssertEqual(loaded?.timesCorrect, 2)
    }
    
    func testLoadAllQuestionStats() throws {
        try storageService.saveQuestionStats(QuestionStats(questionId: "q1", timesAnswered: 1))
        try storageService.saveQuestionStats(QuestionStats(questionId: "q2", timesAnswered: 2))
        
        let allStats = storageService.loadAllQuestionStats()
        XCTAssertEqual(allStats.count, 2)
    }
    
    func testClearAllDataRemovesProfile() throws {
        var profile = UserProfile.default
        profile.totalCorrect = 99
        try storageService.saveUserProfile(profile)
        
        try storageService.clearAllData()
        
        XCTAssertNil(storageService.loadUserProfile())
    }
    
    func testSaveProfileIsThreadSafe() throws {
        // Run concurrent saves
        let queue = DispatchQueue(label: "test", attributes: .concurrent)
        let group = DispatchGroup()
        
        for i in 0..<10 {
            queue.async(group: group) {
                var profile = UserProfile.default
                profile.totalCorrect = i
                try? self.storageService.saveUserProfile(profile)
            }
        }
        
        group.waitWithTimeout(seconds: 5)
        
        let final = storageService.loadUserProfile()
        XCTAssertNotNil(final)  // Some value was saved (thread-safe)
    }
}

extension DispatchGroup {
    func waitWithTimeout(seconds: TimeInterval) {
        let result = self.wait(timeout: .now() + seconds)
        XCTAssertEqual(result, .success, "Dispatch group timed out")
    }
}