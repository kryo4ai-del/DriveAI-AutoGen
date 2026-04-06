import Foundation

/// Type-safe query builder for SQLite operations
struct DatabaseQuery {
    let sql: String
    private(set) var bindings: [DatabaseValue] = []
    
    // MARK: - Builders
    
    static func select(_ columns: String = "*", from table: String) -> Self {
        Self(sql: "SELECT \(columns) FROM \(table)")
    }
    
    static func insert(into table: String, columns: [String]) -> Self {
        let placeholders = Array(repeating: "?", count: columns.count).joined(separator: ", ")
        let sql = "INSERT INTO \(table) (\(columns.joined(separator: ", "))) VALUES (\(placeholders))"
        return Self(sql: sql)
    }
    
    static func update(_ table: String) -> Self {
        Self(sql: "UPDATE \(table)")
    }
    
    static func delete(from table: String) -> Self {
        Self(sql: "DELETE FROM \(table)")
    }
    
    // MARK: - Conditions
    
    mutating func `where`(_ condition: String, values: [DatabaseValue]) -> Self {
        sql += " WHERE \(condition)"
        bindings.append(contentsOf: values)
        return self
    }
    
    mutating func orderBy(_ column: String, ascending: Bool = true) -> Self {
        sql += " ORDER BY \(column) \(ascending ? "ASC" : "DESC")"
        return self
    }
    
    mutating func limit(_ count: Int, offset: Int = 0) -> Self {
        sql += " LIMIT \(count)"
        if offset > 0 {
            sql += " OFFSET \(offset)"
        }
        return self
    }
    
    mutating func groupBy(_ columns: String) -> Self {
        sql += " GROUP BY \(columns)"
        return self
    }
    
    // MARK: - Binding
    
    mutating func bind(_ values: DatabaseValue...) -> Self {
        bindings.append(contentsOf: values)
        return self
    }
}

// MARK: - Database Value Enum
