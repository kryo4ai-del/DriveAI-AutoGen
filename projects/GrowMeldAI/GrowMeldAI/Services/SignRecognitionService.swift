final class SignRecognitionService: SignRecognitionServiceProtocol {
    private let signDatabase: SignDatabaseServiceProtocol
    private static let confidenceThreshold: Float = 0.7
    
    func recognizeSign(from image: UIImage) async throws -> RecognizedSign? {
        guard let ciImage = CIImage(image: image) else {
            throw CameraError.invalidImage
        }
        
        // ✅ Option 1: Vision Framework edge detection
        let detectedShapes = try detectShapes(in: ciImage)
        
        // ✅ Option 2: Core ML model (if available)
        // let predictions = try trafficSignModel.predict(on: ciImage)
        
        // Match detected shapes to database
        for shape in detectedShapes {
            if let matchedSign = try await matchToDatabase(shape: shape) {
                return matchedSign
            }
        }
        
        return nil  // No confident match
    }
    
    private func detectShapes(in image: CIImage) throws -> [DetectedShape] {
        let request = VNDetectContoursRequest()
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        
        try handler.perform([request])
        
        guard let observations = request.results as? [VNContoursObservation] else {
            return []
        }
        
        return observations.compactMap { obs in
            DetectedShape(
                area: obs.contourApproximation?.boundingBox ?? .zero,
                confidence: Float(obs.confidence)
            )
        }
    }
    
    private func matchToDatabase(shape: DetectedShape) async throws -> RecognizedSign? {
        let allSigns = try await signDatabase.fetchAllSigns()
        
        for sign in allSigns {
            let similarity = calculateSimilarity(shape, to: sign.referenceShape)
            if similarity > Self.confidenceThreshold {
                return RecognizedSign(
                    id: sign.id,
                    name: sign.localizedName,
                    confidence: similarity,
                    imageName: sign.imageName,
                    category: sign.category,
                    timestamp: Date()
                )
            }
        }
        
        return nil
    }
}