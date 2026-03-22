// ✅ CORRECT: Protocol-driven
protocol PersistenceManager {
    func save<T: Codable>(_ model: T, for key: String) throws
    func load<T: Codable>(for key: String) throws -> T
    func delete(for key: String) throws
}

class UserDefaultsPersistence: PersistenceManager {
    func save<T: Codable>(_ model: T, for key: String) throws {
        let data = try JSONEncoder().encode(model)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func load<T: Codable>(for key: String) throws -> T {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            throw PersistenceError.notFound
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func delete(for key: String) throws {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// Test mock
class MockPersistence: PersistenceManager {
    var savedData: [String: Any] = [:]
    
    func save<T: Codable>(_ model: T, for key: String) throws {
        savedData[key] = model
    }
    
    func load<T: Codable>(for key: String) throws -> T {
        guard let model = savedData[key] as? T else {
            throw PersistenceError.notFound
        }
        return model
    }
    
    func delete(for key: String) throws {
        savedData.removeValue(forKey: key)
    }
}