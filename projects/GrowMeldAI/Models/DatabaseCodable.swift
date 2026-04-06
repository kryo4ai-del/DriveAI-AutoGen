// Core/Database/DatabaseCodable.swift
/// Reduces GRDB boilerplate through protocol synthesis
protocol DatabaseCodable: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName: String { get }
}

// Mark: Default implementations
extension DatabaseCodable {
    // Uses Codable to auto-sync with database columns
    // Only override if custom logic needed
}

// Core/Models/Question.swift (simplified)

// Core/Models/Category.swift (same pattern)

// ✅ Result: No separate +Database files needed
// Codable + DatabaseCodable handle serialization automatically