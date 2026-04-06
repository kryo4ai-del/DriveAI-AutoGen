@MainActor
final class SpacedRepetitionViewModel: ObservableObject {
    @Published var selectedCategory: String?
    @Published var selectedUrgency: UrgencyLevel?
    
    private var filteredQueueTask: Task<Void, Never>?
    
    init(spacedRepetitionService: SpacedRepetitionService = .shared) {
        self.spacedRepetitionService = spacedRepetitionService
        
        // Debounce filter changes
        Publishers.CombineLatest($selectedCategory, $selectedUrgency)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.filteredQueueTask?.cancel()
                self?.filteredQueueTask = Task {
                    await self?.applyFilters()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func applyFilters() {
        var filtered = reviewQueue
        if let categoryId = selectedCategory {
            filtered = filtered.filter { $0.categoryId == categoryId }
        }
        if let urgency = selectedUrgency {
            filtered = filtered.filter { $0.urgencyLevel == urgency }
        }
        self.filteredQueue = filtered
    }
}