// MARK: - QuestionIdentificationService.swift
/// Main orchestrator - owns pipeline, timeout, and error handling
@MainActor
final class QuestionIdentificationService: ObservableObject {
    @Published var analysisProgress: AnalysisProgress = .idle
    
    private let textExtractor: TextExtractionService
    private let classifier: QuestionClassifierService
    private let matcher: QuestionMatcherService
    private let logger: AnalyticsLogger
    
    private let timeout: TimeInterval = 3.0
    private let stages: [AnalysisStage] = [
        .extraction(duration: 1.5),
        .classification(duration: 1.0),
        .matching(duration: 0.5)
    ]
    
    // MARK: - Public API
    
    func identifyQuestion(from image: UIImage) async -> QuestionIdentificationResult {
        let startTime = Date()
        
        do {
            // Stage 1: Extract text
            analysisProgress = .extracting
            let text = try await textExtractor.extract(from: image)
            try checkTimeout(since: startTime, stage: .extraction)
            
            // Stage 2: Classify
            analysisProgress = .classifying
            let prediction = try await classifier.classify(text: text)
            try checkTimeout(since: startTime, stage: .classification)
            
            // Stage 3: Match
            analysisProgress = .matching
            let match = try await matcher.findBestMatch(
                for: text,
                in: prediction.category,
                withFallback: true
            )
            try checkTimeout(since: startTime, stage: .matching)
            
            // Success
            let elapsed = Date().timeIntervalSince(startTime)
            logSuccess(
                questionID: match.question.id,
                confidence: match.confidence,
                elapsedTime: elapsed,
                stageTimings: computeStageTimings(from: startTime)
            )
            
            return .success(
                question: match.question,
                confidence: match.confidence,
                elapsedTime: elapsed
            )
            
        } catch let error as QuestionIdentificationError {
            logError(error, elapsedTime: Date().timeIntervalSince(startTime))
            return mapErrorToResult(error)
        } catch {
            let unknownError = QuestionIdentificationError.unknown(error.localizedDescription)
            logError(unknownError, elapsedTime: Date().timeIntervalSince(startTime))
            return .error(unknownError.localizedDescription)
        }
    }
    
    // MARK: - Private Helpers
    
    private func checkTimeout(since startTime: Date, stage: AnalysisStage) throws {
        let elapsed = Date().timeIntervalSince(startTime)
        if elapsed > timeout {
            throw QuestionIdentificationError.timeout(stage: stage, elapsed: elapsed)
        }
    }
    
    private func mapErrorToResult(_ error: QuestionIdentificationError) -> QuestionIdentificationResult {
        switch error {
        case .timeout:
            return .timeout
        case .noTextDetected:
            return .fallback(reason: .noTextDetected)
        case .mlUnavailable:
            // Fallback to pure text matching
            return .fallback(reason: .mlUnavailable)
        case .noMatch:
            return .fallback(reason: .noMatch)
        default:
            return .error(error.localizedDescription)
        }
    }
    
    private func logSuccess(
        questionID: String,
        confidence: Double,
        elapsedTime: TimeInterval,
        stageTimings: [String: TimeInterval]
    ) {
        logger.track(event: "question_identified", parameters: [
            "question_id": questionID,
            "confidence": confidence,
            "elapsed_time_ms": Int(elapsedTime * 1000),
            "stages": stageTimings.mapValues { Int($0 * 1000) }
        ])
    }
}

// MARK: - Error Handling (Centralized)
enum QuestionIdentificationError: LocalizedError {
    case timeout(stage: AnalysisStage, elapsed: TimeInterval)
    case noTextDetected
    case mlUnavailable(reason: String)
    case noMatch
    case invalidImage
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .timeout(let stage, let elapsed):
            return "Analyse überschritt Zeitlimit (\(String(format: "%.1f", elapsed))s) bei \(stage.name)"
        case .noTextDetected:
            return "Keine Frage im Bild erkannt"
        case .mlUnavailable(let reason):
            return "KI-Modell nicht verfügbar: \(reason)"
        case .noMatch:
            return "Frage nicht in Datenbank gefunden"
        case .invalidImage:
            return "Bild konnte nicht verarbeitet werden"
        case .unknown(let msg):
            return "Fehler: \(msg)"
        }
    }
}

enum AnalysisStage: Equatable {
    case extraction
    case classification
    case matching
    
    var name: String {
        switch self {
        case .extraction: return "Textextraktion"
        case .classification: return "Klassifizierung"
        case .matching: return "Zuordnung"
        }
    }
}

enum AnalysisProgress {
    case idle
    case extracting(progress: Double = 0.33)
    case classifying(progress: Double = 0.66)
    case matching(progress: Double = 0.99)
}