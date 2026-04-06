import Foundation

protocol EventLogger: Sendable {
    func logAsync(_ event: ExperimentEvent)
}

actor EventLoggerImpl: EventLogger {
    private let abTestingService: ABTestingService

    init(abTestingService: ABTestingService) {
        self.abTestingService = abTestingService
    }

    nonisolated func logAsync(_ event: ExperimentEvent) {
        Task {
            await EventLoggerImpl.log(event: event, service: abTestingService)
        }
    }

    private static func log(event: ExperimentEvent, service: ABTestingService) async {
        try? await service.logEvent(event)
    }
}