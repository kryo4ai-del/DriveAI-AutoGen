// MARK: - Features/ExamReadiness/Services/CacheCoordinatorService.swift

import Foundation

/// ✅ Unified cache manager preventing snapshot/recommendation mismatch
actor CacheCoordinatorService: Sendable {
    private struct CacheSnapshot {
        let readiness: ExamReadinessSnapshot
        let recommendations: [StudyRecommendation]
        let expirationDate: Date
    }
    
    private var cache: CacheSnapshot?
    private let cacheValiditySeconds: TimeInterval = 300
    
    private let readinessService: ReadinessCalculationService
    private let recommendationService: RecommendationEngineService
    
    init(
        readinessService: ReadinessCalculationService,
        recommendationService: RecommendationEngineService
    ) {
        self.readinessService = readinessService
        self.recommendationService = recommendationService
    }
    
    /// ✅ Atomically load both snapshot and recommendations
    func loadCompleteReadinessPipeline(
        examDate: Date
    ) async throws -> (
        snapshot: ExamReadinessSnapshot,
        recommendations: [StudyRecommendation]
    ) {
        // Check cache validity
        if let cached = cache, Date() < cached.expirationDate {
            return (cached.readiness, cached.recommendations)
        }
        
        // Calculate snapshot
        let snapshot = try await readinessService.calculateReadiness(examDate: examDate)
        
        // Generate recommendations from SAME snapshot instance
        let recommendations = await recommendationService.generateRecommendations(
            snapshot: snapshot
        )
        
        // ✅ Cache atomically
        let cacheSnapshot = CacheSnapshot(
            readiness: snapshot,
            recommendations: recommendations,
            expirationDate: Date().addingTimeInterval(cacheValiditySeconds)
        )
        cache = cacheSnapshot
        
        return (snapshot, recommendations)
    }
    
    func invalidateCache() {
        cache = nil
    }
}