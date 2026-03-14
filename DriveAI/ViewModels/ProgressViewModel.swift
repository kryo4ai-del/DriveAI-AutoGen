@MainActor
class ProgressViewModel: ObservableObject {
    @Published var categoryProgress: [String: ProgressSnapshot] = [:]
    @Published var userStats: UserStatistics = .default
    @Published var streak: LearningStreak = .default
    @Published var readiness: ExamReadiness = ExamReadiness(score: 0)
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let dataService: LocalDataService
    private var updateTask: Task<Void, Never>?
    
    init(dataService: LocalDataService = .shared) {
        self.dataService = dataService
        Task {
            await fetchAllProgress()
        }
    }
    
    func recordAnswer(categoryId: String, correct: Bool) {
        // Non-blocking update
        Task {
            do {
                let updated = try await dataService.updateProgress(
                    categoryId: categoryId,
                    correct: correct
                )
                await MainActor.run {
                    categoryProgress[categoryId] = updated
                    updateDerivedState()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save progress"
                }
            }
        }
    }
    
    func fetchAllProgress() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let stats = try await dataService.fetchUserStatistics()
            let streak = try await dataService.fetchLearningStreak()
            let readiness = try await dataService.calculateExamReadiness()
            
            await MainActor.run {
                userStats = stats
                self.streak = streak
                self.readiness = readiness
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load progress"
            }
        }
    }
    
    private func updateDerivedState() {
        readiness = ExamReadiness.calculate(from: categoryProgress)
        // Recalculate user stats aggregate
    }
}