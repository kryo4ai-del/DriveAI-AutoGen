func testFetchUserProgressFailureWithMock() {
    // Arrange
    let expectation = XCTestExpectation(description: "Fetch failure")
    
    // Using a mocking technique (balance mock and observe actual)
    homeViewModel = MockedHomeViewModel() // This would be a subclass or a new class that simulates failures
    homeViewModel.fetchUserProgress()
    
    // Act
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        // Assert
        XCTAssertEqual(self.homeViewModel.errorMessage, "Fehler beim Laden des Fortschritts. Bitte versuchen Sie es erneut.")
        XCTAssertEqual(self.homeViewModel.userProgress.completedQuizzes, 0)
        XCTAssertFalse(self.homeViewModel.isLoading)
        expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 2)
}