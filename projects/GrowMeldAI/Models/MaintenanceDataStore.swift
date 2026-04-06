// MARK: - MaintenanceDataStore.swift
import Foundation

@MainActor
protocol MaintenanceDataStore: Sendable {
    func fetchCheck(categoryId: String) async throws -> MaintenanceCheck
    func fetchAllChecks() async throws -> [MaintenanceCheck]
    func updateCheckDate(categoryId: String, date: Date) async throws
    func updateFrequency(categoryId: String, frequency: MaintenanceFrequency) async throws
}

// MARK: - Schema Definition
enum MaintenanceCheckSchema {
    static let tableName = "maintenance_checks"
    
    static let createTable = """
        CREATE TABLE IF NOT EXISTS maintenance_checks (
            category_id TEXT PRIMARY KEY,
            category_name TEXT NOT NULL,
            last_completed_date TEXT,
            frequency INTEGER NOT NULL DEFAULT 7,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
        );
        
        CREATE INDEX IF NOT EXISTS idx_maintenance_status 
        ON maintenance_checks(last_completed_date, frequency);
    """
}

// MARK: - SQLite Implementation
@MainActor
final class SQLiteMaintenanceStore: MaintenanceDataStore {
    private let db: Database
    
    init(database: Database) throws {
        self.db = database
        try createSchema()
    }
    
    private func createSchema() throws {
        try db.execute(MaintenanceCheckSchema.createTable)
    }
    
    func fetchCheck(categoryId: String) async throws -> MaintenanceCheck {
        let query = """
            SELECT category_id, category_name, last_completed_date, frequency
            FROM maintenance_checks
            WHERE category_id = ?
        """
        
        guard let row = try db.pluck(query, arguments: [categoryId]) else {
            throw MaintenanceServiceError.categoryNotFound(categoryId)
        }
        
        return try decodeRow(row)
    }
    
    func fetchAllChecks() async throws -> [MaintenanceCheck] {
        let query = """
            SELECT category_id, category_name, last_completed_date, frequency
            FROM maintenance_checks
            ORDER BY last_completed_date ASC
        """
        
        let rows = try db.execute(query)
        return try rows.map { try decodeRow($0) }
    }
    
    func updateCheckDate(categoryId: String, date: Date) async throws {
        let isoDate = ISO8601DateFormatter().string(from: date)
        
        let query = """
            UPDATE maintenance_checks
            SET last_completed_date = ?, updated_at = ?
            WHERE category_id = ?
        """
        
        let changes = try db.execute(
            query,
            arguments: [isoDate, ISO8601DateFormatter().string(from: Date()), categoryId]
        )
        
        guard changes > 0 else {
            throw MaintenanceServiceError.categoryNotFound(categoryId)
        }
    }
    
    func updateFrequency(categoryId: String, frequency: MaintenanceFrequency) async throws {
        let query = """
            UPDATE maintenance_checks
            SET frequency = ?, updated_at = ?
            WHERE category_id = ?
        """
        
        let changes = try db.execute(
            query,
            arguments: [frequency.rawValue, ISO8601DateFormatter().string(from: Date()), categoryId]
        )
        
        guard changes > 0 else {
            throw MaintenanceServiceError.categoryNotFound(categoryId)
        }
    }
    
    // MARK: - Private Helpers
    
    private func decodeRow(_ row: DatabaseRow) throws -> MaintenanceCheck {
        let categoryId: String = row["category_id"]
        let categoryName: String = row["category_name"]
        let dateStr: String? = row["last_completed_date"]
        let frequencyRaw: Int = row["frequency"]
        
        let lastDate = dateStr.flatMap { ISO8601DateFormatter().date(from: $0) }
        let frequency = MaintenanceFrequency(rawValue: frequencyRaw) ?? .weekly
        
        return try MaintenanceCheck(
            categoryId: categoryId,
            categoryName: categoryName,
            lastCompletedDate: lastDate,
            frequency: frequency
        )
    }
}