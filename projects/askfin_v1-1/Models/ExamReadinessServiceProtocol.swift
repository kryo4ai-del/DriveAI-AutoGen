import Foundation

protocol ExamReadinessServiceProtocol: Sendable {
    func calculateOverallReadiness() async throws -> ExamReadinessScore
    func getCategoryReadiness() async throws -> [CategoryReadiness]
    func getWeakCategories(limit: Int) async throws -> [CategoryReadiness]
    func getTopCategories(limit: Int) async throws -> [CategoryReadiness]
    func recordDailySnapshot() async throws
    func getTrendData(days: Int) async throws -> [ReadinessTrendPoint]
    func getReadinessHistory() async throws -> [ExamReadinessScore]
}

// ✅ FIX: Removed actor isolation, using standard class for iOS services
@MainActor
class ExamReadinessService: ExamReadinessServiceProtocol {
    private let dataService: LocalDataServiceProtocol
    private let progressService: UserProgressServiceProtocol
    private let persistenceService: TrendPersistenceServiceProtocol
    
    // ✅ FIX: Caching to prevent redundant queries
    private var cachedCategoryReadiness: [CategoryReadiness]?
    private var cacheDate: Date?
    private let cacheTTL: TimeInterval = 300 // 5 minutes
    
    // Category weights for readiness calculation
    private let categoryWeights: [String: Double] = [
        "traffic_signs": 0.40,
        "right_of_way": 0.35,
        "safety": 0.25
    ]
    
    init(
        dataService: LocalDataServiceProtocol,
        progressService: UserProgressServiceProtocol,
        persistenceService: TrendPersistenceServiceProtocol
    ) {
        self.dataService = dataService
        self.progressService = progressService
        self.persistenceService = persistenceService
    }
    
    // MARK: - Main Calculation
    
    func calculateOverallReadiness() async throws -> ExamReadinessScore {
        let categories = try await getCategoryReadiness()
        
        guard !categories.isEmpty else {
            throw ExamReadinessError.noCategoryData(reason: "Keine Kategorien in DB")
        }
        
        let weightedScore = calculateWeightedScore(for: categories)
        let level = levelForScore(weightedScore)
        
        let weakCount = categories.filter { $0.strength == .weak }.count
        let strongCount = categories.filter { 
            $0.strength == .strong || $0.strength == .excellent 
        }.count
        let aboveThreshold = categories.filter { $0.percentage >= 70 }.count
        
        return ExamReadinessScore(
            overall: weightedScore,
            percentageInt: Int(weightedScore * 100),
            level: level,
            calculatedAt: .now,
            weakCategoryCount: weakCount,
            strongCategoryCount: strongCount,
            categoriesAboveThreshold: aboveThreshold
        )
    }
    
    // MARK: - Category Analysis
    
    func getCategoryReadiness() async throws -> [CategoryReadiness] {
        // ✅ FIX: Return cached data if fresh
        if let cached = cachedCategoryReadiness,
           let cacheDate = cacheDate,
           Date().timeIntervalSince(cacheDate) < cacheTTL {
            return cached
        }
        
        let categories = try await dataService.fetchAllCategories()
        
        guard !categories.isEmpty else {
            throw ExamReadinessError.noCategoryData(reason: "0 Kategorien in DB")
        }
        
        let readiness = try await withThrowingTaskGroup(
            of: CategoryReadiness.self,
            returning: [CategoryReadiness].self
        ) { group in
            for category in categories {
                group.addTask {
                    try await self.readinessForCategory(category)
                }
            }
            
            var results: [CategoryReadiness] = []
            for try await result in group {
                results.append(result)
            }
            
            guard !results.isEmpty else {
                throw ExamReadinessError.noCategoryData(
                    reason: "TaskGroup returned no results"
                )
            }
            
            return results.sorted { $0.name < $1.name }
        }
        
        // ✅ Cache the result
        self.cachedCategoryReadiness = readiness
        self.cacheDate = Date()
        
        return readiness
    }
    
    func getWeakCategories(limit: Int) async throws -> [CategoryReadiness] {
        let all = try await getCategoryReadiness()
        return all
            .filter { $0.strength == .weak || $0.strength == .moderate }
            .sorted { $0.percentage < $1.percentage }
            .prefix(limit)
            .map { $0 }
    }
    
    func getTopCategories(limit: Int) async throws -> [CategoryReadiness] {
        let all = try await getCategoryReadiness()
        return all
            .filter { $0.strength == .strong || $0.strength == .excellent }
            .sorted { $0.percentage > $1.percentage }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Trend Tracking
    
    func recordDailySnapshot() async throws {
        let score = try await calculateOverallReadiness()
        let categories = try await getCategoryReadiness()
        
        let trendPoint = ReadinessTrendPoint(
            date: .now,
            score: score.percentageInt,
            weakCategoryCount: categories.filter { $0.strength == .weak }.count
        )
        
        try await persistenceService.saveTrendPoint(trendPoint)
    }
    
    func getTrendData(days: Int) async throws -> [ReadinessTrendPoint] {
        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -days,
            to: .now
        ) ?? .now
        
        let allTrends = try await persistenceService.fetchTrendPoints()
        
        return allTrends
            .filter { $0.date >= cutoffDate }
            .sorted { $0.date < $1.date }
    }
    
    func getReadinessHistory() async throws -> [ExamReadinessScore] {
        let trends = try await getTrendData(days: 90)
        
        return trends.map { trend in
            ExamReadinessScore(
                overall: Double(trend.score) / 100.0,
                percentageInt: trend.score,
                level: levelForScore(Double(trend.score) / 100.0),
                calculatedAt: trend.date,
                weakCategoryCount: trend.weakCategoryCount,
                strongCategoryCount: 0,
                categoriesAboveThreshold: 0
            )
        }
    }
    
    // MARK: - Cache Invalidation
    
    func invalidateCache() {
        cachedCategoryReadiness = nil
        cacheDate = nil
    }
    
    // MARK: - Private Helpers
    
    private func readinessForCategory(_ category: Category) async throws -> CategoryReadiness {
        guard !category.id.isEmpty else {
            throw ExamReadinessError.invalidCategoryId("empty")
        }
        
        do {
            let stats = try await progressService.getCategoryStatistics(
                categoryId: category.id
            )
            
            let average = stats.totalQuestions > 0
                ? Double(stats.correctAnswers) / Double(stats.totalQuestions)
                : 0.0
            
            let strength = strengthForScore(average)
            
            return CategoryReadiness(
                id: category.id,
                name: category.name,
                icon: iconForCategory(category.id),
                totalQuestions: stats.totalQuestions,
                correctAnswers: stats.correctAnswers,
                averageScore: average,
                lastStudied: stats.lastAttemptDate,
                strength: strength
            )
        } catch {
            throw ExamReadinessError.noCategoryData(
                reason: "Fehler für \(category.id): \(error.localizedDescription)"
            )
        }
    }
    
    private func strengthForScore(_ score: Double) -> StrengthRating {
        switch score {
        case 0.85...: return .excellent
        case 0.70..<0.85: return .strong
        case 0.50..<0.70: return .moderate
        default: return .weak
        }
    }
    
    private func levelForScore(_ score: Double) -> ReadinessLevel {
        switch score {
        case 0.85...: return .excellent
        case 0.70..<0.85: return .ready
        case 0.50..<0.70: return .partiallyReady
        default: return .notReady
        }
    }
    
    private func calculateWeightedScore(for categories: [CategoryReadiness]) -> Double {
        let totalWeight = categoryWeights.values.reduce(0, +)
        var weightedScore = 0.0
        
        for category in categories {
            let weight = categoryWeights[category.id] ?? (1.0 / Double(categories.count))
            weightedScore += category.averageScore * weight
        }
        
        return weightedScore / max(totalWeight, 1.0)
    }
    
    private func iconForCategory(_ categoryId: String) -> String {
        switch categoryId {
        case let id where id.contains("traffic"): return "signpost.right"
        case let id where id.contains("right_of_way"): return "arrow.left.and.right"
        case let id where id.contains("safety"): return "heart.shield"
        default: return "book"
        }
    }
}