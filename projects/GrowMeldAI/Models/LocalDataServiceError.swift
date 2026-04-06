import Foundation

enum LocalDataServiceError: Error {
    case fileNotFound(String)
    case invalidData
    case decodingFailed(Error)
}
