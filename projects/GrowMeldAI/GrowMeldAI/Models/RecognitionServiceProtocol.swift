import UIKit

// MARK: - Sign Recognition Result

struct SignRecognitionResult {
    let sign: String
    let confidence: Float
    let boundingBox: CGRect?

    init(sign: String, confidence: Float, boundingBox: CGRect? = nil) {
        self.sign = sign
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

// MARK: - Recognition Service Protocol

protocol RecognitionServiceProtocol {
    func recognizeSign(from image: UIImage) async throws -> SignRecognitionResult
}