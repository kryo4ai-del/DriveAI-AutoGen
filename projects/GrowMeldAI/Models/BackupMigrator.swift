struct BackupMigrator {
    static func migrate(from version: String, data: Data) throws -> BackupSnapshot {
        switch version {
        case "1.0":
            return try migrateV1ToV2(data)
        case "2.0":
            return try decodeV2(data)
        default:
            throw BackupError.unsupportedVersion(version)
        }
    }
    
    private static func migrateV1ToV2(_ data: Data) throws -> BackupSnapshot {
        let v1 = try JSONDecoder().decode(BackupV1.self, from: data)
        return BackupSnapshot(
            // Map v1 fields to v2
            categoryProgress: v1.progress.map { /* transform */ },
            // ...
        )
    }
}