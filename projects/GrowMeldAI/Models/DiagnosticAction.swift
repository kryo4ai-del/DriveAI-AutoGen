import Foundation
import Combine

// MARK: - DiagnosticAction

struct DiagnosticAction: Identifiable, Codable, Sendable {
    let id: String
    let title: String
    let description: String
    let severity: DiagnosticSeverity
    let category: DiagnosticCategory
    let status: DiagnosticStatus
    let createdAt: Date
    let resolvedAt: Date?
    let metadata: [String: String]
    var isHighlighted: Bool { severity == .critical || severity == .error }

    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        severity: DiagnosticSeverity = .info,
        category: DiagnosticCategory = .general,
        status: DiagnosticStatus = .open,
        createdAt: Date = Date(),
        resolvedAt: Date? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.severity = severity
        self.category = category
        self.status = status
        self.createdAt = createdAt
        self.resolvedAt = resolvedAt
        self.metadata = metadata
    }
}

// MARK: - DiagnosticSeverity

enum DiagnosticSeverity: String, Codable, CaseIterable, Sendable {
    case info
    case warning
    case error
    case critical

    var displayName: String {
        switch self {
        case .info:     return "Info"
        case .warning:  return "Warning"
        case .error:    return "Error"
        case .critical: return "Critical"
        }
    }

    var priority: Int {
        switch self {
        case .info:     return 0
        case .warning:  return 1
        case .error:    return 2
        case .critical: return 3
        }
    }
}

// MARK: - DiagnosticCategory

enum DiagnosticCategory: String, Codable, CaseIterable, Sendable {
    case general
    case network
    case performance
    case security
    case storage
    case ui

    var displayName: String {
        switch self {
        case .general:     return "General"
        case .network:     return "Network"
        case .performance: return "Performance"
        case .security:    return "Security"
        case .storage:     return "Storage"
        case .ui:          return "UI"
        }
    }
}

// MARK: - DiagnosticStatus

enum DiagnosticStatus: String, Codable, CaseIterable, Sendable {
    case open
    case inProgress
    case resolved
    case dismissed

    var displayName: String {
        switch self {
        case .open:       return "Open"
        case .inProgress: return "In Progress"
        case .resolved:   return "Resolved"
        case .dismissed:  return "Dismissed"
        }
    }

    var isActive: Bool {
        switch self {
        case .open, .inProgress: return true
        case .resolved, .dismissed: return false
        }
    }
}

// MARK: - DiagnosticActionStore

final class DiagnosticActionStore: ObservableObject, @unchecked Sendable {
    @Published private(set) var actions: [DiagnosticAction] = []

    private let storageKey = "com.growmeldai.diagnosticactions"
    private let queue = DispatchQueue(label: "com.growmeldai.diagnosticactions.store", attributes: .concurrent)

    static let shared = DiagnosticActionStore()

    init() {
        load()
    }

    func add(_ action: DiagnosticAction) {
        queue.async(flags: .barrier) {
            var current = self.actions
            current.append(action)
            self.actions = current
            self.persist(current)
        }
    }

    func remove(id: String) {
        queue.async(flags: .barrier) {
            var current = self.actions
            current.removeAll { $0.id == id }
            self.actions = current
            self.persist(current)
        }
    }

    func update(_ action: DiagnosticAction) {
        queue.async(flags: .barrier) {
            var current = self.actions
            if let index = current.firstIndex(where: { $0.id == action.id }) {
                current[index] = action
            }
            self.actions = current
            self.persist(current)
        }
    }

    func actions(for category: DiagnosticCategory) -> [DiagnosticAction] {
        actions.filter { $0.category == category }
    }

    func actions(with severity: DiagnosticSeverity) -> [DiagnosticAction] {
        actions.filter { $0.severity == severity }
    }

    func activeActions() -> [DiagnosticAction] {
        actions.filter { $0.status.isActive }
    }

    // MARK: - Persistence

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([DiagnosticAction].self, from: data)
            DispatchQueue.main.async {
                self.actions = decoded
            }
        } catch {
            print("[DiagnosticActionStore] Failed to load actions: \(error)")
        }
    }

    private func persist(_ actions: [DiagnosticAction]) {
        do {
            let data = try JSONEncoder().encode(actions)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("[DiagnosticActionStore] Failed to persist actions: \(error)")
        }
    }
}