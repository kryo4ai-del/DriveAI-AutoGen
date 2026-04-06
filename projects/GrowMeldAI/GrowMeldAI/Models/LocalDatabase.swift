final class LocalDatabase {
    private let path: URL
    private var cachedQuestions: [Question]?
    private var cachedCategories: [Category]?
    
    init(path: URL) throws {  // ⚠️ Make throws to propagate errors
        self.path = path
        try seedDataIfNeeded()
    }
    
    private func seedDataIfNeeded() throws {
        // Check if data already exists
        if FileManager.default.fileExists(atPath: path.path) {
            // Validate existing data is not corrupted
            if let data = try? Data(contentsOf: path) {
                _ = try JSONDecoder().decode(DatabaseSchema.self, from: data)
                return  // Valid data exists, skip seeding
            }
            // Corrupted file — delete and reseed
            try FileManager.default.removeItem(at: path)
        }
        
        // Load bundled questions.json
        guard let bundledPath = Bundle.main.path(forResource: "questions_catalog", ofType: "json") else {
            throw DatabaseError.missingBundledData
        }
        
        let data = try Data(contentsOf: URL(fileURLWithPath: bundledPath))
        try data.write(to: path, options: .atomic)  // Atomic write prevents corruption
        
        // Verify seeded data is valid
        _ = try JSONDecoder().decode(DatabaseSchema.self, from: data)
    }
    
    func loadData() throws -> DatabaseSchema {  // ⚠️ Return Result or throw
        let data = try Data(contentsOf: path)
        return try JSONDecoder().decode(DatabaseSchema.self, from: data)
    }
}
