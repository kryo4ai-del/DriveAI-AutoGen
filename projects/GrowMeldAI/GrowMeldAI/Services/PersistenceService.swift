// Services/PersistenceService.swift
protocol PersistenceService {
    func saveQuizSession(_ session: QuizSession) throws
    func loadQuizSession(id: String) throws -> QuizSession?
    func deleteQuizSession(id: String) throws
}

// Implementation using JSON + Documents directory
final class LocalPersistenceService: PersistenceService {
    private let fileManager = FileManager.default
    private let sessionsURL: URL
    
    init() {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        sessionsURL = docs.appendingPathComponent("quiz_sessions")
        try? fileManager.createDirectory(at: sessionsURL, withIntermediateDirectories: true)
    }
    
    func saveQuizSession(_ session: QuizSession) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(session)
        
        let fileURL = sessionsURL.appendingPathComponent("\(session.id).json")
        try data.write(to: fileURL, options: .atomic)
    }
    
    func loadQuizSession(id: String) throws -> QuizSession? {
        let fileURL = sessionsURL.appendingPathComponent("\(id).json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(QuizSession.self, from: data)
    }
    
    func deleteQuizSession(id: String) throws {
        let fileURL = sessionsURL.appendingPathComponent("\(id).json")
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}

// In QuizStateManager
final class QuizStateManager {
    private var currentSession: QuizSession
    private let persistence: PersistenceService
    
    init(sessionID: String, persistence: PersistenceService) {
        self.persistence = persistence
        
        // Load persisted session or create new
        if let loaded = try? persistence.loadQuizSession(id: sessionID) {
            self.currentSession = loaded
        } else {
            self.currentSession = QuizSession(id: sessionID, startDate: Date())
        }
    }
    
    func recordAnswer(questionID: String, selectedOptionID: String, isCorrect: Bool) {
        let answer = QuestionAnswer(
            questionID: questionID,
            selectedOptionID: selectedOptionID,
            isCorrect: isCorrect,
            timestamp: Date()
        )
        currentSession.answers.append(answer)
        
        // Persist IMMEDIATELY (not async to avoid loss on crash)
        try? persistence.saveQuizSession(currentSession)
    }
}