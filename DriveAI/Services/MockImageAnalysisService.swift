class MockImageAnalysisService: ImageAnalysisService {
    var shouldReturnError = false
    
    override func analyze(image: UIImage, completion: @escaping (Result<AnalysisResult, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "AnalysisError", code: -1, userInfo: nil)))
        } else {
            let isRecognized = true // Simulated successful case
            let result = AnalysisResult(isRecognized: isRecognized, description: "Valid sign recognized.")
            completion(.success(result))
        }
    }
}