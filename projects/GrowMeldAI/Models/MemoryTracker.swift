@MainActor
class MemoryTracker: ObservableObject {
    static let shared = MemoryTracker()
    
    private let memoryService: MemoryService
    private var subscriptions = Set<AnyCancellable>()
    
    private init(memoryService: MemoryService = MemoryService()) {
        self.memoryService = memoryService
    }
    
    func captureAnswerEvent(questionID: String, categoryID: String, 
                           isCorrect: Bool, userConfidence: Int) async {
        // Don't block UI
        Task.detached(priority: .background) { [weak self] in
            let memory = EpisodicMemory(
                id: UUID(),
                timestamp: Date(),
                type: isCorrect ? .correctAnswer : .attempted,
                questionID: questionID,
                categoryID: categoryID,
                emotionalTag: nil,
                isPrivate: false,
                synapsStrength: self?.calculateSynapse(isCorrect, userConfidence) ?? 50
            )
            try? await self?.memoryService.recordMemory(memory)
        }
    }
}