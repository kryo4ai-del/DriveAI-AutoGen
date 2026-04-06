import Foundation

// MARK: - Protocol Definition

/// Abstraction for performance data persistence
protocol PerformanceDataService: Sendable {
    
    // MARK: - Write Operations
    
    /// Records a single question attempt
    func recordAttempt(_ metric: PerformanceMetric) async throws
    
    /// Records multiple attempts in batch
    func recordAttempts(_ metrics: [PerformanceMetric]) async throws
    
    /// Saves exam simulation result
    func saveExamResult(_ result: ExamSimulationResult) async throws
    
    /// Updates user streak
    func updateStreak(_ streak: UserStreak) async throws
    
    // MARK: - Read Operations
    
    /// Fetches performance metrics matching query
    func fetchMetrics(query: PerformanceQuery) async throws -> [PerformanceMetric]
    
    /// Fetches category progress
    func fetchCategoryProgress(categoryId: String) async throws -> CategoryProgress?
    
    /// Fetches all category progress
    func fetchAllCategoryProgress() async throws -> [CategoryProgress]
    
    /// Computes overall statistics
    func computeOverallStats() async throws -> OverallStats
    
    /// Fetches user streak
    func fetchUserStreak() async throws -> UserStreak
    
    /// Fetches exam results
    func fetchExamResults(limit: Int, offset: Int) async throws -> [ExamSimulationResult]
    
    /// Fetches single exam result
    func fetchExamResult(id: UUID) async throws -> ExamSimulationResult?
    
    // MARK: - Sync Queue (Future-proofing)
    
    /// Enqueues metric for synchronization
    func enqueueSyncRecord(_ record: PerformanceSyncRecord) async throws
    
    /// Fetches pending sync records
    func fetchPendingSyncRecords(limit: Int) async throws -> [PerformanceSyncRecord]
    
    /// Updates sync record status
    func updateSyncRecordStatus(id: UUID, status: PerformanceSyncRecord.SyncStatus) async throws
    
    // MARK: - Management
    
    /// Clears all performance data (with confirmation in UI layer)
    func resetAllData() async throws
    
    /// Exports stats as JSON
    func exportStats() async throws -> Data
}

// MARK: - Error Handling

enum PerformanceDataError: LocalizedError {
    case databaseCorrupted
    case diskFull
    case queryFailed(String)
    case recordNotFound
    case invalidData
    case syncFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .databaseCorrupted:
            return "Die Datenbank ist beschädigt. Bitte melden Sie sich erneut an."
        case .diskFull:
            return "Der Speicher ist voll. Bitte löschen Sie einige Dateien."
        case .queryFailed(let msg):
            return "Abfragefehler: \(msg)"
        case .recordNotFound:
            return "Datensatz nicht gefunden."
        case .invalidData:
            return "Ungültige Daten."
        case .syncFailed(let msg):
            return "Synchronisierungsfehler: \(msg)"
        }
    }
}