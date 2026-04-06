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

// MARK: - Tests

func runTests() async {
    // testUrgencyLevel_Critical_When3DaysRemaining
    do {
        let mockUserService = MockUserService()
        let mockProgressService = MockProgressService()
        let mockNotificationScheduler = MockNotificationScheduler()
        let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
        
        let examDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 80
        
        assertEqual(sut.urgencyLevel, .critical)
    }
    
    // testUrgencyLevel_High_When7DaysAnd40PercentReadiness
    do {
        let mockUserService = MockUserService()
        let mockProgressService = MockProgressService()
        let mockNotificationScheduler = MockNotificationScheduler()
        let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
        
        let examDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 40
        
        assertEqual(sut.urgencyLevel, .high)
    }
    
    // testUrgencyLevel_High_When5DaysEvenWith80Percent
    do {
        let mockUserService = MockUserService()
        let mockProgressService = MockProgressService()
        let mockNotificationScheduler = MockNotificationScheduler()
        let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
        
        let examDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 80
        
        assertEqual(sut.urgencyLevel, .high)
    }
    
    // testUrgencyLevel_Normal_When21DaysAnd70Percent
    do {
        let mockUserService = MockUserService()
        let mockProgressService = MockProgressService()
        let mockNotificationScheduler = MockNotificationScheduler()
        let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
        
        let examDate = Calendar.current.date(byAdding: .day, value: 21, to: Date())!
        mockUserService.examDate = examDate
        mockProgressService.overallReadiness = 70
        
        assertEqual(sut.urgencyLevel, .normal)
    }
    
    // testExaminationStatus_Completed_WhenExamDatePassed
    do {
        let mockUserService = MockUserService()
        let mockProgressService = MockProgressService()
        let mockNotificationScheduler = MockNotificationScheduler()
        let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
        
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        mockUserService.examDate = pastDate
        
        assertEqual(sut.examinationStatus, .completed)
        assertTrue(sut.notificationMessage.contains("Glückwunsch"))
    }
    
    // testExaminationStatus_DoesNotUpdate_WhenExamDateIsNil
    do {
        let mockUserService = MockUserService()
        let mockProgressService = MockProgressService()
        let mockNotificationScheduler = MockNotificationScheduler()
        let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
        
        mockUserService.examDate = nil
        let statusBefore = sut.examinationStatus
        assertEqual(statusBefore, .preparing)
    }
    
    // testRapidUpdates_OnlyFinalStateApplied
    do {
        let mockUserService = MockUserService()
        let mockProgressService = MockProgressService()
        let mockNotificationScheduler = MockNotificationScheduler()
        let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
        
        let examDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        mockUserService.examDate = examDate
        
        for i in 1...5 {
            mockProgressService.overallReadiness = i * 10
        }
        
        assertEqual(sut.readinessPct, 50)
    }
    
    // testEnableReminder_ThrowsError_WhenSchedulerFails
    do {
        let mockUserService = MockUserService()
        let mockProgressService = MockProgressService()
        let mockNotificationScheduler = MockNotificationScheduler()
        let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
        
        mockNotificationScheduler.shouldThrow = true
        let time = DateComponents(hour: 9, minute: 0)
        
        do {
            try await sut.enableReminder(at: time)
            print("FAIL: Expected error to be thrown")
        } catch {
            assertFalse(sut.isReminderEnabled)
        }
    }
    
    // testLoadReminderState_RestoresPreviouslyEnabledReminder
    do {
        let mockUserService = MockUserService()
        let mockProgressService = MockProgressService()
        let mockNotificationScheduler = MockNotificationScheduler()
        mockNotificationScheduler.isPendingFlag = true
        
        let newViewModel = DailyReminderViewModel(
            userService: mockUserService,
            progressService: mockProgressService,
            notificationScheduler: mockNotificationScheduler
        )
        
        assertTrue(newViewModel.isReminderEnabled)
    }
    
    print("All tests completed.")
}

// Entry point
let semaphore = DispatchSemaphore(value: 0)
Task {
    await runTests()
    semaphore.signal()
}
semaphore.wait()