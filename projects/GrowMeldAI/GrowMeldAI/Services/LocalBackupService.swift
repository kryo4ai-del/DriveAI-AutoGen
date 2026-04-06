// Sources/Services/Backup/LocalBackupService.swift
import Foundation
import Observation

final class LocalBackupService: BackupService {
    private let fileManager: FileManager
    private let codec: DataCodec
    private let backupDirectory: URL
    private let queue = DispatchQueue(label: "com.driveai.backup.queue", qos: .utility)

    private var _isBackupInProgress = false
    private let _backupStatusStream = AsyncStream<Bool>.makeStream()

    var isBackupInProgress: AsyncStream<Bool> {
        _backupStatusStream.stream
    }

    init(fileManager: FileManager = .default, codec: DataCodec = DataCodec()) throws {
        self.fileManager = fileManager
        self.codec = codec

        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        self.backupDirectory = appSupportURL.appendingPathComponent("Backups", isDirectory: true)

        try createBackupDirectoryIfNeeded()
    }

    // MARK: - Public API

    func createBackup() async throws -> BackupSnapshot {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                Task { @MainActor in
                    await self?.performCreateBackup(continuation: continuation)
                }
            }
        }
    }

    func restoreBackup(_ snapshot: BackupSnapshot) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                Task { @MainActor in
                    await self?.performRestoreBackup(snapshot, continuation: continuation)
                }
            }
        }
    }

    func getBackupMetadata() async -> [BackupMetadata] {
        await withCheckedContinuation { continuation in
            queue.async { [weak self] in
                let metadata = self?.loadBackupMetadata() ?? []
                continuation.resume(returning: metadata)
            }
        }
    }

    func deleteBackup(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                do {
                    try self?.deleteBackupInternal(id)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func pruneOldBackups(keepCount: Int) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                do {
                    try self?.pruneBackupsInternal(keepCount: keepCount)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Private Implementation

    private func createBackupDirectoryIfNeeded() throws {
        if !fileManager.fileExists(atPath: backupDirectory.path) {
            try fileManager.createDirectory(at: backupDirectory, withIntermediateDirectories: true)
        }
    }

    private func performCreateBackup(continuation: CheckedContinuation<BackupSnapshot, Error>) async {
        _isBackupInProgress = true
        _backupStatusStream.continuation.yield(true)

        defer {
            _isBackupInProgress = false
            _backupStatusStream.continuation.yield(false)
        }

        do {
            // Check disk space
            let availableSpace = try availableDiskSpace()
            let requiredSpace: UInt64 = 10 * 1024 * 1024 // 10MB buffer

            guard availableSpace > requiredSpace else {
                throw BackupError.diskSpaceInsufficient(required: requiredSpace, available: availableSpace)
            }

            // Create payload
            let settings = UserSettingsSnapshot(
                examDate: nil,
                autoBackupEnabled: true,
                backupFrequency: 86400 // 24 hours
            )

            let payload = BackupPayload(userSettings: settings)

            // Encode and compress
            let encodedData = try await codec.encodeAndCompress(payload)

            // Create snapshot
            let id = UUID().uuidString
            let fileURL = backupDirectory.appendingPathComponent("backup_\(id).bak")
            try encodedData.write(to: fileURL)

            // Calculate checksum
            let checksum = try encodedData.sha256()

            let snapshot = BackupSnapshot(
                id: id,
                timestamp: .now,
                version: MigrationVersion.current.rawValue,
                checksum: checksum,
                size: UInt64(encodedData.count),
                fileURL: fileURL
            )

            // Save metadata
            try saveBackupMetadata(snapshot)

            continuation.resume(returning: snapshot)
        } catch {
            continuation.resume(throwing: error)
        }
    }

    private func performRestoreBackup(_ snapshot: BackupSnapshot, continuation: CheckedContinuation<Void, Error>) async {
        _isBackupInProgress = true
        _backupStatusStream.continuation.yield(true)

        defer {
            _isBackupInProgress = false
            _backupStatusStream.continuation.yield(false)
        }

        do {
            // Verify file exists
            guard fileManager.fileExists(atPath: snapshot.fileURL.path) else {
                throw BackupError.backupNotFound
            }

            // Read and verify checksum
            let fileData = try Data(contentsOf: snapshot.fileURL)
            let calculatedChecksum = try fileData.sha256()

            guard calculatedChecksum == snapshot.checksum else {
                throw BackupError.checksumMismatch
            }

            // Decode payload
            let payload = try await codec.decompressAndDecode(BackupPayload.self, from: fileData)

            // Validate version
            guard payload.version == MigrationVersion.current.rawValue else {
                throw BackupError.invalidBackupVersion(payload.version)
            }

            // Here you would integrate with your actual data models
            // For now, we'll just validate the structure

            continuation.resume()
        } catch {
            continuation.resume(throwing: error)
        }
    }

    private func loadBackupMetadata() -> [BackupMetadata] {
        let fileManager = FileManager.default
        let backupFiles = (try? fileManager.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: nil)) ?? []

        return backupFiles.compactMap { fileURL -> BackupMetadata? in
            guard fileURL.pathExtension == "bak" else { return nil }

            let resourceValues = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
            guard let modificationDate = resourceValues?.contentModificationDate,
                  let fileSize = resourceValues?.fileSize else {
                return nil
            }

            let fileSizeString = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)

            return BackupMetadata(
                id: fileURL.deletingPathExtension().lastPathComponent,
                timestamp: modificationDate,
                displayName: "Sicherung vom \(modificationDate.formatted(date: .abbreviated, time: .omitted))",
                size: fileSizeString,
                version: MigrationVersion.current.rawValue,
                isValid: true
            )
        }.sorted { $0.timestamp > $1.timestamp }
    }

    private func saveBackupMetadata(_ snapshot: BackupSnapshot) throws {
        let metadata = BackupMetadata(
            id: snapshot.id,
            timestamp: snapshot.timestamp,
            displayName: "Sicherung vom \(snapshot.timestamp.formatted(date: .abbreviated, time: .omitted))",
            size: snapshot.size.formatted(.byteCount),
            version: snapshot.version,
            isValid: true
        )

        let metadataURL = backupDirectory.appendingPathComponent("\(snapshot.id).meta")
        let data = try JSONEncoder().encode(metadata)
        try data.write(to: metadataURL)
    }

    private func deleteBackupInternal(_ id: String) throws {
        let fileURL = backupDirectory.appendingPathComponent("backup_\(id).bak")
        let metadataURL = backupDirectory.appendingPathComponent("\(id).meta")

        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }

        if fileManager.fileExists(atPath: metadataURL.path) {
            try fileManager.removeItem(at: metadataURL)
        }
    }

    private func pruneBackupsInternal(keepCount: Int) throws {
        let metadataList = loadBackupMetadata()

        guard metadataList.count > keepCount else { return }

        let backupsToDelete = Array(metadataList.suffix(from: keepCount))

        for metadata in backupsToDelete {
            try deleteBackupInternal(metadata.id)
        }
    }

    private func availableDiskSpace() throws -> UInt64 {
        let systemAttributes = try fileManager.attributesOfFileSystem(forPath: NSHomeDirectory())
        return (systemAttributes[.systemFreeSize] as? UInt64) ?? 0
    }
}