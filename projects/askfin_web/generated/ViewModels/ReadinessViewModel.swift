import Foundation
import SwiftUI

/// Callback fired when milestone tier changes (only once per transition)
public typealias MilestoneChangeCallback = (ReadinessMilestone, ReadinessMilestone) -> Void

/// Observable ViewModel for readiness tracking with auto-refresh
/// Thread-safe: all mutations happen on @MainActor
@MainActor
@Observable
public final class ReadinessViewModel {
    public private(set) var state: ReadinessState
    public let userId: String

    // MARK: - Public accessors
    public var currentScore: Int { state.currentScore }
    public var currentMilestone: ReadinessMilestone { state.currentMilestone }
    public var trend: [ReadinessTrend] { state.trend }
    public var lastUpdated: Date { state.lastUpdated }
    public var isLoading: Bool { state.isLoading }
    public var error: Error? { state.error }

    // MARK: - Private state
    private let apiClient: ReadinessAPIClient
    private let autoRefreshEnabled: Bool
    private let onMilestoneChange: MilestoneChangeCallback?
    
    private var refreshTask: Task<Void, Never>?
    private var activeRefreshInFlight: Task<Void, Never>?

    public init(
        userId: String,
        apiClient: ReadinessAPIClient = .shared,
        autoRefreshEnabled: Bool = true,
        onMilestoneChange: MilestoneChangeCallback? = nil
    ) {
        self.userId = userId
        self.apiClient = apiClient
        self.autoRefreshEnabled = autoRefreshEnabled
        self.onMilestoneChange = onMilestoneChange
        self.state = ReadinessState()

        if autoRefreshEnabled {
            startAutoRefresh()
        }
    }

    deinit {
        stopAutoRefresh()
    }

    // =========================================================================
    // MARK: - Public API
    // =========================================================================

    /// Manually trigger a readiness data refresh (idempotent)
    public func refresh() async {
        // Deduplicate: if a refresh is already in flight, wait for it
        if let activeTask = activeRefreshInFlight {
            await activeTask.value
            return
        }

        let task = Task {
            await performRefresh()
        }

        activeRefreshInFlight = task
        await task.value
        activeRefreshInFlight = nil
    }

    // =========================================================================
    // MARK: - Private: Refresh Logic
    // =========================================================================

    private func performRefresh() async {
        // Guard: if already loading, don't duplicate
        guard !state.isLoading else { return }

        state = state.updating(isLoading: true, error: nil)

        do {
            // Network call (runs on background thread)
            let response = try await apiClient.fetchReadiness(userId: userId)
            let newScore = max(0, min(100, response.score)) // Clamp [0, 100]
            let newMilestone = ReadinessScore.getMilestone(for: newScore)
            
            // Capture old milestone BEFORE updating state
            let oldMilestone = state.currentMilestone

            // Compute derived fields
            var updatedTrend = state.trend
            let velocity = computeVelocity(trend: updatedTrend, newScore: newScore)
            let projectedDate = projectReadinessDate(
                trend: updatedTrend,
                newScore: newScore,
                targetScore: ReadinessScore.CRITICAL_MILESTONE
            )
            let regression = analyzeRegression(
                oldScore: state.currentScore,
                newScore: newScore,
                categoryBreakdown: response.categoryBreakdown
            )

            // Create trend entry with all computed fields
            let trendEntry = ReadinessTrend(
                timestamp: Date(),
                score: newScore,
                milestone: newMilestone,
                velocity: velocity,
                projectedReadinessDate: projectedDate,
                regressionContext: regression
            )

            updatedTrend.append(trendEntry)

            // Trim history to limit
            if updatedTrend.count > ReadinessScore.HISTORY_LIMIT {
                updatedTrend = Array(updatedTrend.suffix(ReadinessScore.HISTORY_LIMIT))
            }

            // Update state atomically
            state = ReadinessState(
                currentScore: newScore,
                currentMilestone: newMilestone,
                trend: updatedTrend,
                lastUpdated: Date(),
                isLoading: false,
                error: nil
            )

            // Fire callback if milestone tier changed
            if oldMilestone.tier != newMilestone.tier {
                onMilestoneChange?(oldMilestone, newMilestone)
            }

        } catch {
            state = state.updating(isLoading: false, error: error)
        }
    }

    // =========================================================================
    // MARK: - Private: Computation Helpers
    // =========================================================================

    /// Compute velocity (points per day) from recent trend
    private func computeVelocity(trend: [ReadinessTrend], newScore: Int) -> Double? {
        var recent = trend.suffix(3)
        if recent.count < 2 { return nil }

        let firstTime = recent.first?.timestamp ?? Date()
        let lastTime = Date()
        let timeDiffDays = lastTime.timeIntervalSince(firstTime) / (24 * 3600)

        guard timeDiffDays > 0.01 else { return nil } // Avoid division by near-zero

        let firstScore = Double(recent.first?.score ?? 0)
        let scoreDiff = Double(newScore) - firstScore
        
        return scoreDiff / timeDiffDays



The refactored code **fixes the three critical bugs**:
