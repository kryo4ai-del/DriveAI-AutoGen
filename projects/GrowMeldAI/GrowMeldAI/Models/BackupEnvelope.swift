func importBackup(from data: Data) async throws {
    // Step 1: Parse encrypted backup envelope
    let envelope = try JSONDecoder().decode(BackupEnvelope.self, from: data)
    
    // Step 2: Decrypt payload
    guard let ciphertextData = Data(base64Encoded: envelope.encrypted),
          let ivData = Data(base64Encoded: envelope.iv),
          let tagData = Data(base64Encoded: envelope.tag) else {
        throw BackupError.malformedBackupFile
    }
    
    let decryptedJSON = try encryptionService.decrypt(
        ciphertext: ciphertextData,
        iv: ivData,
        tag: tagData
    )
    
    // Step 3: Validate checksum
    let calculated = calculateChecksum(decryptedJSON)
    guard calculated == envelope.checksum else {
        throw BackupError.checksumMismatch
    }
    
    // Step 4: Decode and validate backup snapshot
    let backup = try JSONDecoder().decode(BackupSnapshot.self, from: decryptedJSON)
    try BackupValidator.validateBackup(backup)
    
    // Step 5: Migrate schema if necessary
    let migratedBackup = try BackupMigrator.migrate(
        from: backup.backupVersion,
        data: backup
    )
    
    // Step 6: Fetch current local progress
    let currentLocal = LocalDataService.shared.getCurrentProgress()
    
    // Step 7: Resolve conflicts (last-write-wins with logging)
    let resolved = CloudKitService().resolveConflict(
        local: currentLocal,
        cloud: migratedBackup
    )
    
    // Step 8: Apply restored data to local database
    try await LocalDataService.shared.updateProgress(resolved)
    try await LocalDataService.shared.clearQuizHistory()
    try await LocalDataService.shared.insertQuizHistory(migratedBackup.quizHistory)
    
    // Step 9: Queue upload to CloudKit
    try await CloudKitService().uploadProgress(resolved)
}

struct BackupEnvelope: Codable {
    let encrypted: String        // Base64-encoded ciphertext
    let iv: String               // Base64-encoded IV
    let tag: String              // Base64-encoded auth tag
    let checksum: String         // SHA256 of decrypted JSON
    let createdAt: Date
    let version: String          // "1.0" for versioning
}