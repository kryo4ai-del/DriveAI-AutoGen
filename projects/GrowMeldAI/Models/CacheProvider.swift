// Services/Data/CacheProtocol.swift
import Foundation

protocol CacheProvider: AnyObject {
    associatedtype Key: Hashable
    associatedtype Value
    
    func get(for key: Key) -> Value?
    func set(_ value: Value, for key: Key)
    func clear()
}

// Concrete thread-safe implementation
@MainActor
final class ThreadSafeCache<Key: Hashable, Value>: CacheProvider {
    private let queue = DispatchQueue(
        label: "com.driveai.cache.\(String(describing: Key.self))",
        attributes: .concurrent
    )
    private var _storage: [Key: Value] = [:]
    
    func get(for key: Key) -> Value? {
        queue.sync { _storage[key] }
    }
    
    func set(_ value: Value, for key: Key) {
        queue.async(flags: .barrier) {
            self._storage[key] = value
        }
    }
    
    func clear() {
        queue.async(flags: .barrier) {
            self._storage.removeAll()
        }
    }
}

// Use in LocalDataService