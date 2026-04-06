import UIKit

// MARK: - Sign Recognition Result

// Struct SignRecognitionResult declared in Models/SignRecognitionResult.swift

// MARK: - Recognition Service Protocol

protocol RecognitionServiceProtocol {
    func recognizeSign(from image: UIImage) async throws -> SignRecognitionResult
}