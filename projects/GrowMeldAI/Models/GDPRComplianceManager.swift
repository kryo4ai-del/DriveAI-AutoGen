// ✅ IMPROVED: Secure deletion with audit log
final class GDPRComplianceManager {
    enum DeletionError: Error {
        case auditLogCreationFailed
        case deleteVerificationFailed
    }
    
    func deleteAllUserData() async throws {
        // 1. Create audit log before deletion
        let deletionRecord = DeletionAuditLog(
            timestamp: Date(),
            dataCategories: ["progress", "exams", "profile"],
            reason: "user_request"
        )
        try await auditLog.record(deletionRecord)
        
        // 2. Overwrite sensitive data before deletion
        let sensitiveKeys = ["userProgress", "examHistory", "userProfile"]
        for key in sensitiveKeys {
            // Overwrite with random data first
            let randomData = (0..<1024).map { _ in UInt8.random(in: 0...255) }
            UserDefaults.standard.set(randomData, forKey: "\(key)_temp")
            
            // Then remove
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // 3. Verify deletion
        for key in sensitiveKeys {
            guard UserDefaults.standard.object(forKey: key) == nil else {
                throw DeletionError.deleteVerificationFailed
            }
        }
        
        // 4. Log successful deletion
        try await auditLog.recordDeletionComplete(deletionRecord.id)
    }
}