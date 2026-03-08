class OnboardingViewModelTests: XCTestCase {
       func testSaveUserDataWithMockData() {
           let mockUser = User(examDate: Date())
           let viewModel = OnboardingViewModel()
           viewModel.examDate = mockUser.examDate

           viewModel.saveUserData()

           // Validate behavior
           let data = UserDefaults.standard.data(forKey: "userData")
           XCTAssertNotNil(data, "User data should persist after saving.")
       }
   }