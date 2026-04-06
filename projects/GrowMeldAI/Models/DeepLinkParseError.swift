import Foundation

enum DeepLinkParseError: Error {
    case unknownPath(String)
    case malformedCategoryId(String)
}
