// Services/ABTesting/Core/EventLogger.swift

protocol EventLogger: Sendable {
    /// Log event asynchronously without blocking caller
    func logAsync(_ event: ExperimentEvent)
}

actor EventLoggerImpl: EventLogger {
    private let abTestingService: ABTestingService
    private let eventQueue = DispatchQueue(
        label: "com.driveai.abtesting.eventlog",
        qos: .background
    )
    
    init(abTestingService: ABTestingService) {
        self.abTestingService = abTestingService
    }
    
    nonisolated func logAsync(_ event: ExperimentEvent) {
        Task {
            try? await self.abTestingService.logEvent(event)
        }
    }
}