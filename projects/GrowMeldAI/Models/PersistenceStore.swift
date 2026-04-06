@MainActor
final class PersistenceStore {
    static let shared = PersistenceStore()
    
    private let fileManager = FileManager.default
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // MARK: - Typed, Codable-based persistence
    func save<T: Encodable>(_ object: T, to filename: String) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(object)
        let url = documentsDirectory.appendingPathComponent(filename)
        
        try data.write(to: url, options: .atomic)
    }
    
    func load<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        let url = documentsDirectory.appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(T.self, from: data)
    }
    
    func delete(_ filename: String) throws {
        let url = documentsDirectory.appendingPathComponent(filename)
        try fileManager.removeItem(at: url)
    }
    
    func exists(_ filename: String) -> Bool {
        let url = documentsDirectory.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: url.path)
    }
}

// Usage: