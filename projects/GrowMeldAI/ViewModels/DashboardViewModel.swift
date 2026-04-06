@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var userProgress: UserProgress?
    @Published var isLoading = false
    @Published var error: AppError?
    
    let regionManager: RegionManager
    let dataService: QuestionRepository
    
    init(regionManager: RegionManager, dataService: QuestionRepository) {
        self.regionManager = regionManager
        self.dataService = dataService
    }
    
    func loadDashboard() async {
        isLoading = true
        do {
            let questions = try await dataService.loadQuestions(for: regionManager.currentRegion)
            self.categories = groupByCategory(questions)
            self.userProgress = await fetchProgress(for: regionManager.currentRegion)
        } catch {
            self.error = AppError.from(error)
        }
        isLoading = false
    }
}