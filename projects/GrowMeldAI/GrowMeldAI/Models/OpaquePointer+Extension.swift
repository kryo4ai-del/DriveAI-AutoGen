extension OpaquePointer {
    func getDecodedJSON<T: Decodable>(
        column: Int32,
        as type: T.Type
    ) throws -> T {
        guard let blob = sqlite3_column_blob(self, column) else {
            throw DataServiceError.corruptedData("Null blob")
        }
        let data = Data(bytes: blob, count: Int(sqlite3_column_bytes(self, column)))
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func getString(column: Int32) -> String {
        String(cString: sqlite3_column_text(self, column))
    }
}