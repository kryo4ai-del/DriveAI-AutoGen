import SwiftUI
import Combine

/// Manages state and business logic for the simulation result screen.
/// 
/// **FK-005 Implementation Summary:**
/// Consolidated from 5 variants into single canonical version. Handles async
/// persistence via StatisticsService, computes readiness state, provides
/// category analysis. Lifecycle: persists on init, updates readiness async.
/// Thread-safe via @Published. Task lifecycle managed with deinit cancellation.
final class SimulationResultViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var result: SimulationResult
    @Published private(set) var readiness: ExamReadiness
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let statisticsService: StatisticsService
    private let analyticsService: AnalyticsService?
    private var persistTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Initializes with result and optional dependencies.
    /// Automatically triggers async persistence.
    init(
        result: SimulationResult,
        readiness: ExamReadiness = .preview,
        statisticsService: StatisticsService = .shared,
        analyticsService: AnalyticsService? = nil
    ) {
        self.result = result
        self.readiness = readiness
        self.statisticsService = statisticsService
        self.analyticsService = analyticsService
        
        // Track task for cancellation on deinit
        persistTask = Task { await persistAndUpdateReadiness() }
    }
    
    deinit {
        persistTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    func categorysSortedByWeakness() -> [CategoryScore] {
        result.categoryScores.sorted { $0.percentage < $1.percentage }
    }
    
    func categorysSortedByName() -> [CategoryScore] {
        result.categoryScores.sorted { $0.category.name < $1.category.name }
    }
    
    func strongestCategory() -> CategoryScore? {
        result.categoryScores.max { $0.percentage < $1.percentage }
    }
    
    func weakestCategory() -> CategoryScore? {
        categorysSortedByWeakness().first
    }
    
    // MARK: - Private Methods
    
    private func persistAndUpdateReadiness() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await statisticsService.saveSimulationResult(result)
            await MainActor.run {
                statisticsService.computeReadiness()
                self.readiness = statisticsService.readiness
            }
        } catch {
            errorMessage = "Failed to save result: \(error.localizedDescription)"
        }
    }
}