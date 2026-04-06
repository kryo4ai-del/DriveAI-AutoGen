// ✅ CORRECT: Local processing, immediate cleanup
@MainActor
class RecognitionService {
    func recognizeSign(from image: UIImage) async throws -> SignRecognitionResult {
        // Step 1: Preprocess (on-device)
        let pixelBuffer = try visionService.preprocessImage(image)
        
        // Step 2: Inference (on-device)
        let prediction = try await mlModel.recognize(pixelBuffer: pixelBuffer)
        
        // Step 3: CRITICAL - Release pixel buffer immediately
        // Do NOT persist, cache, or send anywhere
        MemoryManager.release(pixelBuffer)
        
        // Step 4: Link to questions (local database)
        let questions = questionLinker.getRelatedQuestions(for: prediction.signID)
        
        return SignRecognitionResult(...)
    }
}