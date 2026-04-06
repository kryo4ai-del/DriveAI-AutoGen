// Tests/Mocks/MockPersistenceStore.swift
final class MockPersistenceStore: PersistenceStore {
    var savedData: [String: Data] = [:]
    
    func save(_ data: Data, for key: String) throws {
        savedData[key] = data
    }
    
    func load(for key: String) throws -> Data? {
        savedData[key]
    }
    
    func remove(for key: String) throws {
        savedData.removeValue(forKey: key)
    }
}

// In test:
let mockStore = MockPersistenceStore()
let service = UserProfileService(persistenceStore: mockStore)
try service.saveProfile()
XCTAssertNotNil(mockStore.savedData[profileKey])