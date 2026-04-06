import Foundation

protocol DataCodec: AnyObject, Sendable {
    func encode<T: Encodable>(_ value: T) async throws -> Data
    func decode<T: Decodable>(_ type: T.Type, from data: Data) async throws -> T
}

actor JSONDataCodec: DataCodec {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func encode<T: Encodable>(_ value: T) async throws -> Data {
        try encoder.encode(value)
    }

    func decode<T: Decodable>(_ type: T.Type, from data: Data) async throws -> T {
        try decoder.decode(type, from: data)
    }
}