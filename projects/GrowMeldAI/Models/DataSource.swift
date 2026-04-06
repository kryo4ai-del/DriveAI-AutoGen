import Foundation

// MARK: - DataSource

enum DataSource {
    case bundled
    case mock
}

// MARK: - DataLoadError

enum DataLoadError: LocalizedError {
    case fileNotFound
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "The data file could not be found in the bundle."
        case .decodingFailed(let reason):
            return "Failed to decode data: \(reason)"
        }
    }
}

// MARK: - BundleDataLoader

struct BundleDataLoader {
    static func load<T: Decodable>(_ type: T.Type, fromFile fileName: String) throws -> T {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw DataLoadError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw DataLoadError.decodingFailed(error.localizedDescription)
        }
    }
}