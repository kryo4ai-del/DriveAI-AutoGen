import Foundation
import UIKit
import Vision

// MARK: - OCRRecognitionProtocol

protocol OCRRecognitionProtocol {
    func recognizeText(from image: UIImage, completion: @escaping (Swift.Result<String, OCRRecognitionError>) -> Void)
}
