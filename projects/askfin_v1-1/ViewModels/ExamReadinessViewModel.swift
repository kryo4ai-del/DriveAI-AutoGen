import Combine
@MainActor
final class ExamReadinessViewModel: ObservableObject {
    @Published private(set) var readinessScore: ExamReadinessScore?
    @Published private(set) var categoryReadiness: [CategoryReadiness] = []
    @Published private(set) var weakCategories: [CategoryReadiness] = []
    @Published private(set) var trendData: [ReadinessTrendPoint] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var showRetryButton = false
    
    private let service: ExamReadinessServiceProtocol
    private var loadTask: Task<Void, Never>?
    
    init(service: ExamReadinessServiceProtocol) {
        self.service = service
    }
    
    deinit {
        loadTask?.cancel()
    }
    
    func loadReadiness() {
        loadTask?.cancel()
        loadTask = Task {
            await performLoad()
        }
    }
    
    func refresh() {
        loadReadiness()
    }
    
    func retryAfterError() {
        error = nil
        showRetryButton = false
        loadReadiness()
    }
    
    private func performLoad() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let scoreTask = service.calculateOverallReadiness()
            async let categoriesTask = service.getCategoryReadiness()
            async let weakTask = service.getWeakCategories(limit: 5)
            async let trendTask = service.getTrendData(days: 30)
            
            let (score, categories, weak, trend) = try await (
                scoreTask,
                categoriesTask,
                weakTask,
                trendTask
            )
            
            self.readinessScore = score
            self.categoryReadiness = categories
            self.weakCategories = weak
            self.trendData = trend
            self.error = nil
            self.showRetryButton = false
            
        } catch {
            self.error = error
            self.showRetryButton = true
        }
    }
}