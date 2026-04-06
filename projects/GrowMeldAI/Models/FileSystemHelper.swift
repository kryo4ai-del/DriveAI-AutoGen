// Services/Backup/FileSystemHelper.swift

import Foundation

struct FileSystemHelper {
    static func getAvailableDiskSpace(for url: URL) throws -> UInt64 {
        let resourceKeys: Set<URLResourceKey> = [.volumeAvailableCapacityKey]
        let values = try url.resourceValues(forKeys: resourceKeys)
        
        guard let capacity = values.volumeAvailableCapacity else {
            throw BackupError.ioError(
                NSError(domain: "FileSystem", code: -1, 
                        userInfo: [NSLocalizedDescriptionKey: "Cannot determine disk space"])
            )
        }
        
        return UInt64(max(0, capacity))
    }
    
    static func estimateBackupSize(
        progressCategories: Int = 12,
        examSessions: Int = 5
    ) -> UInt64 {
        // Conservative estimates:
        // - Progress entry: ~200 bytes (category ID, scores, timestamp)
        // - Exam session: ~5 KB (30 answers + metadata)
        // - JSON overhead: ~50 KB
        
        let progressSize = UInt64(progressCategories * 200)
        let sessionsSize = UInt64(examSessions * 5_000)
        let baseOverhead = UInt64(50_000)
        
        return progressSize + sessionsSize + baseOverhead
    }
}