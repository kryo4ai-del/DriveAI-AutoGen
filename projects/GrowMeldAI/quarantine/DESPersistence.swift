// Services/DES/DESPersistence.swift
import SQLite3

@MainActor
final class DESPersistence {
    
    private let dbQueue = DispatchQueue(
        label: "com.driveai.des.db",
        attributes: .concurrent
    )
    
    private let dbPath: String
    
    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        dbPath = docs.appendingPathComponent("des.db").path
        Task { try? await initializeDB() }
    }
    
    // MARK: - Append-Only Metrics Log
    
    func appendPerformanceMetrics(_ metrics: PerformanceMetrics) async throws {
        try await dbQueue.async(flags: .barrier) {
            let db = try SQLiteDB(path: self.dbPath)
            defer { try? db.close() }
            
            try db.prepare("""
                INSERT INTO performance_metrics
                (category_id, date, total_attempts, correct_answers, avg_time_ms, session_duration_ms)
                VALUES (?, ?, ?, ?, ?, ?)
                """)
                .bind([
                    metrics.categoryId,
                    metrics.date.timeIntervalSince1970,
                    metrics.totalAttempts,
                    metrics.correctAnswers,
                    Int(metrics.averageTimePerQuestion * 1000),
                    Int(metrics.sessionDuration * 1000)
                ])
                .execute()
        }
    }
    
    /// Query with index (no full table scan)
    func loadPerformanceMetrics(
        categoryId: String,
        since: Date
    ) async throws -> [PerformanceMetrics] {
        try await dbQueue.async {
            let db = try SQLiteDB(path: self.dbPath)
            defer { try? db.close() }
            
            let rows = try db.query("""
                SELECT category_id, date, total_attempts, correct_answers, avg_time_ms, session_duration_ms
                FROM performance_metrics
                WHERE category_id = ? AND date > ?
                ORDER BY date DESC
                LIMIT 1000
                """,
                [categoryId, since.timeIntervalSince1970]
            )
            
            return rows.map { row in
                PerformanceMetrics(
                    categoryId: row[0] as! String,
                    date: Date(timeIntervalSince1970: row[1] as! Double),
                    totalAttempts: row[2] as! Int,
                    correctAnswers: row[3] as! Int,
                    averageTimePerQuestion: Double(row[4] as! Int) / 1000,
                    sessionDuration: Double(row[5] as! Int) / 1000
                )
            }
        }
    }
    
    private func initializeDB() async throws {
        try await dbQueue.async(flags: .barrier) {
            let db = try SQLiteDB(path: self.dbPath)
            defer { try? db.close() }
            
            try db.execute("""
                CREATE TABLE IF NOT EXISTS performance_metrics (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    category_id TEXT NOT NULL,
                    date REAL NOT NULL,
                    total_attempts INTEGER NOT NULL,
                    correct_answers INTEGER NOT NULL,
                    avg_time_ms INTEGER NOT NULL,
                    session_duration_ms INTEGER NOT NULL,
                    created_at REAL DEFAULT (unixepoch())
                );
                
                CREATE INDEX IF NOT EXISTS idx_category_date
                ON performance_metrics(category_id, date DESC);
                
                CREATE INDEX IF NOT EXISTS idx_date
                ON performance_metrics(date DESC);
                """)
        }
    }
}