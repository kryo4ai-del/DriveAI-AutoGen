// Services/Learning/LearningQueueService.swift

protocol LearningQueueServiceProtocol {
    func enqueue(_ sign: RecognizedSign, for category: ExamCategory) async throws
    func dequeue() async -> (sign: RecognizedSign, category: ExamCategory)?
    func getQueueStatus() async -> QueueStatus
}

enum QueueError: LocalizedError {
    case storageError(String)
    case queueFull
    case invalidCategory
    
    var errorDescription: String? {
        switch self {
        case .storageError(let msg): return "Speicherfehler: \(msg)"
        case .queueFull: return "Warteschlange voll (max 50 Schilder)"
        case .invalidCategory: return "Ungültige Kategorie"
        }
    }
}

struct QueueStatus {
    let count: Int
    let isFull: Bool
    let oldestTimestamp: Date?
}

@MainActor

// MARK: - Supporting Types

fileprivate struct QueueEntry: Codable {
    let id: UUID
    let sign: RecognizedSign
    let category: ExamCategory
    let timestamp: Date
    
    init(sign: RecognizedSign, category: ExamCategory) {
        self.id = UUID()
        self.sign = sign
        self.category = category
        self.timestamp = Date()
    }
}