struct CodableMetadata: Codable {
    private let data: [String: AnyCodable]
    
    init(from dict: [String: Any]) throws {
        var converted: [String: AnyCodable] = [:]
        for (key, value) in dict {
            do {
                converted[key] = try AnyCodable(value)
            } catch {
                throw ABTestingError.serializationFailed(key: key, reason: error.localizedDescription)
            }
        }
        self.data = converted
    }
    
    func toDictionary() -> [String: Any] {
        return data.mapValues { $0.value }
    }
}

/// Wrapper for heterogeneous Codable values

// Updated error enum