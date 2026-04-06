import Foundation

protocol DataSource {
    func fetch() async throws -> [ExamCenter]
}

struct ExamCenter: Codable, Identifiable {
    let id: String
    let name: String
    let address: String
    let city: String
    let postalCode: String
    let latitude: Double
    let longitude: Double
}

enum DataSourceType: DataSource {
    case bundleJSON(filename: String)
    case mock([ExamCenter])

    init(bundleJSON filename: String = "exam-centers") {
        self = .bundleJSON(filename: filename)
    }

    func fetch() async throws -> [ExamCenter] {
        switch self {
        case .bundleJSON(let filename):
            return try loadFromBundle(filename)
        case .mock(let centers):
            return centers
        }
    }

    private func loadFromBundle(_ filename: String) throws -> [ExamCenter] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw DataSourceError.fileNotFound(filename)
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([ExamCenter].self, from: data)
    }
}

enum DataSourceError: LocalizedError {
    case fileNotFound(String)
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "Bundle file not found: \(name).json"
        case .decodingFailed(let reason):
            return "Failed to decode data: \(reason)"
        }
    }
}