@MainActor
final class EpisodicMemoryViewModel: ObservableObject {
    @Published var recentMemories: [EpisodicMemory] = []
    @Published var isLoading = false
    
    private let repository: EpisodicMemoryRepository
    
    init(repository: EpisodicMemoryRepository) {
        self.repository = repository
    }
    
    func loadRecentMemories(limit: Int = 20) {
        Task {
            isLoading = true
            defer { isLoading = false }
            let memories = await repository.fetchRecent(limit: limit)
            self.recentMemories = memories
        }
    }
}