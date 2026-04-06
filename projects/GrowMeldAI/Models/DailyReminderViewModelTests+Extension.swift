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
    
    var urgencyLevel: UrgencyLevel = .normal
    var examinationStatus: ExaminationStatus = .preparing
    var notificationMessage: String = ""
    var readinessPct: Int = 0
    var isReminderEnabled: Bool = false
    
    init(userService: MockUserService, progressService: MockProgressService, notificationScheduler: MockNotificationScheduler) {
        self.userService = userService
        self.progressService = progressService
        self.notificationScheduler = notificationScheduler
        
        if notificationScheduler.isPendingFlag {
            isReminderEnabled = true
        }
        
        updateState()
    }
    
    func updateState() {
        readinessPct = progressService.overallReadiness
        
        guard let examDate = userService.examDate else {
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let daysRemaining = calendar.dateComponents([.day], from: now, to: examDate).day ?? 0
        
        if daysRemaining < 0 {
            examinationStatus = .completed
            notificationMessage = "Glückwunsch zur bestandenen Prüfung!"
            return
        }
        
        if daysRemaining <= 3 {
            urgencyLevel = .critical
        } else if daysRemaining <= 7 {
            urgencyLevel = .high
        } else if daysRemaining <= 14 && readinessPct < 50 {
            urgencyLevel = .high
        } else {
            urgencyLevel = .normal
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
    
    func refresh() {
        readinessPct = progressService.overallReadiness
        updateState()
    }
}

// MARK: - Tests (standalone, no XCTest)

@main
struct TestRunner {
    static func main() async {
        print("Running tests...")
        
        var passed = 0
        var failed = 0
        
        func assert(_ condition: Bool, _ message: String = "", file: String = #file, line: Int = #line) {
            if condition {
                passed += 1
            } else {
                failed += 1
                print("FAIL (\(file):\(line)): \(message)")
            }
        }
        
        // testUrgencyLevel_Critical_When3DaysRemaining
        do {
            let mockUserService = MockUserService()
            let mockProgressService = MockProgressService()
            let mockNotificationScheduler = MockNotificationScheduler()
            let examDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
            mockUserService.examDate = examDate
            mockProgressService.overallReadiness = 80
            let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
            assert(sut.urgencyLevel == .critical, "Expected critical urgency for 3 days remaining")
        }
        
        // testUrgencyLevel_High_When7DaysAnd40PercentReadiness
        do {
            let mockUserService = MockUserService()
            let mockProgressService = MockProgressService()
            let mockNotificationScheduler = MockNotificationScheduler()
            let examDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
            mockUserService.examDate = examDate
            mockProgressService.overallReadiness = 40
            let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
            assert(sut.urgencyLevel == .high, "Expected high urgency for 7 days and 40% readiness")
        }
        
        // testUrgencyLevel_High_When5DaysEvenWith80Percent
        do {
            let mockUserService = MockUserService()
            let mockProgressService = MockProgressService()
            let mockNotificationScheduler = MockNotificationScheduler()
            let examDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
            mockUserService.examDate = examDate
            mockProgressService.overallReadiness = 80
            let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
            assert(sut.urgencyLevel == .high, "Expected high urgency for 5 days even with 80%")
        }
        
        // testUrgencyLevel_Normal_When21DaysAnd70Percent
        do {
            let mockUserService = MockUserService()
            let mockProgressService = MockProgressService()
            let mockNotificationScheduler = MockNotificationScheduler()
            let examDate = Calendar.current.date(byAdding: .day, value: 21, to: Date())!
            mockUserService.examDate = examDate
            mockProgressService.overallReadiness = 70
            let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
            assert(sut.urgencyLevel == .normal, "Expected normal urgency for 21 days and 70%")
        }
        
        // testExaminationStatus_Completed_WhenExamDatePassed
        do {
            let mockUserService = MockUserService()
            let mockProgressService = MockProgressService()
            let mockNotificationScheduler = MockNotificationScheduler()
            let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            mockUserService.examDate = pastDate
            let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
            assert(sut.examinationStatus == .completed, "Expected completed status when exam date passed")
            assert(sut.notificationMessage.contains("Glückwunsch"), "Expected congratulations message")
        }
        
        // testExaminationStatus_DoesNotUpdate_WhenExamDateIsNil
        do {
            let mockUserService = MockUserService()
            let mockProgressService = MockProgressService()
            let mockNotificationScheduler = MockNotificationScheduler()
            mockUserService.examDate = nil
            let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
            assert(sut.examinationStatus == .preparing, "Expected preparing status when exam date is nil")
        }
        
        // testRapidUpdates_OnlyFinalStateApplied
        do {
            let mockUserService = MockUserService()
            let mockProgressService = MockProgressService()
            let mockNotificationScheduler = MockNotificationScheduler()
            let examDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
            mockUserService.examDate = examDate
            for i in 1...5 {
                mockProgressService.overallReadiness = i * 10
            }
            let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
            assert(sut.readinessPct == 50, "Expected readiness to be 50, got \(sut.readinessPct)")
        }
        
        // testEnableReminder_ThrowsError_WhenSchedulerFails
        do {
            let mockUserService = MockUserService()
            let mockProgressService = MockProgressService()
            let mockNotificationScheduler = MockNotificationScheduler()
            mockNotificationScheduler.shouldThrow = true
            let sut = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
            let time = DateComponents(hour: 9, minute: 0)
            do {
                try await sut.enableReminder(at: time)
                assert(false, "Expected error to be thrown")
            } catch {
                assert(!sut.isReminderEnabled, "Expected reminder to not be enabled after error")
            }
        }
        
        // testLoadReminderState_RestoresPreviouslyEnabledReminder
        do {
            let mockUserService = MockUserService()
            let mockProgressService = MockProgressService()
            let mockNotificationScheduler = MockNotificationScheduler()
            mockNotificationScheduler.isPendingFlag = true
            let newViewModel = DailyReminderViewModel(userService: mockUserService, progressService: mockProgressService, notificationScheduler: mockNotificationScheduler)
            assert(newViewModel.isReminderEnabled, "Expected reminder to be enabled when pending flag is true")
        }
        
        print("\nResults: \(passed) passed, \(failed) failed")
    }
}