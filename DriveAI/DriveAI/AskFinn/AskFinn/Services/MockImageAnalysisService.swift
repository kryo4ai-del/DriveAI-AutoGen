import Foundation
import UIKit

class MockImageAnalysisService: ImageAnalysisService {
    var shouldReturnError = false

    func mockAnalyze(image: UIImage, completion: @escaping (Swift.Result<AnalysisResult, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "AnalysisError", code: -1, userInfo: nil)))
        } else {
            let result = AnalysisResult(
                question: "Mock question",
                userAnswer: "Mock answer",
                correctAnswer: "Mock correct answer"
            )
            completion(.success(result))
        }
    }
}
