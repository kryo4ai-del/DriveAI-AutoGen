// Define as state machine (code-of-truth)
enum NavigationState {
  case onboarding
  case home
  case question(categoryID: Int)
  case exam(mode: ExamMode)
  case results(score: Int)
  case profile
}

// Define valid transitions
let validTransitions: [NavigationState: [NavigationState]] = [
  .onboarding: [.home],
  .home: [.question, .exam, .profile],
  .question: [.home, .results],
  .exam: [.home, .results],  // Can't skip to question mid-exam
  .results: [.home, .profile],
  .profile: [.home]
]

// XCTest: Verify no invalid transitions exist
func testNavigationOnlyAllowsValidTransitions() {
  for (from, toList) in validTransitions {
    for to in toList {
      let vm = AppNavigationViewModel(from: from)
      XCTAssertTrue(vm.canNavigate(to: to))
    }
  }
}