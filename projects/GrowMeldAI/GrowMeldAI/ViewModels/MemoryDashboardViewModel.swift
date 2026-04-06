import Foundation
import Combine
import os.log

@MainActor
final class MemoryDashboardViewModel: ObservableObject {
    // MARK: - State Machine
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - Published State
    @Published private(set) var loadingState: LoadingState = .idle
    @Published private(set) var insights: [MemoryInsight] = []
    @Published private(set) var coaching: CoachingRecommendation?
    @Published private(set) var nextReviewQueue: [Question] = []
    @Published private(set) var masteryDistribution: [MasteryLevel: Int] = [:]
    @Published private(set) var confidenceByCategory: [String: Double] = [:]
    @Published private(set) var lastUpdated: Date?
    
    // MARK: - Dependencies
    private let memoryService: MemoryServiceProtocol
    private let dataService: LocalDataServiceProtocol
    private let historyService: ConfidenceHistoryServiceProtocol
    private let logger = Logger(subsystem: "com.driveai.memory", category: "dashboard")
    
    // MARK: - Private State
    private var loadTask: Task<Void, Never>?
    
    // MARK: - Init
    nonisolated init(
        memoryService: MemoryServiceProtocol,
        dataService: LocalDataServiceProtocol,
        historyService: ConfidenceHistoryServiceProtocol
    ) {
        self.memoryService = memoryService
        self.dataService = dataService
        self.historyService = historyService
    }
    
    deinit {
        loadTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Loads dashboard data without blocking. Safe to call multiple times.
    func loadDashboard() {
        // Cancel previous load if still running
        loadTask?.cancel()
        loadingState = .loading
        
        loadTask = Task {
            do {
                try await performLoad()
                
                // Only update state if not cancelled
                if !Task.isCancelled {
                    lastUpdated = Date()
                    loadingState = .loaded
                }
            } catch is CancellationError {
                logger.debug("Dashboard load was cancelled")
                // Don't update state on cancellation
            } catch {
                loadingState = .error(error.localizedDescription)
                logger.error("Dashboard load failed: \(error.localizedDescription)")
            }
        }
    }
    
    /// Refresh dashboard data.
    func refresh() {
        loadDashboard()
    }
    
    // MARK: - Private Methods
    
    private func performLoad() async throws {
        // Fetch all required data in parallel
        async let snapshotTask = memoryService.getCurrentMasterySnapshot()
        async let calibrationTask = memoryService.getConfidenceCalibration()
        async let reviewQueueTask = memoryService.getNextReviewQueue(limit: 5)
        
        let snapshot = try await snapshotTask
        let calibration = try await calibrationTask
        let reviewQueue = try await reviewQueueTask
        
        // Validate data
        try validateSnapshot(snapshot)
        
        // Transform to presentation models
        insights = try await transformToInsights(from: snapshot, calibration: calibration)
        coaching = try await determineCoaching(from: snapshot, calibration: calibration)
        nextReviewQueue = reviewQueue
        masteryDistribution = transformToDistribution(from: snapshot)
        confidenceByCategory = calibration
    }
    
    private func validateSnapshot(_ snapshot: MasterySnapshot) throws {
        for category in snapshot.categories {
            guard category.totalCount > 0 else {
                throw SnapshotValidationError.invalidTotalCount(category: category.name)
            }
            
            guard category.reviewedCount <= category.totalCount else {
                logger.warning(
                    "Reviewed count (\(category.reviewedCount)) exceeds total (\(category.totalCount)) for \(category.name)"
                )
                // Don't throw—clamp the value
            }
        }
    }
    
    private func transformToInsights(
        from snapshot: MasterySnapshot,
        calibration: [String: Double]
    ) async -> [MemoryInsight] {
        var insights: [MemoryInsight] = []
        
        for category in snapshot.categories {
            let confidence = calibration[category.name] ?? 0
            
            // Fetch trend asynchronously
            let trend = await getConfidenceTrend(for: category.name)
            
            let narrative = buildNarrative(
                reviewedCount: category.reviewedCount,
                totalCount: category.totalCount,
                confidence: confidence,
                trend: trend
            )
            
            let insight = MemoryInsight(
                id: UUID(),
                category: category.name,
                confidencePercentage: confidence,
                narrative: narrative,
                trend: trend,
                reviewedCount: category.reviewedCount,
                totalCount: category.totalCount,
                nextActionLabel: "Wiederholen",
                nextActionIcon: "arrow.right.circle.fill"
            )
            
            insights.append(insight)
        }
        
        return insights.sorted { $0.confidencePercentage < $1.confidencePercentage }
    }
    
    private func determineCoaching(
        from snapshot: MasterySnapshot,
        calibration: [String: Double]
    ) async -> CoachingRecommendation? {
        guard !snapshot.categories.isEmpty else { return nil }
        
        // Find weakest category by confidence
        let weakest = snapshot.categories.min { a, b in
            (calibration[a.name] ?? 0) < (calibration[b.name] ?? 0)
        }
        
        guard let weakest = weakest else { return nil }
        
        let confidence = calibration[weakest.name] ?? 0
        let evidenceText = "\(weakest.reviewedCount)/\(weakest.totalCount) Fragen"
        
        // All categories below threshold get immediate coaching
        if confidence < 0.75 {
            let psychCue: String
            let priority: CoachingPriority
            
            if confidence < 0.5 {
                psychCue = "Diese Kategorie braucht Aufmerksamkeit — wiederholtes Abrufen stärkt Ihr Gedächtnis."
                priority = .immediate
            } else {
                psychCue = "Festigen Sie Ihr Wissen mit gezielten Wiederholungsfragen."
                priority = .soon
            }
            
            return CoachingRecommendation(
                headline: "\(weakest.name) braucht Aufmerksamkeit",
                evidence: evidenceText,
                psychologicalCue: psychCue,
                actionItems: ["3–5 Fragen zu \(weakest.name) machen"],
                priority: priority
            )
        }
        
        // All categories at or above threshold get maintenance coaching
        return CoachingRecommendation(
            headline: "Wissen festigen",
            evidence: evidenceText,
            psychologicalCue: "Regelmäßige Wiederholung stärkt langfristiges Gedächtnis.",
            actionItems: ["3–5 Fragen zu \(weakest.name) wiederholen"],
            priority: .maintenance
        )
    }
    
    private func transformToDistribution(from snapshot: MasterySnapshot) -> [MasteryLevel: Int] {
        // Initialize all levels to 0
        var distribution = MasteryLevel.allCases.reduce(into: [:]) { dict, level in
            dict[level] = 0
        }
        
        for category in snapshot.categories {
            let level = determineMasteryLevel(
                reviewedCount: category.reviewedCount,
                totalCount: category.totalCount
            )
            distribution[level, default: 0] += 1
        }
        
        return distribution
    }
    
    private func determineMasteryLevel(reviewedCount: Int, totalCount: Int) -> MasteryLevel {
        // Clamp reviewed to [0, total]
        let clampedReviewed = max(0, min(reviewedCount, totalCount))
        let clampedTotal = max(1, totalCount)  // Prevent division by zero
        
        let ratio = Double(clampedReviewed) / Double(clampedTotal)
        
        if ratio >= 1.0 {
            return .mastered
        } else if ratio >= 0.75 {
            return .proficient
        } else if ratio >= 0.5 {
            return .developing
        } else {
            return .novice
        }
    }
    
    private func getConfidenceTrend(for category: String) async -> ConfidenceTrend {
        do {
            return try await historyService.getConfidenceTrend(
                for: category,
                lookbackDays: 7
            )
        } catch {
            logger.warning("Failed to fetch trend for \(category): \(error)")
            return .stable
        }
    }
    
    private func buildNarrative(
        reviewedCount: Int,
        totalCount: Int,
        confidence: Double,
        trend: ConfidenceTrend
    ) -> String {
        let percent = Int(confidence * 100)
        let trendEmoji = trend.emoji
        
        return "\(percent)% Vertrauen, \(reviewedCount) von \(totalCount) Fragen \(trendEmoji)"
    }
}

// MARK: - Presentation Models

struct CoachingRecommendation: Identifiable {
    let id: UUID = UUID()
    let headline: String
    let evidence: String
    let psychologicalCue: String
    let actionItems: [String]
    let priority: CoachingPriority
    
    enum CoachingPriority: String, CaseIterable {
        case immediate = "Sofort"
        case soon = "Bald"
        case maintenance = "Wartung"
    }
}

enum ConfidenceTrend: Hashable, CaseIterable {
    case improving
    case declining
    case stable
    
    var emoji: String {
        switch self {
        case .improving: return "↑"
        case .declining: return "↓"
        case .stable: return "→"
        }
    }
    
    var description: String {
        switch self {
        case .improving: return "Verbesserung"
        case .declining: return "Rückgang"
        case .stable: return "Stabil"
        }
    }
}

// MARK: - Errors

enum SnapshotValidationError: LocalizedError {
    case invalidTotalCount(category: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidTotalCount(let category):
            return "Kategorie \(category) hat ungültige Gesamtzahl"
        }
    }
}