// MARK: - Tests/Mocks/MockUserDefaults.swift

import Foundation

class MockUserDefaults: UserDefaults {
  private var storage: [String: Any] = [:]
  
  override func set(_ value: Any?, forKey defaultName: String) {
    storage[defaultName] = value
  }
  
  override func object(forKey defaultName: String) -> Any? {
    return storage[defaultName]
  }
  
  override func string(forKey defaultName: String) -> String? {
    return storage[defaultName] as? String
  }
  
  override func data(forKey defaultName: String) -> Data? {
    return storage[defaultName] as? Data
  }
  
  override func array(forKey defaultName: String) -> [Any]? {
    return storage[defaultName] as? [Any]
  }
  
  override func dictionary(forKey defaultName: String) -> [String: Any]? {
    return storage[defaultName] as? [String: Any]
  }
  
  override func removeObject(forKey defaultName: String) {
    storage.removeValue(forKey: defaultName)
  }
  
  override func dictionaryRepresentation() -> [String: Any] {
    return storage
  }
  
  func clear() {
    storage.removeAll()
  }
}

// MARK: - Atomic Counter for Concurrency Tests
actor AtomicCounter {
  private var value: Int = 0
  
  func increment() {
    value += 1
  }
  
  func get() -> Int {
    return value
  }
  
  func reset() {
    value = 0
  }
}