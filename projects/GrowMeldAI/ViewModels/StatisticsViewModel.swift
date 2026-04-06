class StatisticsViewModel: ObservableObject {
    @Published var statistics: UserStatistics?
    @Published var selectedCategory: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let statsService: StatisticsCalculationServiceProtocol
    
    init(statsService: StatisticsCalculationServiceProtocol) {
        self.statsService = statsService
    }
    
    @MainActor
    func loadStatistics() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            statistics = try await statsService.getStatistics()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    var categoryStats: [UserStatistics.CategoryStats] {
        statistics?.categoryBreakdown.values.sorted { $0.questionsAnswered > $1.questionsAnswered } ?? []
    }
}