import SQLite3
import Foundation

/// Centralized SQLite configuration and PRAGMA settings
enum DatabaseConfiguration {
    static let defaultTimeout: Int32 = 5000  // 5 second timeout
    static let pageSize: Int32 = 4096
    static let cacheSize: Int32 = -64000  // 64MB in-memory cache
    
    static func applyOptimalSettings(to db: OpaquePointer?) throws {
        guard let db = db else { throw DriveAIError.databaseUnavailable }
        
        let pragmas = [
            // Crash resilience
            "PRAGMA journal_mode=WAL",
            "PRAGMA synchronous=NORMAL",
            
            // Foreign key enforcement
            "PRAGMA foreign_keys=ON",
            
            // Performance tuning
            "PRAGMA page_size=\(pageSize)",
            "PRAGMA cache_size=\(cacheSize)",
            "PRAGMA temp_store=MEMORY",
            "PRAGMA mmap_size=30000000",  // Memory-mapped I/O
            
            // Connection timeout
            "PRAGMA busy_timeout=\(defaultTimeout)",
            
            // Integrity
            "PRAGMA quick_check"
        ]
        
        for pragma in pragmas {
            var errorMsg: UnsafeMutablePointer<Int8>?
            defer { sqlite3_free(errorMsg) }
            
            if sqlite3_exec(db, pragma, nil, nil, &errorMsg) != SQLITE_OK {
                let msg = String(cString: errorMsg ?? "unknown".cString(using: .utf8)!)
                throw DriveAIError.databaseCorrupted(reason: "PRAGMA \(pragma): \(msg)")
            }
        }
    }
}