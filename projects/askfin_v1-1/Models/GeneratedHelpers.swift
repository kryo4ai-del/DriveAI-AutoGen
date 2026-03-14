// MARK: - ExamReadinessService (Actor Implementation)
// **FK-012 Fix:** Single authoritative service using Swift actor for thread safety
// Replaces conflicting class/actor implementations

import Foundation

/// Thread-safe service for exam readiness calculations.
/// Uses Swift `actor` isolation to prevent data races on cache mutations.
final actor ExamReadinessService: ExamReadinessServiceProtocol {
    
    // MARK: - Dependencies
    
    private let dataService: LocalDataServiceProtocol
    private let progressService: UserProgressServiceProtocol
    private let persistenceService: TrendPersistenceServiceProtocol
    
    // MARK: - Caching (Actor-isolated)
    
    private var cachedCategoryReadiness: [CategoryReadiness]?
    private var cacheDate: Date?
    private let cacheTTL: TimeInterval = 300 // 5 minutes
    
    // MARK: - Initialization
    
    init(
        dataService: LocalDataServiceProtocol,
        progressService: UserProgressServiceProtocol,
        persistenceService: TrendPersistenceServiceProtocol
    ) {
        self.dataService = dataService
        self.progressService = progressService
        self.persistenceService = persistenceService
    }
    
    // MARK: - Public API (nonisolated for cross-actor calls)
    
    nonisolated func calculateOverallReadiness() async throws -> ExamReadinessScore {
        let categories = try await getCategoryReadiness()
        return await computeOverallScore(from: categories)
    }
    
    nonisolated func getCategoryReadiness() async throws -> [CategoryReadiness] {
        let cached = await getValidCache()
        if let cached = cached {
            return cached
        }
        
        let categories = try await fetchCategoryReadiness()
        await setCache(categories)
        return categories
    }
    
    nonisolated func getWeakCategories(limit: Int) async throws -> [CategoryReadiness] {
        let all = try await getCategoryReadiness()
        return all
            .filter { $0.strength == .weak }
            .sorted { $0.percentage < $1.percentage }
            .prefix(limit)
            .Array
    }
    
    func recordDailySnapshot() async throws {
        let score = try await calculateOverallReadiness()
        let trendPoint = ReadinessTrendPoint(
            date: Date(),
            score: score.percentageInt,
            level: score.level
        )
        try await persistenceService.saveTrendPoint(trendPoint)
    }
    
    nonisolated func getTrendData(days: Int) async throws -> [ReadinessTrendPoint] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let allPoints = try await persistenceService.fetchTrendPoints()
        return allPoints.filter { $0.date >= cutoffDate }
    }
    
    // MARK: - Private Helpers (Actor-isolated)
    
    private func fetchCategoryReadiness() async throws -> [CategoryReadiness] {
        let categories = try await dataService.fetchAllCategories()
        
        return try await withThrowingTaskGroup(of: CategoryReadiness.self) { group in
            for category in categories {
                group.addTask {
                    let progress = try await self.progressService.getProgress(
                        categoryId: category.id
                    )
                    return self.buildCategoryReadiness(from: category, progress: progress)
                }
            }
            
            var results: [CategoryReadiness] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
    
    private func buildCategoryReadiness(
        from category: Category,
        progress: UserProgress
    ) -> CategoryReadiness {
        let percentage = progress.totalQuestions > 0
            ? (Double(progress.correctAnswers) / Double(progress.totalQuestions))
            : 0.0
        
        let strength = StrengthRating(percentage: percentage)
        
        return CategoryReadiness(
            id: category.id,
            name: category.name,
            totalQuestions: progress.totalQuestions,
            correctAnswers: progress.correctAnswers,
            averageScore: percentage,
            lastStudied: progress.lastStudiedDate,
            strength: strength,
            recommendedFocusLevel: computeFocusLevel(for: percentage)
        )
    }
    
    private func computeOverallScore(from categories: [CategoryReadiness]) -> ExamReadinessScore {
        guard !categories.isEmpty else {
            return ExamReadinessScore(
                overall: 0.0,
                percentageInt: 0,
                level: .notReady,
                calculatedAt: Date(),
                weakCategoryCount: 0,
                categoriesAboveThreshold: 0
            )
        }
        
        let weights = computeWeights(for: categories)
        let weightedAverage = categories.enumerated().reduce(0.0) { sum, item in
            sum + (item.element.averageScore * weights[item.offset])
        }
        
        let percentageInt = Int(weightedAverage * 100)
        let level = ReadinessLevel(percentage: percentageInt)
        let weakCount = categories.filter { $0.strength == .weak }.count
        let aboveThreshold = categories.filter { $0.percentage >= 70 }.count
        
        return ExamReadinessScore(
            overall: weightedAverage,
            percentageInt: percentageInt,
            level: level,
            calculatedAt: Date(),
            weakCategoryCount: weakCount,
            categoriesAboveThreshold: aboveThreshold
        )
    }
    
    // MARK: - Cache Management
    
    private func getValidCache() async -> [CategoryReadiness]? {
        guard let cacheDate = cacheDate,
              let cached = cachedCategoryReadiness,
              Date().timeIntervalSince(cacheDate) < cacheTTL else {
            return nil
        }
        return cached
    }
    
    private func setCache(_ categories: [CategoryReadiness]) async {
        self.cachedCategoryReadiness = categories
        self.cacheDate = Date()
    }
    
    // MARK: - Computation Helpers
    
    private func computeWeights(for categories: [CategoryReadiness]) -> [Double] {
        // Equal weight by default; customize by category importance if needed
        let baseWeight = 1.0 / Double(categories.count)
        return Array(repeating: baseWeight, count: categories.count)
    }
    
    private func computeFocusLevel(for percentage: Double) -> Int {
        switch percentage {
        case 0..<0.3: return 5   // Urgent
        case 0.3..<0.5: return 4 // High
        case 0.5..<0.7: return 3 // Medium
        case 0.7..<0.9: return 2 // Low
        default: return 1        // Maintenance
        }
    }
}

// ---

final actor ExamReadinessService: ExamReadinessServiceProtocol {
    private let dataService: LocalDataServiceProtocol
    private let progressService: UserProgressServiceProtocol
    private let persistenceService: TrendPersistenceServiceProtocol
    
    private var cachedCategoryReadiness: [CategoryReadiness]?
    private var cacheDate: Date?
    private let cacheTTL: TimeInterval = 300
    
    init(
        dataService: LocalDataServiceProtocol,
        progressService: UserProgressServiceProtocol,
        persistenceService: TrendPersistenceServiceProtocol
    ) {
        self.dataService = dataService
        self.progressService = progressService
        self.persistenceService = persistenceService
    }
    
    nonisolated func calculateOverallReadiness() async throws -> ExamReadinessScore {
        let categories = try await getCategoryReadiness()
        return await computeOverallScore(from: categories)
    }
    
    nonisolated func getCategoryReadiness() async throws -> [CategoryReadiness] {
        let cached = await getValidCache()
        if let cached = cached { return cached }
        
        let categories = try await fetchCategoryReadiness()
        await setCache(categories)
        return categories
    }
    
    nonisolated func getWeakCategories(limit: Int) async throws -> [CategoryReadiness] {
        let all = try await getCategoryReadiness()
        return all
            .filter { $0.strength == .weak }
            .sorted { $0.percentage < $1.percentage }
            .prefix(limit)
            .Array
    }
    
    func recordDailySnapshot() async throws {
        let score = try await calculateOverallReadiness()
        let point = ReadinessTrendPoint(
            date: Date(),
            score: score.percentageInt,
            level: score.level
        )
        try await persistenceService.saveTrendPoint(point)
    }
    
    nonisolated func getTrendData(days: Int) async throws -> [ReadinessTrendPoint] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let all = try await persistenceService.fetchTrendPoints()
        return all.filter { $0.date >= cutoff }
    }
    
    // MARK: - Private Helpers
    
    private func fetchCategoryReadiness() async throws -> [CategoryReadiness] {
        let categories = try await dataService.fetchAllCategories()
        return try await withThrowingTaskGroup(of: CategoryReadiness.self) { group in
            for category in categories {
                group.addTask {
                    let progress = try await self.progressService.getProgress(
                        categoryId: category.id
                    )
                    return self.buildCategoryReadiness(from: category, progress: progress)
                }
            }
            var results: [CategoryReadiness] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
    
    private func buildCategoryReadiness(
        from category: Category,
        progress: UserProgress
    ) -> CategoryReadiness {
        let percentage = progress.totalQuestions > 0
            ? Double(progress.correctAnswers) / Double(progress.totalQuestions)
            : 0.0
        
        return CategoryReadiness(
            id: category.id,
            name: category.name,
            totalQuestions: progress.totalQuestions,
            correctAnswers: progress.correctAnswers,
            averageScore: percentage,
            lastStudied: progress.lastStudiedDate,
            strength: StrengthRating(percentage: percentage),
            recommendedFocusLevel: computeFocusLevel(for: percentage)
        )
    }
    
    private func computeOverallScore(from categories: [CategoryReadiness]) -> ExamReadinessScore {
        guard !categories.isEmpty else {
            return ExamReadinessScore(
                overall: 0.0,
                percentageInt: 0,
                level: .notReady,
                calculatedAt: Date(),
                weakCategoryCount: 0,
                categoriesAboveThreshold: 0
            )
        }
        
        let weighted = categories.reduce(0.0) { $0 + ($1.averageScore / Double(categories.count)) }
        let percentageInt = Int(weighted * 100)
        let level = ReadinessLevel(percentage: percentageInt)
        
        return ExamReadinessScore(
            overall: weighted,
            percentageInt: percentageInt,
            level: level,
            calculatedAt: Date(),
            weakCategoryCount: categories.filter { $0.strength == .weak }.count,
            categoriesAboveThreshold: categories.filter { $0.percentage >= 70 }.count
        )
    }
    
    private func getValidCache() async -> [CategoryReadiness]? {
        guard let cacheDate = cacheDate,
              let cached = cachedCategoryReadiness,
              Date().timeIntervalSince(cacheDate) < cacheTTL else {
            return nil
        }
        return cached
    }
    
    private func setCache(_ categories: [CategoryReadiness]) async {
        self.cachedCategoryReadiness = categories
        self.cacheDate = Date()
    }
    
    private func computeFocusLevel(for percentage: Double) -> Int {
        switch percentage {
        case 0..<0.3: return 5
        case 0.3..<0.5: return 4
        case 0.5..<0.7: return 3
        case 0.7..<0.9: return 2
        default: return 1
        }
    }
}