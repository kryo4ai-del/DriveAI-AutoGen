// Infrastructure/Persistence/LocalBackupRepository.swift
import Foundation
import CryptoKit
import Security

final class LocalBackupRepository: BackupRepositoryProtocol {

    // MARK: - Properties

    private let fileManager: FileManager
    private let keychainService: KeychainServiceProtocol
    private let backupDirectoryName = "driveai_backups"
    private var backupDirectoryURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(backupDirectoryName)
    }

    // MARK: - Initialization

    init(fileManager: FileManager = .default,
         keychainService: KeychainServiceProtocol = KeychainService()) {
        self.fileManager = fileManager
        self.keychainService = keychainService
        createBackupDirectoryIfNeeded()
    }

    // MARK: - Backup Operations

    func saveBackup(_ backup: UserBackup) async throws {
        do {
            // Validate backup
            try backup.validate()

            // Serialize
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(backup)

            // Encrypt
            let encryptedData = try encryptData(data)

            // Write atomically
            let backupURL = backupFileURL(for: backup.backupMetadata.backupTimestamp)
            try encryptedData.write(to: backupURL, options: [.atomic])

            // Update metadata
            try updateBackupMetadata(backupURL, size: encryptedData.count)

        } catch let error as BackupError {
            throw error
        } catch {
            throw BackupError.encryptionFailed("Failed to save backup: \(error.localizedDescription)")
        }
    }

    func loadBackup() async throws -> UserBackup? {
        let fileURLs = try fileManager.contentsOfDirectory(at: backupDirectoryURL,
                                                          includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "driveai" }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }

        guard let latestURL = fileURLs.first else {
            return nil
        }

        do {
            let encryptedData = try Data(contentsOf: latestURL)
            let data = try decryptData(encryptedData)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(UserBackup.self, from: data)
        } catch {
            throw BackupError.corruptedBackupFile("Failed to load backup: \(error.localizedDescription)")
        }
    }

    func deleteBackup() async throws {
        let fileURLs = try fileManager.contentsOfDirectory(at: backupDirectoryURL,
                                                          includingPropertiesForKeys: nil)
        for fileURL in fileURLs {
            try fileManager.removeItem(at: fileURL)
        }
    }

    // MARK: - Encryption

    private func encryptData(_ data: Data) throws -> Data {
        let key = try keychainService.getOrCreateBackupKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined ?? Data()
    }

    private func decryptData(_ encryptedData: Data) throws -> Data {
        let key = try keychainService.getBackupKey()
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // MARK: - File Management

    private var backupFileURL: URL {
        backupDirectoryURL.appendingPathComponent("backup.driveai")
    }

    private func backupFileURL(for timestamp: Date) -> URL {
        backupDirectoryURL.appendingPathComponent("backup_\(timestamp.timeIntervalSince1970).driveai")
    }

    private func createBackupDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: backupDirectoryURL.path) {
            try? fileManager.createDirectory(at: backupDirectoryURL,
                                           withIntermediateDirectories: true)
        }
    }

    private func updateBackupMetadata(_ url: URL, size: Int64) throws {
        var resourceValues = URLResourceValues()
        resourceValues.contentModificationDate = Date()
        try url.setResourceValues(resourceValues)
    }
}

// MARK: - Keychain Service Protocol

protocol KeychainServiceProtocol {
    func getBackupKey() throws -> SymmetricKey
    func getOrCreateBackupKey() throws -> SymmetricKey
}
