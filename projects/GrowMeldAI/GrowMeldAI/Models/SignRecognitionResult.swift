import Foundation

// MARK: - Sign Recognition Result

struct SignRecognitionResult: Identifiable, Codable, Sendable {
    let id: UUID
    let signLabel: String
    let confidence: Float
    let boundingBox: CGRectCodable?
    let timestamp: Date
    let rawClassifierOutput: [String: Float]

    init(
        id: UUID = UUID(),
        signLabel: String,
        confidence: Float,
        boundingBox: CGRectCodable? = nil,
        timestamp: Date = Date(),
        rawClassifierOutput: [String: Float] = [:]
    ) {
        self.id = id
        self.signLabel = signLabel
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.timestamp = timestamp
        self.rawClassifierOutput = rawClassifierOutput
    }

    /// Returns true when the model is sufficiently confident in this recognition.
    var isHighConfidence: Bool {
        confidence >= 0.75
    }

    /// Human-readable confidence percentage string.
    var confidencePercentage: String {
        String(format: "%.1f%%", confidence * 100)
    }
}

// MARK: - CGRect Codable Wrapper

/// A `Codable` + `Sendable` wrapper around `CGRect` so that
/// `SignRecognitionResult` can be fully serialized without pulling in SwiftUI.
struct CGRectCodable: Codable, Sendable, Equatable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double

    init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    #if canImport(CoreGraphics)
    import CoreGraphics

    init(_ rect: CGRect) {
        self.x = Double(rect.origin.x)
        self.y = Double(rect.origin.y)
        self.width = Double(rect.size.width)
        self.height = Double(rect.size.height)
    }

    var cgRect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
    #endif
}

// MARK: - Recognition Status

enum SignRecognitionStatus: String, Codable, Sendable {
    case idle
    case processing
    case succeeded
    case failed
    case lowConfidence
}

// MARK: - Recognition Session

struct SignRecognitionSession: Identifiable, Codable, Sendable {
    let id: UUID
    let startedAt: Date
    var results: [SignRecognitionResult]
    var status: SignRecognitionStatus

    init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        results: [SignRecognitionResult] = [],
        status: SignRecognitionStatus = .idle
    ) {
        self.id = id
        self.startedAt = startedAt
        self.results = results
        self.status = status
    }

    /// The best result in the session by confidence score.
    var bestResult: SignRecognitionResult? {
        results.max(by: { $0.confidence < $1.confidence })
    }

    /// All results that exceed the high-confidence threshold.
    var highConfidenceResults: [SignRecognitionResult] {
        results.filter { $0.isHighConfidence }
    }
}