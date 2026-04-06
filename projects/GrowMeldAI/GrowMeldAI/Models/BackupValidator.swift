// Checksum validation on import
struct BackupValidator {
    static func validateBackup(_ data: Data) throws {
        let backup = try JSONDecoder().decode(BackupSnapshot.self, from: data)
        
        // Verify checksum
        let calculated = calculateChecksum(backup.data)
        guard calculated == backup.checksumSHA256 else {
            throw BackupError.checksumMismatch
        }
        
        // Verify version compatibility
        guard isVersionCompatible(backup.backupVersion) else {
            throw BackupError.unsupportedVersion(backup.backupVersion)
        }
        
        // Verify no data corruption (schema validation)
        guard backup.categoryProgress.allSatisfy({ $0.percentageScore >= 0 && $0.percentageScore <= 1.0 }) else {
            throw BackupError.corruptedData("Invalid score range")
        }
    }
    
    private static func calculateChecksum(_ data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress!, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}