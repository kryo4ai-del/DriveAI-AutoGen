import Foundation
import Combine

/// Thread-safe view model for managing user progress across exam categories.
/// Uses @MainActor to ensure all UI updates occur on the main thread.
/// Internal data mutations are protected by NSLock to prevent concurrent write conflicts.
@MainActor
class ProgressViewModel: ObservableObject {
    @Published var categoryProgress: [String: ProgressSnapshot] = [:]
    @Published var userStats: UserStatistics = .default
    @Published var streak: LearningStreak = .default
    @Published var readiness: ExamReadiness = ExamReadiness(score: 0)
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let dataService: LocalDataService
    private let progressLock = NSLock()  // Synchronization for concurrent writes
    private var updateTask: Task<Void, Never>?
    private let debounceDelay: TimeInterval = 0.5
    private var pendingUpdates: [String: ProgressUpdate] = [:]
    
    init(dataService: LocalDataService = .shared) {
        self.dataService = dataService
    }
    
    /// Records a user's answer to a quiz question with thread-safe synchronization.
    /// - Parameters:
    ///   - categoryId: The ID of the category being answered
    ///   - correct: Whether the answer was correct
    /// 
    /// Thread Safety: Uses NSLock to serialize concurrent writes to categoryProgress.
    /// This prevents data loss when multiple answers are submitted simultaneously.
    func recordAnswer(categoryId: String, correct: Bool) async throws {
        do {
            isLoading = true
            defer { isLoading = false }
            
            let updated = try await dataService.updateProgress(
                categoryId: categoryId,
                correct: correct
            )
            
            // Serialize access to categoryProgress via lock
            progressLock.withLock {
                self.categoryProgress[categoryId] = updated
            }
            
            // Debounce UI updates for readiness recalculation
            scheduleFlush()
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// Fetches all progress data from storage and updates published properties.
    func fetchAllProgress() async {
        do {
            isLoading = true
            
            let categoryProgress = try await dataService.fetchAllCategoryProgress()
            let userStats = try await dataService.fetchUserStatistics()
            let streak = try await dataService.fetchLearningStreak()
            
            progressLock.withLock {
                self.categoryProgress = categoryProgress
                self.userStats = userStats
                self.streak = streak
                self.readiness = ExamReadiness.calculate(from: categoryProgress)
            }
            
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    /// Schedules a debounced flush of pending updates to recalculate readiness.
    private func scheduleFlush() {
        updateTask?.cancel()
        updateTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
            
            progressLock.withLock {
                self.readiness = ExamReadiness.calculate(from: self.categoryProgress)
            }
        }
    }
}