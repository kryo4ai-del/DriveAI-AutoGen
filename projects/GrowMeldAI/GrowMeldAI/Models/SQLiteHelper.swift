// File: Sources/Services/SQLiteHelper.swift

import SQLite3

struct SQLiteHelper {
    static func getText(_ statement: OpaquePointer?, column: Int32) -> String? {
        guard let cString = sqlite3_column_text(statement, column) else {
            return nil // NULL in database
        }
        return String(cString: cString)
    }
    
    static func getInt(_ statement: OpaquePointer?, column: Int32) -> Int? {
        let value = sqlite3_column_int(statement, column)
        // Check if column was actually NULL (SQLite returns 0 for NULL ints)
        guard sqlite3_column_type(statement, column) != SQLITE_NULL else {
            return nil
        }
        return Int(value)
    }
    
    static func getDouble(_ statement: OpaquePointer?, column: Int32) -> Double? {
        guard sqlite3_column_type(statement, column) != SQLITE_NULL else {
            return nil
        }
        return Double(sqlite3_column_double(statement, column))
    }
}

// Usage in parseQuestion():
private func parseQuestion(from statement: OpaquePointer?) -> Question? {
    guard let statement = statement else { return nil }
    
    guard let idString = SQLiteHelper.getText(statement, column: 0),
          let categoryIdString = SQLiteHelper.getText(statement, column: 1),
          let text = SQLiteHelper.getText(statement, column: 2),
          let optionsJson = SQLiteHelper.getText(statement, column: 4),
          let correctIndex = SQLiteHelper.getInt(statement, column: 5),
          let explanation = SQLiteHelper.getText(statement, column: 6)
    else {
        // Log and skip corrupt row
        logger.error("Failed to parse question: missing required fields")
        return nil
    }
    
    let imageUrl = SQLiteHelper.getText(statement, column: 3) // Optional
    let difficulty = SQLiteHelper.getInt(statement, column: 7) ?? 1
    
    guard let id = UUID(uuidString: idString),
          let categoryId = UUID(uuidString: categoryIdString),
          let options = try? JSONDecoder().decode([String].self, 
                                                   from: optionsJson.data(using: .utf8) ?? Data())
    else {
        logger.error("Failed to parse question: invalid UUID or JSON")
        return nil
    }
    
    return Question(
        id: id,
        categoryId: categoryId,
        text: text,
        imageUrl: imageUrl,
        options: options,
        correctOptionIndex: correctIndex,
        explanation: explanation,
        difficulty: difficulty
    )
}