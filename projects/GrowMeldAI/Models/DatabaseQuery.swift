import Foundation

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

    func `where`(_ condition: String, values: [DatabaseValue]) -> Self {
        var copy = self
        copy = Self(sql: sql + " WHERE \(condition)", bindings: bindings + values)
        return copy
    }

    func orderBy(_ column: String, ascending: Bool = true) -> Self {
        Self(sql: sql + " ORDER BY \(column) \(ascending ? "ASC" : "DESC")", bindings: bindings)
    }

    func limit(_ count: Int, offset: Int = 0) -> Self {
        var newSQL = sql + " LIMIT \(count)"
        if offset > 0 {
            newSQL += " OFFSET \(offset)"
        }
        return Self(sql: newSQL, bindings: bindings)
    }

    func groupBy(_ columns: String) -> Self {
        Self(sql: sql + " GROUP BY \(columns)", bindings: bindings)
    }

    // MARK: - Binding

    func bind(_ values: DatabaseValue...) -> Self {
        Self(sql: sql, bindings: bindings + values)
    }
}

// MARK: - Database Value Enum

enum DatabaseValue {
    case integer(Int)
    case real(Double)
    case text(String)
    case blob(Data)
    case null
}