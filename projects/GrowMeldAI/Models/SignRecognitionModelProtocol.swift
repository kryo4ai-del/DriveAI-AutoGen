protocol SignRecognitionModelProtocol {
    func loadModel() async throws
    func recognize(pixelBuffer: CVPixelBuffer) async throws -> SignPrediction
    func isModelLoaded() -> Bool
}

@MainActor

// MARK: - Output Models
struct SignPrediction {
    let signID: String
    let confidence: Float // 0.0...1.0
    let inferenceTime: TimeInterval
}