@MainActor
class MemoryTimelineViewModel: ObservableObject {
    @Published var memories: [EpisodicMemory] = []
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var weekOffset = 0
    
    private let memoryService: MemoryService
    
    init(memoryService: MemoryService = MemoryService()) {
        self.memoryService = memoryService
    }
    
    func loadWeek() async {
        isLoading = true
        let startDate = Calendar.current.date(byAdding: .day, value: weekOffset * 7, to: Date())!
        
        do {
            memories = try await memoryService.getTimelineForWeek(startDate)
        } catch {
            self.error = AppError(error)
        }
        isLoading = false
    }
}