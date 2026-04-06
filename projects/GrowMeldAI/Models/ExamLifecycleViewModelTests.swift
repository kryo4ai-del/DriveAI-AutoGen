// Tests/ViewModels/ExamLifecycleViewModelTests.swift
import XCTest
import Combine
@testable import DriveAI

class ExamLifecycleViewModelTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable> = []
    var mockUserProfileService: MockUserProfileService!
    var viewModel: ExamLifecycleViewModel!
    
    override func setUp() {
        super.setUp()
        mockUserProfileService = MockUserProfileService()
        viewModel = ExamLifecycleViewModel(userProfileService: mockUserProfileService)
    }
    
    override func tearDown() {
        viewModel.stopMonitoring()
        cancellables.removeAll()
        super.tearDown()
    }
    
    // ✅ HAPPY PATH: Initializes with early prep stage
    func test_initialization_with_future_exam_date() {
        let futureDate = Date().addingTimeInterval(60 * 60 * 24 * 45)  // 45 days
        mockUserProfileService.scheduledExamDate = futureDate
        
        viewModel = ExamLifecycleViewModel(userProfileService: mockUserProfileService)
        
        XCTAssertEqual(viewModel.currentStage, .earlyPrep)
        XCTAssertEqual(viewModel.daysUntilExam, 45)
    }
    
    // ✅ BEHAVIOR: Updates stage when exam date changes
    func test_updates_stage_on_exam_date_change() {
        let expectation = XCTestExpectation(description: "Stage updated")
        
        viewModel.$currentStage
            .dropFirst()
            .sink { stage in
                XCTAssertEqual(stage, .midStudy)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Change exam date to 10 days away
        let futureDate = Date().addingTimeInterval(60 * 60 * 24 * 10)
        mockUserProfileService.scheduledExamDate = futureDate
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // ✅ EDGE CASE: Exam date in past (exam passed)
    func test_handles_past_exam_date() {
        let pastDate = Date().addingTimeInterval(-60 * 60 * 24 * 5)  // 5 days ago
        mockUserProfileService.scheduledExamDate = pastDate
        
        viewModel = ExamLifecycleViewModel(userProfileService: mockUserProfileService)
        
        XCTAssertEqual(viewModel.daysUntilExam, 0)  // Never negative
        XCTAssertEqual(viewModel.currentStage, .finalCramming)
    }
    
    // ✅ EDGE CASE: No exam date set
    func test_no_exam_date_set() {
        mockUserProfileService.scheduledExamDate = nil
        
        viewModel = ExamLifecycleViewModel(userProfileService: mockUserProfileService)
        
        XCTAssertNil(viewModel.examDate)
        XCTAssertEqual(viewModel.daysUntilExam, 0)
    }
    
    // ✅ MEMORY: Cleanup on deinit
    func test_stops_monitoring_on_deinit() {
        var viewModel: ExamLifecycleViewModel? = 
            ExamLifecycleViewModel(userProfileService: mockUserProfileService)
        
        XCTAssertNotNil(viewModel)
        viewModel?.stopMonitoring()
        viewModel = nil
        
        XCTAssertNil(viewModel)
    }
}