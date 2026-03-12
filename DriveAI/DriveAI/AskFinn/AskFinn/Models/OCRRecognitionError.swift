import Foundation

enum OCRRecognitionError: Error {
    case imageTooSmall
    case emptyImage
    case recognitionFailed(reason: String)
    case unknown
}
