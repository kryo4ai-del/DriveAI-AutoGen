final class MLInferenceService {
    enum MLError: LocalizedError {
        case modelNotFound
        case modelLoadFailed(String)
        case predictionFailed(String)
        case invalidInput
        case timeout
        
        var errorDescription: String? {
            switch self {
            case .modelNotFound:
                return "ML-Modell nicht verfügbar"
            case .modelLoadFailed(let reason):
                return "Modell konnte nicht geladen werden: \(reason)"
            case .predictionFailed(let reason):
                return "Vorhersage fehlgeschlagen: \(reason)"
            case .invalidInput:
                return "Eingabedaten ungültig"
            case .timeout:
                return "ML-Analyse Timeout"
            }
        }
    }
    
    private var modelCache: GermanQuestionClassifier?
    private let modelLoadTimeout: TimeInterval = 1.0
    
    func classifyQuestion(text: String) async throws -> MLPrediction {
        // Validate input before ML
        let trimmedText = text.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty && trimmedText.count < 1000 else {
            throw MLError.invalidInput
        }
        
        do {
            let model = try await loadModelWithTimeout()
            let input = GermanQuestionClassifierInput(text: trimmedText)
            let output = try model.prediction(input: input)
            
            return MLPrediction(
                category: output.category,
                confidence: Double(output.confidence) ?? 0.0
            )
        } catch let error as MLError {
            throw error
        } catch {
            throw MLError.predictionFailed(error.localizedDescription)
        }
    }
    
    private func loadModelWithTimeout() async throws -> GermanQuestionClassifier {
        // Return cached model if available
        if let cached = modelCache {
            return cached
        }
        
        // Load with timeout protection
        let result = try await withThrowingTaskGroup(of: GermanQuestionClassifier.self) { group in
            group.addTask {
                guard let bundle = Bundle.main.url(forResource: "GermanQuestionClassifier", withExtension: "mlmodelc") else {
                    throw MLError.modelNotFound
                }
                
                do {
                    let model = try GermanQuestionClassifier()
                    return model
                } catch {
                    throw MLError.modelLoadFailed(error.localizedDescription)
                }
            }
            
            // Add timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(modelLoadTimeout * 1_000_000_000))
                throw MLError.timeout
            }
            
            // Return first successful result (either model loads or timeout triggers)
            let result = try await group.next()
            group.cancelAll()
            return result ?? { throw MLError.modelNotFound }()
        }
        
        modelCache = result
        return result
    }
}