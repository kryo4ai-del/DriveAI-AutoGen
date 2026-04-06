public struct ExperimentMetric {
    // ... existing fields ...
    public let retentionPolicyDays: Int  // Auto-delete after X days
    public let deletionScheduledAt: Date?  // When this metric will be deleted
    
    public func isRetentionExpired(asOf date: Date = Date()) -> Bool {
        let expiryDate = timestamp.addingTimeInterval(Double(retentionPolicyDays) * 86400)
        return date > expiryDate
    }
}
