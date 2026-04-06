// Models/Backup/MigrationVersion.swift

enum MigrationVersion: Int, CaseIterable, Comparable {
    case v1 = 1  // Initial schema: Questions, UserProgress, ExamSessions
    case v2 = 2  // Future: Add streak data, achievements
    
    static var current: MigrationVersion = .v1
    
    static func < (lhs: MigrationVersion, rhs: MigrationVersion) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}