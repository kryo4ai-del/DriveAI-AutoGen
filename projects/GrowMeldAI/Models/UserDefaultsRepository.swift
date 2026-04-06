import Foundation

protocol UserDefaultsRepository: Sendable {
    func set<T: Encodable>(_ value: T, forKey key: String) async throws
    func get<T: Decodable>(_ type: T.Type, forKey key: String) async throws -> T?
    func remove(forKey key: String) async throws
}