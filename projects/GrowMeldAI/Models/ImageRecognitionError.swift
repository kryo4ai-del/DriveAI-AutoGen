import Foundation
import SwiftUI
enum ImageRecognitionError: LocalizedError {
  case invalidImage(reason: String)
  case apiKeyMissing
  case quotaExceeded(retryAfter: Date?)
  case networkFailure(underlying: URLError)
  case apiResponseInvalid(statusCode: Int)
  case cacheError(underlying: Error)
  case unknownIdentification // "I don't know what this is"
  
  var recoveryAction: RecoveryAction {
    switch self {
    case .quotaExceeded(let retryAfter):
      return .retryLater(retryAfter ?? Date(timeIntervalSinceNow: 3600))
    case .networkFailure:
      return .useCache // Fall back to cached result
    case .apiKeyMissing:
      return .configureFeature // Prompt admin setup
    default:
      return .retry
    }
  }
}

enum RecoveryAction {
  case retry
  case retryLater(Date)
  case useCache
  case configureFeature
  case contactSupport
}