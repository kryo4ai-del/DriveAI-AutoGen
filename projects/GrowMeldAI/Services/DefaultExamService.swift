class DefaultExamService: ExamService {
    private let dataService: LocalDataService
    private let questionRepository: QuestionRepository
    private var sessionLocks: [UUID: NSLock] = [:]
    
    private func getLock(for sessionId: UUID) -> NSLock {
        if sessionLocks[sessionId] == nil {
            sessionLocks[sessionId] = NSLock()
        }
        return sessionLocks[sessionId]!
    }
    
    func submitAnswer(
        sessionId: UUID,
        questionId: UUID,
        answer: String
    ) async throws {
        let lock = getLock(for: sessionId)
        
        return try await lock.withLock {
            guard var session = dataService.fetchExamSession(id: sessionId) else {
                throw ExamError.sessionNotFound
            }
            
            // ✅ Prevent submission after exam ends
            guard session.endTime == nil else {
                throw ExamError.examAlreadyCompleted
            }
            
            session.answers[questionId] = answer
            try await dataService.saveExamSession(session)
        }
    }
    
    func completeExam(sessionId: UUID) async throws -> ExamResult {
        let lock = getLock(for: sessionId)
        
        return try await lock.withLock {
            guard var session = dataService.fetchExamSession(id: sessionId) else {
                throw ExamError.sessionNotFound
            }
            
            // ✅ Prevent double completion
            guard session.endTime == nil else {
                throw ExamError.examAlreadyCompleted
            }
            
            session.endTime = Date()
            try await dataService.saveExamSession(session)
            
            // Calculate result with locked data
            let result = calculateResult(for: session)
            return result
        }
    }
    
    private func calculateResult(for session: ExamSession) -> ExamResult {
        // Implementation...
    }
}

// Helper extension for NSLock
extension NSLock {
    func withLock<T>(_ block: () -> T) -> T {
        lock()
        defer { unlock() }
        return block()
    }
}