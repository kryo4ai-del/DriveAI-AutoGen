class FeedbackAuditLogger {
    func logDeletion(feedbackID: UUID, reason: String, timestamp: Date = Date()) {
        // Write to tamper-proof log
        let auditEntry = AuditEntry(
            action: .deleted,
            feedbackID: feedbackID,
            reason: reason,
            timestamp: timestamp
        )
        persistenceManager.saveAuditEntry(auditEntry)
    }
}