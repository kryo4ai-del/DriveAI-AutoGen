// Features/EpisodicalMemory/Tests/EpisodicalMemoryViewModelTests.swift

import XCTest
import Combine
@testable import DriveAI

final class EpisodicalMemoryViewModelTests: XCTestCase {
    var viewModel: EpisodicalMemoryViewModel!
    var mockService: MockEpisodicalMemoryService!
    var mockSpacedRecall: MockSpacedRecallTask!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockEpisodicalMemoryService()
        mockSpacedRecall = MockSpacedRecallTask()
        viewModel = EpisodicalMemoryViewModel(
            memoryService: mockService,
            spacedRecallTask: mockSpacedRecall
        )
        cancellables = []
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        mockService = nil
        mockSpacedRecall = nil
        cancellables = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_init_setsInitialState() {
        XCTAssertEqual(viewModel.memories, [])
        XCTAssertEqual(viewModel.filteredMemories, [])
        XCTAssertNil(viewModel.selectedMemory)
        XCTAssertEqual(viewModel.filterState, MemoryFilterState())
        XCTAssertEqual(viewModel.uiState, .idle)
        XCTAssertEqual(viewModel.dueForReviewCount, 0)
    }
    
    func test_init_doesNotLeakMemory() {
        weak var weakViewModel: EpisodicalMemoryViewModel? = viewModel
        viewModel = nil
        XCTAssertNil(weakViewModel, "ViewModel should deallocate")
    }
    
    func test_bindings_setupCorrectly() {
        let expectation = expectation(description: "Bindings fire on init")
        expectation.expectedFulfillmentCount = 1
        
        var receivedMemories: [Memory] = []
        viewModel.$memories
            .dropFirst()
            .sink { memories in
                receivedMemories = memories
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let testMemories = [Memory.fixture()]
        mockService.memoriesSubject.send(testMemories)
        
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedMemories, testMemories)
    }
}