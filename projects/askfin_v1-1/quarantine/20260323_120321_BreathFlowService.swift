import Foundation
import Combine

/// Manages persistence of BreathFlow sessions using UserDefaults (MVP).
///
/// History is capped at maxStoredSessions to stay within safe UserDefaults
/// key sizes (~100 sessions ≈ 80KB encoded).
/// Writes are debounced to avoid synchronous encoding on every save call.
final class BreathFlowService: ObservableObject {

    // MARK: - Singleton

    static let shared = BreathFlowService()

    // MARK: - Published State

    @Published private(set) var sessions: [BreathSession] = []

    // MARK: - Configuration

    private let storageKey = "breathflow.sessions.v1"
    private let maxStoredSessions = 100

    // MARK: - Private

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var persistTask: Task<Void, Never>?

    private init() {
        load()
    }

    // MARK: - Public API

    func save(session: BreathSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.append(session)
        }
        schedulePersist()
    }

    var completedSessionsCount: Int {
        sessions.filter { $0.completedAt != nil }.count
    }

    var averageCalmingDelta: Double? {
        let deltas = sessions.compactMap(\.calmingDelta)
        guard !deltas.isEmpty else { return nil }
        return Double(deltas.reduce(0, +)) / Double(deltas.count)
    }

    var mostRecentSession: BreathSession? {
        sessions
            .filter { $0.completedAt != nil }
            .max { ($0.completedAt ?? .distantPast) < ($1.completedAt ?? .distantPast) }
    }

    // MARK: - Persistence

    /// Debounced — coalesces rapid saves into a single disk write after 500ms.
    private func schedulePersist() {
        persistTask?.cancel()
        persistTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled, let self else { return }
            await MainActor.run { self.writeToDisk() }
        }
    }

    private func writeToDisk() {
        let trimmed = Array(sessions.suffix(maxStoredSessions))
        guard let data = try? encoder.encode(trimmed) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            sessions = try decoder.decode([BreathSession].self, from: data)
        } catch {
            // Data exists but failed to decode — log and reset.
            // assertionFailure surfaces this in debug builds without crashing production.
            assertionFailure("BreathFlowService: failed to decode session history: \(error)")
            sessions = []
        }
    }
}