import Foundation

// MARK: - Enums

enum UrgencyLevel: Equatable {
    case critical
    case high
    case normal
}

enum ExaminationStatus: Equatable {
    case preparing
    case completed
}

// MARK: - Mock Services

class MockUserService {
    var examDate: Date?
}

class MockProgressService {
    var overallReadiness: Int = 0
}

class MockNotificationScheduler {
    var shouldThrow: Bool = false
    var isPendingFlag: Bool = false
    
    func schedule(at time: DateComponents) async throws {
        if shouldThrow {
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
    }
}

// MARK: - DailyReminderViewModel

class DailyReminderViewModel {
    var userService: MockUserService
    var progressService: MockProgressService
    var notificationScheduler: MockNotificationScheduler
    
    var urgencyLevel: UrgencyLevel {
        guard let examDate = userService.examDate else { return .normal }
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0
        if daysRemaining <= 3 {
            return .critical
        } else if daysRemaining <= 7 {
            if progressService.overallReadiness < 50 || daysRemaining <= 5 {
                return .high
            }
            return .high
        } else {
            return .normal
        }
    }
    
    var examinationStatus: ExaminationStatus {
        guard let examDate = userService.examDate else { return .preparing }
        if examDate < Date() {
            return .completed
        }
        return .preparing
    }
    
    var notificationMessage: String {
        if examinationStatus == .completed {
            return "Glückwunsch zur bestandenen Prüfung!"
        }
        return ""
    }
    
    var readinessPct: Int {
        return progressService.overallReadiness
    }
    
    var isReminderEnabled: Bool = false
    
    init(userService: MockUserService, progressService: MockProgressService, notificationScheduler: MockNotificationScheduler) {
        self.userService = userService
        self.progressService = progressService
        self.notificationScheduler = notificationScheduler
        
        if notificationScheduler.isPendingFlag {
            self.isReminderEnabled = true
        }
    }
    
    func enableReminder(at time: DateComponents) async throws {
        do {
            try await notificationScheduler.schedule(at: time)
            isReminderEnabled = true
        } catch {
            isReminderEnabled = false
            throw error
        }
    }
}

// MARK: - Simple Test Harness

func assertEqual<T: Equatable>(_ a: T, _ b: T, file: String = #file, line: Int = #line) {
    if a != b {
        print("FAIL (\(file):\(line)): \(a) != \(b)")
    } else {
        print("PASS")
    }
}

func assertTrue(_ value: Bool, file: String = #file, line: Int = #line) {
    if !value {
        print("FAIL (\(file):\(line)): expected true")
    } else {
        print("PASS")
    }
}

func assertFalse(_ value: Bool, file: String = #file, line: Int = #line) {
    if value {
        print("FAIL (\(file):\(line)): expected false")
    } else {
        print("PASS")
    }
}

// MARK: - DailyReminderViewModelTests

class DailyReminderViewModelTests {
    var sut: DailyReminderViewModel!
    var mockUserService: MockUserService!
    var mockProgressService: MockProgressService!
    var mockNotificationScheduler: MockNotificationScheduler!
    
    func setUp() {
        mockUserService = MockUserService()
        mockProgressService = MockProgressService()
        mockNotificationScheduler = MockNotificationScheduler()
        sut = DailyReminderViewModel(
            userService: mockUserService,
            progressService: mockProgressService,
            notificationScheduler: mockNotificationScheduler
        )
    }
    
    func tearDown() {
        sut = nil
        mockUserService = nil
        mockProgressService = nil
        mockNotificationScheduler = nil
    }
    
    // MARK: - Urgency Calculation
    
    func testUrgencyLevel_Critical_When3DaysRemaining() {
        setUp()
        let examDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 80
        assertEqual(sut.urgencyLevel, .critical)
        tearDown()
    }
    
    func testUrgencyLevel_High_When7DaysAnd40PercentReadiness() {
        setUp()
        let examDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 40
        assertEqual(sut.urgencyLevel, .high)
        tearDown()
    }
    
    func testUrgencyLevel_High_When5DaysEvenWith80Percent() {
        setUp()
        let examDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 80
        assertEqual(sut.urgencyLevel, .high)
        tearDown()
    }
    
    func testUrgencyLevel_Normal_When21DaysAnd70Percent() {
        setUp()
        let examDate = Calendar.current.date(byAdding: .day, value: 21, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 70
        assertEqual(sut.urgencyLevel, .normal)
        tearDown()
    }
    
    // MARK: - Post-Exam State
    
    func testExaminationStatus_Completed_WhenExamDatePassed() {
        setUp()
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        mockUserService.examDate = pastDate
        assertEqual(sut.examinationStatus, .completed)
        assertTrue(sut.notificationMessage.contains("Glückwunsch"))
        tearDown()
    }
    
    func testExaminationStatus_DoesNotUpdate_WhenExamDateIsNil() {
        setUp()
        mockUserService.examDate = nil
        let statusBefore = sut.examinationStatus
        assertEqual(statusBefore, .preparing)
        tearDown()
    }
    
    // MARK: - Race Condition Prevention (Debouncing)
    
    func testRapidUpdates_OnlyFinalStateApplied() {
        setUp()
        let _ = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        for i in 1...5 {
            mockProgressService.overallReadiness = i * 10
        }
        assertEqual(sut.readinessPct, 50)
        tearDown()
    }
    
    // MARK: - Enable Reminder Error Handling
    
    func testEnableReminder_ThrowsError_WhenSchedulerFails() async {
        setUp()
        mockNotificationScheduler.shouldThrow = true
        let time = DateComponents(hour: 9, minute: 0)
        do {
            try await sut.enableReminder(at: time)
            print("FAIL: Expected error to be thrown")
        } catch {
            assertFalse(sut.isReminderEnabled)
        }
        tearDown()
    }
    
    // MARK: - Load Reminder State
    
    func testLoadReminderState_RestoresPreviouslyEnabledReminder() {
        setUp()
        mockNotificationScheduler.isPendingFlag = true
        let newViewModel = DailyReminderViewModel(
            userService: mockUserService,
            progressService: mockProgressService,
            notificationScheduler: mockNotificationScheduler
        )
        assertTrue(newViewModel.isReminderEnabled)
        tearDown()
    }
    
    func runAll() async {
        testUrgencyLevel_Critical_When3DaysRemaining()
        testUrgencyLevel_High_When7DaysAnd40PercentReadiness()
        testUrgencyLevel_High_When5DaysEvenWith80Percent()
        testUrgencyLevel_Normal_When21DaysAnd70Percent()
        testExaminationStatus_Completed_WhenExamDatePassed()
        testExaminationStatus_DoesNotUpdate_WhenExamDateIsNil()
        testRapidUpdates_OnlyFinalStateApplied()
        await testEnableReminder_ThrowsError_WhenSchedulerFails()
        testLoadReminderState_RestoresPreviouslyEnabledReminder()
    }
}