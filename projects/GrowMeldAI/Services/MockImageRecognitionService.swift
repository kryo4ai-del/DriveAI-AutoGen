import Foundation

// MARK: - Supporting Types

enum ImageRecognitionError: LocalizedError {
    case unableToProcess
    case lowConfidence
    case unknown

    var errorDescription: String? {
        switch self {
        case .unableToProcess: return "Unable to process image."
        case .lowConfidence: return "Recognition confidence too low."
        case .unknown: return "An unknown error occurred."
        }
    }
}

enum RecognitionCategory {
    case trafficSign
    case vehicle
    case roadMarking
    case other
}

struct IdentificationRequest {
    let imageData: Data
    let maxResults: Int

    init(imageData: Data, maxResults: Int = 5) {
        self.imageData = imageData
        self.maxResults = maxResults
    }
}

struct IdentificationResult {
    let name: String
    let confidence: Double
    let category: RecognitionCategory
    let description: String
}

protocol ImageRecognitionService {
    func identify(request: IdentificationRequest) async throws -> IdentificationResult
}

// MARK: - Mock Extension

extension IdentificationResult {
    static var mock: IdentificationResult {
        IdentificationResult(
            name: "Stop Sign",
            confidence: 0.95,
            category: .trafficSign,
            description: "Red octagonal sign"
        )
    }
}

// MARK: - Mock Service

final class MockImageRecognitionService: ImageRecognitionService {
    var identifyResult: Result<IdentificationResult, ImageRecognitionError> =
        .success(IdentificationResult.mock)

    func identify(request: IdentificationRequest) async throws -> IdentificationResult {
        try identifyResult.get()
    }
}