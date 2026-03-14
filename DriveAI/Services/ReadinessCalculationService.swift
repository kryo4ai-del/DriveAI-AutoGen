@MainActor
class ReadinessCalculationService {
    let dataService: LocalDataService
    
    private var calculationCache: [String: CategoryReadiness] = [:]
    private var cacheTimestamp: Date = .distantPast
    
    private let cacheValiditySeconds: TimeInterval = 300
    
    func calculateCategoryReadiness(
        categoryId: String,
        useCache: Bool = true
    ) -> CategoryReadiness {
        // ✅ Check cache first
        if useCache,
           let cached = calculationCache[categoryId],
           Date().timeIntervalSince(cacheTimestamp) < cacheValiditySeconds {
            return cached
        }
        
        let category = dataService.getCategory(categoryId)
        let answers = dataService.getUserAnswers(for: categoryId)
        let correctCount = answers.filter(\.isCorrect).count
        
        let result = CategoryReadiness(
            categoryId: categoryId,
            categoryName: category?.name ?? categoryId,
            correctAnswers: correctCount,
            totalQuestions: answers.count
        )
        
        calculationCache[categoryId] = result
        return result
    }
    
    func generateFullReport(forceRefresh: Bool = false) -> ExamReadinessReport {
        let allCategories = dataService.getAllCategories()
        
        // ✅ Batch calculation with cache
        let categoryReadiness = allCategories.map { category in
            calculateCategoryReadiness(categoryId: category.id, useCache: !forceRefresh)
        }
        
        let overallScore = categoryReadiness.isEmpty ? 0 :
            (categoryReadiness.map(\.percentage).reduce(0, +) / categoryReadiness.count)
        
        cacheTimestamp = Date()
        return ExamReadinessReport(
            overallScore: overallScore,
            categoryBreakdown: categoryReadiness
        )
    }
    
    func clearCache() {
        calculationCache.removeAll()
        cacheTimestamp = .distantPast
    }
}