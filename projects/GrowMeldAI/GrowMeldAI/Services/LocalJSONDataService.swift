@MainActor
final class LocalJSONDataService: DataService {
    @Published private(set) var isLoading = true
    private var questionCache: [Question] = []
    private var categoryCache: [Category] = []
    
    init() {
        Task {
            await loadCaches()
        }
    }
    
    private func loadCaches() async {
        // Offload to background thread
        let (questions, categories) = await Task.detached(priority: .userInitiated) {
            (Self.loadQuestions(), Self.loadCategories())
        }.value
        
        self.questionCache = questions
        self.categoryCache = categories
        self.isLoading = false
    }
    
    func fetchAllCategories() async -> [Category] {
        while isLoading {
            try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1s poll
        }
        return categoryCache
    }
}

// Update AppState to handle loading:
@MainActor
func loadProgress() async {
    if let service = dataService as? LocalJSONDataService {
        // Wait for data service to finish loading
        while service.isLoading {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
    let progress = await dataService.fetchUserProgress()
    self.categoryProgress = progress.categoryBreakdown
}