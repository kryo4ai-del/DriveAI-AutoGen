// ViewModels/DiagnosticsViewModel.swift
import Foundation
import Combine

/// ViewModel for the diagnostics system
final class DiagnosticsViewModel: ObservableObject {
    @Published var currentDiagnosis: LearningDiagnosis?
    @Published var topRecommendations: [RecommendedStudyPath] = []
    @Published var performanceMetrics: [String: PerformanceMetrics] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let analyzer: PerformanceAnalyzer
    private let recommendationEngine: RecommendationEngine
    private let storage: AnalyticsStorageProtocol
    private var cancellables = Set<AnyCancellable>()
    private let cache = DiagnosticsCache()

    init(analyzer: PerformanceAnalyzer,
         recommendationEngine: RecommendationEngine,
         storage: AnalyticsStorageProtocol) {
        self.analyzer = analyzer
        self.recommendationEngine = recommendationEngine
        self.storage = storage
    }

    /// Loads the current diagnosis
    @MainActor
    func loadDiagnosis() async {
        isLoading = true
        errorMessage = nil

        do {
            // Check cache first
            if let cached = cache.getCachedDiagnosis(), !cache.isExpired {
                currentDiagnosis = cached
                topRecommendations = cache.getCachedRecommendations()
                isLoading = false
                return
            }

            // Calculate performance metrics
            var metricsDict = [String: PerformanceMetrics]()
            for category in Category.allCases {
                let metrics = try await analyzer.aggregatePerformance(for: category)
                metricsDict[category.rawValue] = metrics
            }

            // Identify weak areas
            let weakAreas = try await analyzer.identifyWeakAreas()

            // Calculate overall progress
            let totalAccuracy = metricsDict.values.map { $0.accuracy }.reduce(0, +) / Double(metricsDict.count)
            let progress = totalAccuracy

            // Generate diagnosis
            let diagnosis = LearningDiagnosis(
                weakAreas: weakAreas,
                confidenceScores: metricsDict.mapValues { $0.accuracy },
                suggestedFocus: weakAreas.first?.displayName ?? "Alles gut!",
                progressTowardMastery: progress
            )

            // Generate recommendations
            let recommendations = try await recommendationEngine.generateRecommendations()

            // Update state
            currentDiagnosis = diagnosis
            topRecommendations = Array(recommendations.prefix(3))
            performanceMetrics = metricsDict

            // Cache results
            cache.cache(diagnosis: diagnosis, recommendations: recommendations)

        } catch {
            errorMessage = "Fehler beim Laden der Diagnose: \(error.localizedDescription)"
            print("DiagnosticsViewModel error: \(error)")
        }

        isLoading = false
    }

    /// Tracks a completed question and updates diagnostics
    @MainActor
    func trackQuestionCompleted(_ result: QuestionResult) async {
        do {
            try await storage.saveResult(result)

            // Invalidate cache
            cache.invalidate()

            // Reload diagnosis
            await loadDiagnosis()
        } catch {
            errorMessage = "Fehler beim Speichern des Ergebnisses: \(error.localizedDescription)"
        }
    }

    /// Acknowledges a diagnosis (removes from unread state)
    func acknowledgeDiagnosis() {
        // In a real app, this would update a backend or local read state
        // For now, we'll just clear any error state
        errorMessage = nil
    }
}

/// Cache for diagnostics data
private final class DiagnosticsCache {
    private var cachedDiagnosis: LearningDiagnosis?
    private var cachedRecommendations: [RecommendedStudyPath] = []
    private var cacheDate = Date.distantPast

    var isExpired: Bool {
        Date().timeIntervalSince(cacheDate) > 900 // 15 minutes
    }

    func cache(diagnosis: LearningDiagnosis, recommendations: [RecommendedStudyPath]) {
        cachedDiagnosis = diagnosis
        cachedRecommendations = recommendations
        cacheDate = Date()
    }

    func getCachedDiagnosis() -> LearningDiagnosis? {
        guard isExpired else { return cachedDiagnosis }
        return nil
    }

    func getCachedRecommendations() -> [RecommendedStudyPath] {
        guard isExpired else { return cachedRecommendations }
        return []
    }

    func invalidate() {
        cacheDate = Date.distantPast
    }
}