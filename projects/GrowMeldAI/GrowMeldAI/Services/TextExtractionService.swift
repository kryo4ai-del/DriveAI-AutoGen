// MARK: - TextExtractionService.swift
final class TextExtractionService {
    enum ExtractionError: LocalizedError {
        case invalidImage
        case visionFrameworkUnavailable
        case timeout
        case noTextFound
    }
    
    private let timeout: TimeInterval = 1.5
    
    /// Extract German text from image
    /// - Parameter image: UIImage to process
    /// - Returns: Extracted text or nil if no text detected
    /// - Throws: ExtractionError on fatal errors
    func extract(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw ExtractionError.invalidImage
        }
        
        return try await withTimeoutDeadline(deadline: timeout) {
            try await performOCR(cgImage: cgImage)
        }
    }
    
    private func performOCR(cgImage: CGImage) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let requestHandler = VNImageRequestHandler(cgImage: cgImage)
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: ExtractionError.noTextFound)
                    return
                }
                
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                
                if text.isEmpty {
                    continuation.resume(throwing: ExtractionError.noTextFound)
                } else {
                    continuation.resume(returning: text)
                }
            }
            
            request.recognitionLanguages = ["de"]
            request.usesLanguageCorrection = true
            if #available(iOS 16.0, *) {
                request.recognitionLevel = .fast
            }
            
            try requestHandler.perform([request])
        }
    }
}

// MARK: - QuestionClassifierService.swift
final class QuestionClassifierService {
    enum ClassificationError: LocalizedError {
        case modelNotFound
        case modelLoadFailed(String)
        case predictionFailed(String)
        case invalidInput
    }
    
    private let timeout: TimeInterval = 1.0
    private var modelCache: GermanQuestionClassifier?
    private let modelLock = NSLock()
    
    func classify(text: String) async throws -> ClassificationResult {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty, trimmed.count < 5000 else {
            throw ClassificationError.invalidInput
        }
        
        return try await withTimeoutDeadline(deadline: timeout) {
            let model = try loadModel()
            let input = GermanQuestionClassifierInput(text: trimmed)
            
            do {
                let output = try model.prediction(input: input)
                return ClassificationResult(
                    category: output.category,
                    confidence: Double(output.confidence) ?? 0.0
                )
            } catch {
                throw ClassificationError.predictionFailed(error.localizedDescription)
            }
        }
    }
    
    private func loadModel() throws -> GermanQuestionClassifier {
        return try modelLock.withLock {
            if let cached = modelCache {
                return cached
            }
            
            do {
                let model = try GermanQuestionClassifier()
                modelCache = model
                return model
            } catch {
                throw ClassificationError.modelLoadFailed(error.localizedDescription)
            }
        }
    }
}

// MARK: - QuestionMatcherService.swift
final class QuestionMatcherService {
    enum MatchingError: LocalizedError {
        case noMatch
        case databaseUnavailable
    }
    
    @Injected private var localDataService: LocalDataService
    private let textNormalizer = TextNormalizer()
    private let fuzzyMatcher = FuzzyMatcher()
    
    func findBestMatch(
        for text: String,
        in category: String,
        withFallback: Bool = true
    ) async throws -> QuestionMatch {
        let normalized = textNormalizer.normalize(text)
        
        // Stage 1: Search in category (fast)
        let categoryQuestions = localDataService.questions(in: category)
        if let match = fuzzyMatcher.findBestMatch(
            query: normalized,
            in: categoryQuestions,
            minScore: 0.85
        ) {
            return match
        }
        
        // Stage 2: Fallback to all questions if enabled
        if withFallback {
            let allQuestions = localDataService.allQuestions
            if let match = fuzzyMatcher.findBestMatch(
                query: normalized,
                in: allQuestions,
                minScore: 0.75
            ) {
                return match
            }
        }
        
        throw MatchingError.noMatch
    }
}

// MARK: - Supporting Types
struct ClassificationResult {
    let category: String
    let confidence: Double
}

struct QuestionMatch {
    let question: Question
    let confidence: Double
    let matchScore: Double
}