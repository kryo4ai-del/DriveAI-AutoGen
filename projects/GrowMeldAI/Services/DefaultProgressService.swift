class DefaultProgressService: ProgressService {
    private let dataService: LocalDataService
    @Published private(set) var cachedProgress: OverallProgress?
    private let updateSubject = PassthroughSubject<Void, Never>()
    
    func recordAnswer(
        questionId: UUID,
        isCorrect: Bool,
        category: String,
        timeSpent: TimeInterval
    ) async throws {
        let progress = UserProgress(
            id: UUID(),
            questionId: questionId,
            category: category,
            isCorrect: isCorrect,
            answeredAt: Date(),
            timeSpent: timeSpent
        )
        
        try await dataService.saveProgress(progress)
        
        // ✅ Invalidate cache & notify observers
        await MainActor.run {
            self.cachedProgress = nil
            self.updateSubject.send()
        }
    }
    
    func getOverallProgress() async -> OverallProgress {
        if let cached = cachedProgress { return cached }
        
        let allProgress = try? await dataService.fetchAllProgress()
        let correct = allProgress?.filter { $0.isCorrect }.count ?? 0
        
        let result = OverallProgress(
            totalQuestionsAnswered: allProgress?.count ?? 0,
            totalCorrect: correct,
            currentStreak: getCurrentStreak(from: allProgress ?? []),
            longestStreak: getLongestStreak(from: allProgress ?? []),
            categoryProgress: buildCategoryProgress(from: allProgress ?? []),
            lastStudyDate: allProgress?.map { $0.answeredAt }.max()
        )
        
        await MainActor.run {
            self.cachedProgress = result
        }
        
        return result
    }
}