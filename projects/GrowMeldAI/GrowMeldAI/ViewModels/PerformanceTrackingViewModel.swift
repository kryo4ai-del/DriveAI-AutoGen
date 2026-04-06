@MainActor
final class PerformanceTrackingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var categoryStats: [CategoryPerformance] = []
    @Published var examReadiness: ExamReadinessSnapshot?
    @Published var spacedRepetitionQueue: [SpacedRepetitionItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let performanceService: PerformanceStorageService
    private let predictionService: ExamReadinessPredictionService
    private let spacedRepetitionService: SpacedRepetitionService
    private var cancellables = Set<AnyCancellable>()
    
    // Prevent concurrent loads
    private var activeLoadTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(
        performanceService: PerformanceStorageService = .shared,
        predictionService: ExamReadinessPredictionService = .shared,
        spacedRepetitionService: SpacedRepetitionService = .shared
    ) {
        self.performanceService = performanceService
        self.predictionService = predictionService
        self.spacedRepetitionService = spacedRepetitionService
    }
    
    // MARK: - Public Methods
    
    /// Loads all performance data atomically.
    /// - Note: Cancels any in-flight load operation to prevent race conditions.
    func loadPerformanceData() async {
        // Cancel previous load if still in flight
        activeLoadTask?.cancel()
        
        let task = Task {
            await performLoadOperation()
        }
        activeLoadTask = task
        await task.value
    }
    
    func refreshPerformanceData() async {
        await loadPerformanceData()
    }
    
    func calculateReadiness() -> Double {
        guard let readiness = examReadiness else { return 0.0 }
        return readiness.confidenceScore / 100.0
    }
    
    func getRecommendedQuestions(for categoryId: String) -> [SpacedRepetitionItem] {
        spacedRepetitionQueue.filter { $0.categoryId == categoryId }
    }
    
    func markQuestionReviewed(questionId: String) async {
        do {
            try await spacedRepetitionService.updateReviewDate(for: questionId)
            await loadPerformanceData()
        } catch {
            errorMessage = errorMessage(for: error)
            Logger.error("Failed to mark question reviewed", error: error)
        }
    }
    
    // MARK: - Private Methods
    
    private func performLoadOperation() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Concurrent loads with clear error propagation
            async let statsTask = performanceService.getCategoryStats()
            async let readinessTask = predictionService.calculateExamReadiness()
            async let queueTask = spacedRepetitionService.getReviewQueue(limit: 20)
            
            let (stats, readiness, queue) = try await (statsTask, readinessTask, queueTask)
            
            // All assignments are atomic under @MainActor
            updateStateAtomically(
                stats: stats,
                readiness: readiness,
                queue: queue
            )
        } catch {
            self.errorMessage = errorMessage(for: error)
            Logger.error("Failed to load performance data", error: error)
        }
    }
    
    private func updateStateAtomically(
        stats: [CategoryPerformance],
        readiness: ExamReadinessSnapshot,
        queue: [SpacedRepetitionItem]
    ) {
        // Atomic update of related state
        self.categoryStats = stats.sorted { $0.categoryId < $1.categoryId }
        self.examReadiness = readiness
        self.spacedRepetitionQueue = queue.sorted { $0.urgencyComparator() < $1.urgencyComparator() }
    }
    
    private func errorMessage(for error: Error) -> String {
        switch error {
        case let storageError as StorageError:
            return handleStorageError(storageError)
        case is DecodingError:
            return NSLocalizedString(
                "error.decoding",
                value: "Daten konnten nicht gelesen werden.",
                comment: "Decoding error message"
            )
        case let nsError as NSError where nsError.domain == NSURLErrorDomain:
            return handleNetworkError(nsError)
        default:
            return NSLocalizedString(
                "error.unknown",
                value: "Ein unerwarteter Fehler ist aufgetreten.",
                comment: "Generic error message"
            )
        }
    }
    
    private func handleStorageError(_ error: StorageError) -> String {
        switch error {
        case .databaseError:
            return NSLocalizedString(
                "error.database",
                value: "Datenbankfehler. Bitte versuchen Sie es später erneut.",
                comment: "Database error"
            )
        case .invalidData:
            return NSLocalizedString(
                "error.invalidData",
                value: "Ungültige Daten. Bitte starten Sie die App neu.",
                comment: "Invalid data error"
            )
        case .notFound:
            return NSLocalizedString(
                "error.notFound",
                value: "Keine Daten gefunden.",
                comment: "Not found error"
            )
        @unknown default:
            return NSLocalizedString(
                "error.storage",
                value: "Speicherfehler aufgetreten.",
                comment: "Generic storage error"
            )
        }
    }
    
    private func handleNetworkError(_ error: NSError) -> String {
        if error.code == NSURLErrorTimedOut {
            return NSLocalizedString(
                "error.timeout",
                value: "Verbindungs-Timeout. Bitte erneut versuchen.",
                comment: "Network timeout"
            )
        }
        return NSLocalizedString(
            "error.network",
            value: "Netzwerkfehler aufgetreten.",
            comment: "Generic network error"
        )
    }
}