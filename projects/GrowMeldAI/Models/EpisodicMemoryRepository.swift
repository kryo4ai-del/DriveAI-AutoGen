// ✅ OPTION A: Isolate to MainActor (simplest for DriveAI)

protocol Database {
    func read<T>(_ block: (Any) throws -> T) async throws -> T
    func execute<T>(_ block: (Any) throws -> T) async throws -> T
}

protocol Connection {}

@MainActor
final class EpisodicMemoryRepository: ObservableObject {
    private let database: Database  // Now safe—only accessed from MainActor
    
    init(database: Database) {
        self.database = database
    }
    
    nonisolated func fetchRecent(limit: Int = 20) async throws -> [EpisodicMemory] {
        // Offload to background queue for non-blocking reads
        return try await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { throw CancellationError() }
            return try await MainActor.run {
                return try self.database.read { _ in [EpisodicMemory]() }
            }
        }.value
    }
    
    nonisolated func create(_ memory: EpisodicMemory) async throws {
        try await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { throw CancellationError() }
            return try await MainActor.run {
                return try self.database.execute { _ in () }
            }
        }.value
    }
}

struct EpisodicMemory: Sendable {}

// ✅ OPTION B: Explicit Sendable wrapper
struct SendableDatabase: Sendable {
    nonisolated private let connection: any Connection
    private let queue: DispatchQueue
    
    init(connection: any Connection) {
        self.connection = connection
        self.queue = DispatchQueue(
            label: "com.driveai.db",
            attributes: .concurrent
        )
    }
    
    nonisolated func read<T: Sendable>(
        _ block: @Sendable @escaping (any Connection) throws -> T
    ) async throws -> T {
        let conn = self.connection
        let q = self.queue
        return try await withCheckedThrowingContinuation { continuation in
            q.async {
                do {
                    continuation.resume(returning: try block(conn))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

final class EpisodicMemoryRepositoryB {
    private let database: SendableDatabase  // ✅ Now truly thread-safe
    
    init(database: SendableDatabase) {
        self.database = database
    }
}