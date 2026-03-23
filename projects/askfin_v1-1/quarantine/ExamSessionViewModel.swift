import Combine
import SwiftUI
@MainActor
final class ExamSessionViewModel: BaseViewModel {
    @StateObject private var timerService: ExamTimerService
    @Published var session: ExamSession
    private let examSessionService: ExamSessionService

    init(session: ExamSession, examSessionService: ExamSessionService) {
        self.examSessionService = examSessionService
        self.session = session
        _timerService = StateObject(wrappedValue: ExamTimerService(sessionStartTime: session.startTime))
        super.init()
    }
    
    func startExam() {
        timerService.start { [weak self] in
            Task { await self?.handleTimeExpired() }
        }
    }
    
    private func handleTimeExpired() async {
        timerService.pause()
        var localSession = session
        try? await examSessionService.completeExamSession(&localSession)
        session = localSession
        // Navigate to results
    }
}