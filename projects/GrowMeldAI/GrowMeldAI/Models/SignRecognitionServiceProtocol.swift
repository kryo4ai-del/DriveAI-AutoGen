import Vision
import UIKit

protocol SignRecognitionServiceProtocol: Sendable {
    func recognizeSign(from image: UIImage) async throws -> RecognizedSign?
    func selectSignManually(id: String) async throws -> RecognizedSign
}
