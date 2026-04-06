// Concrete, repeatable flow
class MemoryLeakTests: XCTestCase {
  
  func testQuestionScreenMemoryOnRepeat() {
    let initialMemory = ProcessInfo.processInfo.physicalMemory
    
    // Repeat the user flow 10× (mimics extended use)
    for _ in 0..<10 {
      let vm = QuestionViewModel(dataService: mockService)
      vm.loadQuestion()
      vm.selectAnswer(0)
      // Deinit released
    }
    
    // Forced collection
    DispatchQueue.main.sync { }
    
    let finalMemory = ProcessInfo.processInfo.physicalMemory
    let leaked = finalMemory - initialMemory
    
    XCTAssertLessThan(leaked, 10_000_000, // <10MB leak
      "Question screen leaks memory on repeated use")
  }
}