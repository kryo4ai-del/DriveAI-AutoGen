// Features/Base/TaskManager.swift
@MainActor
final class TaskManager {
    private var tasks: [String: Task<Void, Never>] = [:]
    
    func store(_ task: Task<Void, Never>, for key: String) {
        tasks[key]?.cancel()
        tasks[key] = task
    }
    
    func cancel(for key: String) {
        tasks[key]?.cancel()
        tasks[key] = nil
    }
    
    func cancelAll() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }
}