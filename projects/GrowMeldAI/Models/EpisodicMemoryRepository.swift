// ✅ OPTION A: Isolate to MainActor (simplest for DriveAI)
@MainActor
final class EpisodicMemoryRepository: ObservableObject {
    private let database: Database  // Now safe—only accessed from MainActor
    
    nonisolated func fetchRecent(limit: Int = 20) async throws -> [EpisodicMemory] {
        // Offload to background queue for non-blocking reads
        return try await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { throw CancellationError() }
            return try await self.database.read { ... }
        }.value
    }
    
    nonisolated func create(_ memory: EpisodicMemory) async throws {
        return try await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { throw CancellationError() }
            return try await self.database.execute { ... }
        }.value
    }
}

// ✅ OPTION B: Explicit Sendable wrapper
struct SendableDatabase: Sendable {
    nonisolated private let connection: Connection
    private let queue = DispatchQueue(
        label: "com.driveai.db",
        attributes: .concurrent
    )
    
    nonisolated func read<T: Sendable>(
        _ block: @Sendable (Connection) throws -> T
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    continuation.resume(returning: try block(connection))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

final class EpisodicMemoryRepository {
    private let database: SendableDatabase  // ✅ Now truly thread-safe
}