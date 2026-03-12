import Foundation

enum DataError: Error {
    case questionLoadingFailed
    case parsingError(String)
    // More cases can be added as needed
}
