import Foundation

enum CameraState {
    case idle
    case capturing
    case processing
    case showingResult
    case error(String)

    var actionDescription: String {
        switch self {
        case .idle:
            return ""
        case .capturing:
            return "Capture in progress..."
        case .processing:
            return "Analyzing..."
        case .showingResult:
            return ""
        case .error(let message):
            return message
        }
    }
}