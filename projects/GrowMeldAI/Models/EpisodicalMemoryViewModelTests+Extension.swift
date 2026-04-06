extension EpisodicalMemoryViewModelTests {
    
    // MARK: - addMemory Tests
    
    func test_addMemory_callsService() {
        let memory = Memory.fixture()
        let expectation = expectation(description: "Service called")
        
        mockService.onAddMemory = { addedMemory in
            XCTAssertEqual(addedMemory.id, memory.id)
            expectation.fulfill()
        }
        
        viewModel.addMemory(memory)
        waitForExpectations(timeout: 1.0)
    }
    
    func test_addMemory_showsToastOnSuccess() {
        let memory = Memory.fixture()
        mockService.addSuccess = true
        
        let expectation = expectation(description: "Toast shown")
        
        viewModel.$toastMessage
            .dropFirst()
            .sink { message in
                if message != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.addMemory(memory)
        waitForExpectations(timeout: 1.0)
        
        XCTAssertNotNil(viewModel.toastMessage)
    }
    
    func test_addMemory_withError_showsErrorToast() {
        let memory = Memory.fixture()
        let testError = NSError(domain: "test", code: -1, userInfo: nil)
        mockService.addError = testError
        
        let expectation = expectation(description: "Error shown")
        
        viewModel.$uiState
            .dropFirst()
            .sink { state in
                if case .error = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.addMemory(memory)
        waitForExpectations(timeout: 1.0)
    }
    
    func test_addMemory_errorAutoRecovery() {
        let memory = Memory.fixture()
        let testError = NSError(domain: "test", code: -1, userInfo: nil)
        mockService.addError = testError
        
        let expectation = expectation(description: "Error recovered")
        expectation.expectedFulfillmentCount = 2
        
        var stateSequence: [UIState] = []
        viewModel.$uiState
            .dropFirst()
            .sink { state in
                stateSequence.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.addMemory(memory)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertTrue(stateSequence.contains(where: { if case .error = $0 { return true } else { return false } }))
        XCTAssertEqual(stateSequence.last, .success)
    }
    
    // MARK: - deleteMemory Tests
    
    func test_deleteMemory_callsService() {
        let memory = Memory.fixture()
        let expectation = expectation(description: "Service called")
        
        mockService.onDeleteMemory = { deletedMemory in
            XCTAssertEqual(deletedMemory.id, memory.id)
            expectation.fulfill()
        }
        
        viewModel.deleteMemory(memory)
        waitForExpectations(timeout: 1.0)
    }
    
    func test_deleteMemory_showsToastOnSuccess() {
        let memory = Memory.fixture()
        mockService.deleteSuccess = true
        
        let expectation = expectation(description: "Toast shown")
        
        viewModel.$toastMessage
            .dropFirst()
            .sink { message in
                if message != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.deleteMemory(memory)
        waitForExpectations(timeout: 1.0)
    }
    
    // MARK: - markAsMastered Tests
    
    func test_markAsMastered_setsFlag() {
        let memory = Memory.fixture()
        let expectation = expectation(description: "Memory updated")
        
        mockService.onUpdateMemory = { updated in
            XCTAssertTrue(updated.isMastered)
            expectation.fulfill()
        }
        
        viewModel.markAsMastered(memory)
        waitForExpectations(timeout: 1.0)
    }
    
    func test_markAsMastered_showsToast() {
        let memory = Memory.fixture()
        mockService.updateSuccess = true
        
        let expectation = expectation(description: "Toast shown")
        
        viewModel.$toastMessage
            .dropFirst()
            .sink { message in
                if message != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.markAsMastered(memory)
        waitForExpectations(timeout: 1.0)
    }
    
    // MARK: - addNote Tests
    
    func test_addNote_updatesMemory() {
        let memory = Memory.fixture()
        let note = "Wichtig: Dieses Verkehrszeichen immer verwechselt"
        let expectation = expectation(description: "Memory updated")
        
        mockService.onUpdateMemory = { updated in
            XCTAssertEqual(updated.userNote, note)
            expectation.fulfill()
        }
        
        viewModel.addNote(note, to: memory)
        waitForExpectations(timeout: 1.0)
    }
    
    func test_addNote_setsLastReviewedDate() {
        let memory = Memory.fixture()
        let beforeDate = Date()
        let expectation = expectation(description: "Memory updated")
        
        mockService.onUpdateMemory = { updated in
            XCTAssertNotNil(updated.lastReviewedAt)
            expectation.fulfill()
        }
        
        viewModel.addNote("Test note", to: memory)
        waitForExpectations(timeout: 1.0)
    }
}