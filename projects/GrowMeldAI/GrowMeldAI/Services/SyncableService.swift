// Future: CoreData + CloudKit sync
protocol SyncableService {
    func syncWithBackend() async throws
    func resolveConflicts() async throws
}