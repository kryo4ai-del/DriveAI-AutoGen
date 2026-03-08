func startFetchingLogs(every interval: TimeInterval = 2.0) {
    Timer.publish(every: interval, on: .main, in: .common)
        // rest of the implementation...
}

// ---

.receiveCompletion { completion in
    switch completion {
    case .failure(let error):
        // Handle the error, perhaps log it
    case .finished:
        break
    }
}

// ---

List(viewModel.debugLogs) { log in
   // Code...
}
.listStyle(PlainListStyle())

// ---

.flatMap { _ in
    self.debugDataService.retrieveDebugData()
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
}

// ---

func startFetchingLogs(every interval: TimeInterval = 2.0) {
    Timer.publish(every: interval, on: .main, in: .common)
        .autoconnect()
        .flatMap { _ in self.debugDataService.retrieveDebugData() }
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("Error fetching logs: \(error)")
            case .finished:
                break
            }
        }) { [weak self] logs in
            self?.debugLogs = logs
        }
        .store(in: &cancellables)
}

// ---

List(viewModel.debugLogs) { log in
   HStack {
       Text(log.timestamp, formatter: dateFormatter)
           .font(.footnote)
           .foregroundColor(.gray)
       Text(log.message)
           .font(.body)
           .foregroundColor(log.level == .error ? .red : .black)
   }
}
.listStyle(PlainListStyle())

// ---

.flatMap { _ in
    self.debugDataService.retrieveDebugData()
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
}

// ---

func testDebugInfoCreation() {
      let debugInfo = DebugInfo(timestamp: Date(), message: "Test Message", level: .info)
      XCTAssertNotNil(debugInfo.id)
      XCTAssertEqual(debugInfo.message, "Test Message")
      XCTAssertEqual(debugInfo.level, LogLevel.info)
  }

// ---

func testInitialDebugLogsState() {
      let viewModel = AnalysisDebugPanelViewModel()
      XCTAssertTrue(viewModel.debugLogs.isEmpty, "Debug logs should be initially empty.")
  }

// ---

func testAnalysisDebugPanelShowsLogs() {
      let viewModel = AnalysisDebugPanelViewModel(debugDataService: MockDebugDataService())
      let view = AnalysisDebugPanel()
      viewModel.startFetchingLogs(every: 0.1)

      let viewController = UIHostingController(rootView: view)
      let window = UIWindow(frame: UIScreen.main.bounds)
      window.rootViewController = viewController
      window.makeKeyAndVisible()
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          // Check the text for the first log in the List
          let logText = viewController.view.findSubview(ofType: UILabel.self)?.text
          XCTAssertEqual(logText, "Log 1", "First log text should be Log 1.")
      }
  }

// ---

func testDebugInfoCreation() {
    let debugInfo = DebugInfo(timestamp: Date(), message: "Test Message", level: .info)
    XCTAssertNotNil(debugInfo.id)
    XCTAssertEqual(debugInfo.message, "Test Message")
    XCTAssertEqual(debugInfo.level, LogLevel.info)
}

// ---

func testInitialDebugLogsState() {
    let viewModel = AnalysisDebugPanelViewModel()
    XCTAssertTrue(viewModel.debugLogs.isEmpty, "Debug logs should be initially empty.")
}

// ---

func testAnalysisDebugPanelShowsLogs() {
    let viewModel = AnalysisDebugPanelViewModel(debugDataService: MockDebugDataService())
    let view = AnalysisDebugPanel()
    viewModel.startFetchingLogs(every: 0.1)

    let viewController = UIHostingController(rootView: view)
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = viewController
    window.makeKeyAndVisible()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        // Check the text for the first log in the List
        let logText = viewController.view.findSubview(ofType: UILabel.self)?.text
        XCTAssertEqual(logText, "Log 1", "First log text should be Log 1.")
    }
}

// ---

func testDebugInfoCreation() {
    let debugInfo = DebugInfo(timestamp: Date(), message: "Test Message", level: .info)
    XCTAssertNotNil(debugInfo.id)
    XCTAssertEqual(debugInfo.message, "Test Message")
    XCTAssertEqual(debugInfo.level, LogLevel.info)
}

// ---

func testInitialDebugLogsState() {
    let viewModel = AnalysisDebugPanelViewModel()
    XCTAssertTrue(viewModel.debugLogs.isEmpty, "Debug logs should be initially empty.")
}

// ---

func testAnalysisDebugPanelShowsLogs() {
    let viewModel = AnalysisDebugPanelViewModel(debugDataService: MockDebugDataService())
    let view = AnalysisDebugPanel()
    
    // Start fetching logs before displaying the view.
    viewModel.startFetchingLogs(every: 0.1)

    let viewController = UIHostingController(rootView: view)
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = viewController
    window.makeKeyAndVisible()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        // Check the text for the first log in the List, if rendered correctly.
        let logText = viewController.view.findSubview(ofType: UILabel.self)?.text
        XCTAssertEqual(logText, "Log 1", "First log text should be Log 1.")
    }
}

// ---

func testDebugInfoCreation() {
    let debugInfo = DebugInfo(timestamp: Date(), message: "Test Message", level: .info)
    XCTAssertNotNil(debugInfo.id)
    XCTAssertEqual(debugInfo.message, "Test Message")
    XCTAssertEqual(debugInfo.level, LogLevel.info)
}

// ---

func testInitialDebugLogsState() {
    let viewModel = AnalysisDebugPanelViewModel()
    XCTAssertTrue(viewModel.debugLogs.isEmpty, "Debug logs should be initially empty.")
}

// ---

func testAnalysisDebugPanelShowsLogs() {
    let viewModel = AnalysisDebugPanelViewModel(debugDataService: MockDebugDataService())
    let view = AnalysisDebugPanel()
    
    // Start fetching logs before displaying the view.
    viewModel.startFetchingLogs(every: 0.1)

    let viewController = UIHostingController(rootView: view)
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = viewController
    window.makeKeyAndVisible()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        // Check the text for the first log in the List, if rendered correctly.
        let logText = viewController.view.findSubview(ofType: UILabel.self)?.text
        XCTAssertEqual(logText, "Log 1", "First log text should be Log 1.")
    }
}