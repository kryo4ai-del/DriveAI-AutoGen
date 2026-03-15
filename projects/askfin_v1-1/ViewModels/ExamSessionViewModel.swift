@MainActor
final class ExamSessionViewModel: BaseViewModel {
    @StateObject private var timerService: ExamTimerService
    @Published var session: ExamSession
    
    init(session: ExamSession, /* ... */) {
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
        try? await examSessionService.completeExamSession(&session)
        // Navigate to results
    }
}