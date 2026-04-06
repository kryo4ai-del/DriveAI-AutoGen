private class SQLiteConnection {
    private let pointer: OpaquePointer
    
    init(at path: String) throws {
        var ptr: OpaquePointer?
        guard sqlite3_open(path, &ptr) == SQLITE_OK,
              let ptr = ptr else {
            throw DataServiceError.databaseError("Failed to open")
        }
        self.pointer = ptr
    }
    
    deinit {
        sqlite3_close(pointer)
    }
}