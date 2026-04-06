import Foundation

class AuditLogService {
    static let shared = AuditLogService()
    private var entries: [AuditEvent] = []
    func log(_ event: AuditEvent) { entries.append(event) }
}
