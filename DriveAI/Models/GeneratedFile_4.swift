private func verifyUserProgressState(expectedProgress: UserProgress, isLoading: Bool, errorMessage: String?) {
         XCTAssertEqual(homeViewModel.userProgress, expectedProgress)
         XCTAssertEqual(homeViewModel.isLoading, isLoading)
         XCTAssertEqual(homeViewModel.errorMessage, errorMessage)
     }