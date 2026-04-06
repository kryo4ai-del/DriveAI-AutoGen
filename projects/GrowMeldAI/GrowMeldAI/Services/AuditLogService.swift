@MainActor
final class AuditLogService: ObservableObject {
    private let persistenceQueue = DispatchQueue(
        label: "com.driveai.audit-log.persist",
        qos: .userInitiated  // High priority, but still off-main
    )
    
    func log(eventType: String, metadata: [String: String]? = nil, userConfirmed: Bool = true) {
        let entry = AuditLogEntry(eventType: eventType, metadata: metadata, userConfirmed: userConfirmed)
        
        // Update UI immediately (fast)
        entries.append(entry)
        
        // Persist asynchronously off MainThread
        persistenceQueue.async { [weak self] in
            self?.saveAuditLog()  // No @MainActor confinement here
        }
    }
    
    private func saveAuditLog() {
        let data = try? encoder.encode(entries)
        UserDefaults.standard.set(data, forKey: auditLogKey)
    }
}