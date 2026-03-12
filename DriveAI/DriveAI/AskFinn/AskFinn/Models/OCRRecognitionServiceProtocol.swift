import Foundation
import UIKit

protocol OCRRecognitionServiceProtocol {
    func recognizeText(from image: UIImage, completion: @escaping (Swift.Result<String, OCRRecognitionError>) -> Void)
}
