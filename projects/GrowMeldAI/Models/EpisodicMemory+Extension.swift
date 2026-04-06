// ✅ OPTION A: Use SQLite.swift fluent API
func fetchRecent(limit: Int = 20, offset: Int = 0) async throws -> [EpisodicMemory] {
    return try await database.read { db in
        let memories = Table("episodic_memories")
        let timestampCol = Expression<Date>("timestamp")
        let idCol = Expression<String>("id")
        
        return try db
            .prepare(memories.order(timestampCol.desc).limit(limit, offset: offset))
            .compactMap { row in
                try? EpisodicMemory.from(row: row)  // Custom decoder
            }
    }
}

// Custom decoder using SQLite.swift's Row type
extension EpisodicMemory {
    static func from(row: Row) throws -> EpisodicMemory {
        let typeExp = Expression<String>("type")
        let metadataExp = Expression<String>("metadata")
        let timestampExp = Expression<Date>("timestamp")
        
        let typeString = row[typeExp]
        let metadataString = row[metadataExp]
        
        guard let type = MemoryType(rawValue: typeString) else {
            throw EpisodicMemoryError.invalidMetadata
        }
        
        guard let metadataData = metadataString.data(using: .utf8),
              let metadata = try? JSONDecoder().decode(MemoryMetadata.self, from: metadataData)
        else {
            throw EpisodicMemoryError.invalidMetadata
        }
        
        return EpisodicMemory(
            id: row[Expression<String>("id")],
            type: type,
            timestamp: row[timestampExp],
            categoryId: try? row.get(Expression<String>("category_id")),
            metadata: metadata,
            contextScore: row[Expression<Int>("context_score")]
        )
    }
}

// ✅ OPTION B: Raw SQL with explicit parameter markers
func fetchRecent(limit: Int = 20, offset: Int = 0) async throws -> [EpisodicMemory] {
    return try await database.read { db in
        let sql = """
            SELECT id, type, timestamp, category_id, metadata, context_score
            FROM episodic_memories
            ORDER BY timestamp DESC
            LIMIT ? OFFSET ?
        """
        
        return try db.prepare(sql).bind(limit, offset)
            .compactMap { stmt in
                try? EpisodicMemory.from(statement: stmt)
            }
    }
}